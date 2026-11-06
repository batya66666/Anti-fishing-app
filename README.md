# KÖDER

**Phishing defence as a daily game.** Five minutes a day you work a shift in a simulated office: emails, texts, calls, QR codes and sign-in prompts arrive, and you decide what is an attack. Fall for one and your phone gets "hacked" before your eyes. Then you duel colleagues, or the jury, in real time.

Hackathon project of students at Westsächsische Hochschule Zwickau. Flutter (game and admin panel) and Spring Boot (modular monolith).

## Run it

You need Docker, and Flutter 3.32 to build the web apps.

```powershell
copy .env.example .env          # then set KOEDER_JWT_SECRET and KOEDER_DEMO_PASSWORD
.\scripts\start_wifi.ps1 -Build  # builds everything and starts it for your Wi-Fi
```

The script finds the laptop's Wi-Fi address, starts the stack and prints the address to open. Everybody on the same Wi-Fi can then play in a browser, with no install and no account. Without `-Build` it restarts what is already built, so run it again if your address changes. On Linux and macOS use `scripts/build_web.sh` and `docker compose up -d --build`.

If phones cannot reach the address, the network probably isolates its clients, which is common on guest and university Wi-Fi. Use a phone hotspot instead.

| What | Where |
|---|---|
| Game | http://localhost/ or the printed Wi-Fi address |
| Admin panel | /admin/ on the same address (`thomas@muster-automotive.example`, password from `.env`) |
| API documentation | http://localhost/swagger-ui/index.html |
| Health | http://localhost/actuator/health |

Set `KOEDER_DOMAIN` in `.env` on a server and Caddy obtains HTTPS automatically. The Wi-Fi address has no HTTPS, and the sign-up form says so: nobody should use a real password there.

The game also runs with no backend at all, for example with `flutter run -d chrome`: it detects the missing server and plays locally, with a local bot as the duel opponent.

For Android: `flutter build apk --dart-define=API_BASE=https://your-domain`. The Android build needs JDK 17; Gradle 8.12 does not run on JDK 25.

## What is in it

| Mode | What it does |
|---|---|
| **Working shift** | 8 messages arrive in an inbox, half of them genuine. Calls and sign-in prompts interrupt you. Tap a sender to see the real address, long-press a link to see where it goes. No daily limit |
| **Endless mode** | Question after question at a difficulty you choose. New ones first, then what you saw longest ago |
| **PARANOID sequence** | Reporting a genuine message hacks nobody, so it gets its own reaction: red flags rain on a nervous fish, then an explanation |
| **HACKED sequence** | Every mistake on a real attack: a GLSL shader tears apart a snapshot of the screen, followed by a fake ransomware screen, then a calm debrief with red flags marked on the message. Modes with a running clock and simple mode get a one-second version |
| **Simulators** | Mail with a PDF viewer, SMS, messenger, browser with address bar, incoming call with a dialogue tree, QR, MFA fatigue push spam, file manager, on-site situations |
| **Guided tour** | The dimmed screen lights up one element after another while the fish explains it, on the home screen, in the inbox and in the first mail. Can be repeated from the profile |
| **PvP duel** | 5 rounds over STOMP: same scenarios for both, server-side timing and scoring, ELO, emoji reactions. By ranked queue, code or QR. Players with different languages can duel |
| **Bots** | Four opponents from intern to CISO, or one matched to you. They read at their own speed, go wrong more often on hard messages, and hurry and slip once you have answered. Games against bots never change your ELO |
| **Arena** | One QR code on a slide: everyone who scans is paired up within seconds |
| **Swipe**, **Spot the flags** | Fast verdicts in 60 s; tapping the suspicious parts of a message |
| **Case files** | Replay eight real incidents and try to stop them: Binance 2026 and 2019, Marks & Spencer 2025, Arup 2024, MGM and Retool 2023, Uber 2022, Twitter 2020. Each names its sources and says what is reconstructed and what is uncertain |
| **Check a message** | Paste a suspicious message and get a verdict. Claude if a key is set, otherwise a local rule engine, and the UI says which one answered |
| **Simple mode** | Large type, no timers, no rankings, everyday scams only |
| **Company dashboard** | Human Risk Score, heatmap of department by attack type, trends, live feed, audit PDF, scenario generator with human review |
| **Difficulty control** | A manager pins Bronze to Diamond for the whole company at once, to demonstrate or check a level, and reviews every scenario with its solution as players see it |

The 90 scenarios per language are about half Gold and Diamond: flawless text, real accounts taken over, cloned voices, consent phishing. PDFs carry QR codes, fake sign-in buttons, changed bank details or fake update prompts, and many are genuine, so that "PDF" never means "attack". Every shift contains hard messages, for beginners too.

Accounts are optional. Language comes first, then sign-up, sign-in or guest; registering keeps a guest's progress, and from then on only the password opens the account.

Theory is optional: from the setup screen, the learning path or any lesson.

Also: 13-module learning path that continues where you stopped, spaced repetition (1, 3, 7, 14, 30 days), XP and job titles from intern to CISO, streaks with freezes, weekly leagues, badges, German and English, data export and account deletion.

## Architecture

```mermaid
flowchart LR
    subgraph Clients["Flutter"]
        App["Game: Web, Android"]
        Admin["Admin panel: Web"]
    end
    subgraph Server["Docker Compose"]
        Caddy["Caddy: HTTPS, static files"]
        subgraph Boot["Spring Boot modular monolith"]
            Identity[identity]
            Content[content]
            Shift[shift]
            Duel[duel]
            Progression[progression]
            Organization[organization]
            Ai[ai]
        end
        PG[("PostgreSQL + Flyway")]
    end
    Claude["Claude API"]
    App -->|"REST, STOMP"| Caddy
    Admin -->|"REST, STOMP"| Caddy
    Caddy --> Boot
    Boot --> PG
    Ai --> Claude
    Shift -. ScenarioAnswered, ShiftCompleted .-> Progression
    Shift -. ScenarioAnswered .-> Organization
    Duel -. DuelFinished .-> Progression
```

The modules talk through Spring application events and small public APIs. `ModularityTest` fails the build if a module reaches into another module's internals or a cycle appears. The generated module diagram is in [docs/architecture/modules.puml](docs/architecture/modules.puml).

**Why a monolith?** One deployment is right for one night and one server, while the verified boundaries keep any module, say `duel`, extractable later.

**The contract is enforced.** The app talks to the API through a client generated from the OpenAPI document (`scripts/gen_api.sh`, output in `app/packages/koeder_api`). `OpenApiContractTest` fails if the API and the committed document drift apart.

**Content is data.** All scenarios live in [content/](content/) as JSON, validated against a JSON Schema at startup and in tests. Tests also check that German and English cover the same scenarios, that about half the messages are genuine, that only reserved domains are used, and that every red flag quotes text that really exists. After editing content, run `dart run tool/sync_content.dart` in `app/` to update the offline bundle.

## Security and privacy

- **No personal link in company statistics.** An answer becomes a counter on department, day and attack type, and the user id is dropped at that point. The employer cannot reconstruct who clicked what. Departments under 5 people show no numbers.
- **Anti-cheat.** The solution is not sent before a round ends. The server measures time, accepts one answer per round, and ignores late answers.
- JWT with roles, also checked on the WebSocket. A company's live feed is visible only to managers of that company.
- Bean Validation, parameterised SQL, rate limiting on login and AI, secrets only in the environment, Postgres not published.
- Fonts, CanvasKit and sounds are bundled, so nothing is loaded from third parties.
- All domains in scenarios use reserved zones (`.example`, `.test`), and brands are invented.
- Account deletion cascades through every table holding personal data; export returns all of it as JSON.

## Tests

```powershell
cd backend; mvn verify          # needs Docker for Testcontainers
cd app; flutter analyze; flutter test
```

The backend suite covers ELO, scoring, Leitner, streaks, shift planning, risk score, rule engine, content rules, module boundaries, the API contract, and full flows against real Postgres, including two STOMP clients playing a complete match.

## Demo configuration: turn off for anything real

`KOEDER_DEMO_ENABLED=true` seeds a company with **synthetic** history (labelled in the UI and in the PDF), opens the "reset the day" endpoint, and with `KOEDER_DEMO_AUTO_JOIN=true` adds every guest to that company so the dashboard moves live.

## Known limits

- The web and app bundles contain scenarios with solutions for offline play, so a determined player could look up duel answers. The server still decides timing and score. A production build should bundle only a separate offline pack.
- Nothing limits play, so XP and leagues can be farmed by anyone with enough patience. One answer per message within a shift is still enforced.
- The pool is large but finite: in endless mode questions come back after about 90 answers.
- Session tokens live 30 days and cannot be revoked on the server. Signing out only forgets the token on the device. Email addresses are not verified, and there is no password reset yet.
- Without a domain there is no HTTPS: on the Wi-Fi address, passwords travel in clear text.
- Matchmaking and running duels live in memory on one instance. Scaling out needs an external broker and shared state.
- Plans and prices are shown as a preview; there are no payments.

See [docs/DEMO.md](docs/DEMO.md) for the stage script (in Russian).
