# FOC FAST

A quick Flutter Web game for an Electrical Engineering demonstration. Drag the
stator-field arrow around a permanent-magnet rotor. Keep it roughly 90° ahead to
build speed; drift behind and the same field can brake or reverse the rotor. A
25-second run scores the highest **absolute** motor RPM.

The game deliberately uses a small educational model, not a complete PMSM or
field-oriented control simulation. The kart follows an oval track using a
signed-speed visual: reverse motor RPM moves it counterclockwise. It does not
claim a real vehicle speed.

The oval and top-down kart icon are drawn in
[lib/widgets/kart_track.dart](lib/widgets/kart_track.dart). The warm beige,
brown, and tile-like styling takes visual inspiration from the
[open-source 2048 Android port](https://github.com/uberspot/2048-android)
and its bundled original 2048 game.

## Install the game

Open the GitHub Pages URL in Chrome or Edge and choose **Install app** from the
browser menu. On Android Chrome, choose **Add to Home screen** if that is the
option shown. On iPhone or iPad, open the URL in Safari, tap **Share**, then
**Add to Home Screen**. Embedded in-app browsers may not offer installation,
so open the link in your device browser first. The app caches a basic offline
copy, while online visits fetch fresh deployments.

## Run locally

Install Flutter 3.29.1 or newer, then:

```sh
flutter pub get
flutter run -d chrome
```

The shared leaderboard is hosted in the FOC Supabase project. To connect a local
run to it:

```sh
flutter run -d chrome --dart-define=SUPABASE_URL=https://qiihwpffmkotsjausztc.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Use the public publishable key only. Never use a secret/service-role key in a web
build. Build-time defines are embedded in the public JavaScript bundle.

## Edit the wording

Change the landing page text in
[lib/content/home_copy.dart](lib/content/home_copy.dart). Edit the words between
quotes on the right of each `=`. Keep the names on the left, quotes, and semicolons.
Other page text lives in its corresponding file under `lib/screens/`. The app
tests find controls by stable keys, so changing visible wording does not break
deployment.

Push to `main` to publish the original version at
https://joaopedra-amdg.github.io/FOC-game/. Push to
`codex/lofi-cafe-palette` to publish the Lofi version at
https://joaopedra-amdg.github.io/FOC-game/lofi/. Push to
`codex/clash-royale-style` to publish the arena version at
https://joaopedra-amdg.github.io/FOC-game/royale/. Push to
`codex/simulation-display-style` to publish the investigation-style version at
https://joaopedra-amdg.github.io/FOC-game/simulation/. GitHub Actions checks
and rebuilds all four sites after any branch changes. Wait for the deployment
to finish, then refresh an already open browser tab. All versions use the same
Supabase leaderboard.

## Tuning the game

Edit [lib/config/game_physics_config.dart](lib/config/game_physics_config.dart).
It contains inertia, maximum torque, viscous and dry friction, simulation time
scale, starting RPM, display range, countdown, and run duration. Each constant
has a comment explaining its effect.

The model is `T = T_max sin(delta)` and
`J * d(omega)/dt = T - drag`. The signed angle is wrapped to `[-pi, pi)`.
Small time steps integrate velocity and rotor position. The renderer reads
that same simulated angle; it does not fake rotor movement.

## Shared leaderboard

The table and its policies have been created in the FOC Supabase project.
[supabase/schema.sql](supabase/schema.sql) records the setup for another project.
For local runs, copy the **publishable** key from Supabase's API settings and
supply it as the Dart define above. The GitHub repository has Actions variables
named `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` for its deployment workflow.

The table validates nicknames and score range, allows anonymous reads and
inserts, and has no update/delete policy. This is a casual demo leaderboard:
client-submitted scores can still be fabricated. The game remains playable
when Supabase is absent or unavailable.

## Verify

```sh
flutter analyze
flutter test
python tool/resize_icons.py
flutter build web --release --pwa-strategy=none
```

The physics tests cover zero, forward and reverse torque; forward acceleration;
deceleration and reversal; drag; angle wrapping; and frame-rate consistency.

## Repository and hosting

The included GitHub Actions workflow runs analysis/tests for all four branches,
builds Flutter Web with separate base paths, and deploys them together
to GitHub Pages on pushes to any of the branches.

The app, browser tab, and Apple touch icon use
[`web/favicon.png`](web/favicon.png). The web manifest uses 192px and 512px
copies made from that PNG. The deployment workflow regenerates both copies
on every push, so editing only `web/favicon.png` is enough for the live site.
The SVG remains an editable design source but is not loaded by the app.

The source is in [JoaoPedra-AMDG/FOC-game](https://github.com/JoaoPedra-AMDG/FOC-game).
GitHub Pages is built by the included workflow on pushes to `main`. Its URL is
`https://joaopedra-amdg.github.io/FOC-game/`. The currently hosted Sites version
is also available at `https://torque-chase-joao.pretty-mint-6178.chatgpt.site/`.

The workflow builds with `--base-href /FOC-game/`. If the repository has a
different name or uses a custom domain, change that value in
[.github/workflows/deploy.yml](.github/workflows/deploy.yml).

To update GitHub Pages later, commit and push to `main`; the workflow
redeploys after its checks pass. The separate Sites copy does not follow
GitHub pushes. Set the Supabase variables and rerun the workflow when you
are ready to enable shared scores.

For a demo-day QR code, generate one using the **final, tested HTTPS URL**, not
the local development address. For example:

```sh
npx qrcode -o foc-fast-qr.png https://joaopedra-amdg.github.io/FOC-game/
```

Print and test the QR code with a phone before the event.

## About us

The app links to [Joao Pedra and Oryon Choonoo's Group 01 profiles](https://dsl-masters-interest.netlify.app/projects/group-01/)
on the Digital Smart Lab site. Each link uses a browser text fragment to jump
to the selected profile where supported.
