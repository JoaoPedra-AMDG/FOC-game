# Torque Chase

A quick Flutter Web game for an Electrical Engineering demonstration. Drag the
stator-field arrow around a permanent-magnet rotor. Keep it roughly 90° ahead to
build speed; drift behind and the same field can brake or reverse the rotor. A
25-second run scores the highest **absolute** motor RPM.

The game deliberately uses a small educational model, not a complete PMSM or
field-oriented control simulation. The kart track is a signed-speed visual:
reverse motor RPM moves the markings in the opposite direction. It does not
claim a real vehicle speed.

## Run locally

Install Flutter 3.29.1 or newer, then:

```sh
flutter pub get
flutter run -d chrome
```

The game runs without a backend. To include the shared leaderboard locally:

```sh
flutter run -d chrome --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Use the public publishable key only. Never use a secret/service-role key in a web
build. Build-time defines are embedded in the public JavaScript bundle.

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

1. Create a Supabase project.
2. Run [supabase/schema.sql](supabase/schema.sql) once in its SQL editor.
3. Copy the project URL and **publishable** key from Supabase's API
   settings. Supply them as the two Dart defines above.
4. For GitHub Pages, add repository **Actions variables** named
   `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`, then rerun the deploy workflow.

The table validates nicknames and score range, allows anonymous reads and
inserts, and has no update/delete policy. This is a casual demo leaderboard:
client-submitted scores can still be fabricated. The game remains playable
when Supabase is absent or unavailable.

## Verify

```sh
flutter analyze
flutter test
flutter build web --release
```

The physics tests cover zero, forward and reverse torque; forward acceleration;
deceleration and reversal; drag; angle wrapping; and frame-rate consistency.

## Repository and hosting

The included GitHub Actions workflow runs analysis/tests, builds Flutter Web,
and deploys `build/web` to GitHub Pages on pushes to `main`.

1. Create a public GitHub repository named `torque-chase`.
2. From this project directory, initialize Git if needed, set that repository
   as `origin`, and push `main`.
3. In the repository's **Settings → Pages**, choose **GitHub Actions** as the
   build and deployment source.
4. After the workflow succeeds, open
   `https://YOUR_GITHUB_USERNAME.github.io/torque-chase/`.

The workflow builds with `--base-href /torque-chase/`. If the repository has a
different name or uses a custom domain, change that value in
[.github/workflows/deploy.yml](.github/workflows/deploy.yml).

To update the site later, commit and push to `main`; the workflow redeploys
it. Set the Supabase variables and rerun the workflow when you are ready to
enable shared scores.

For a demo-day QR code, generate one using the **final, tested HTTPS URL**, not
the local development address. For example:

```sh
npx qrcode -o torque-chase-qr.png https://YOUR_GITHUB_USERNAME.github.io/torque-chase/
```

Print and test the QR code with a phone before the event.

## About us

The app links to [Joao Pedra and Oryon Choonoo's Group 01 profiles](https://dsl-masters-interest.netlify.app/projects/group-01/)
on the Digital Smart Lab site. Each link uses a browser text fragment to jump
to the selected profile where supported.
