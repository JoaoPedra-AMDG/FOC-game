# FOC FAST field lab

Public game: https://joaopedra-amdg.github.io/FOC-game/fields/

Branch: `codex/stator-transform-lab`. The entry point uses the main game's home
screen, controls, timed runs, sensorless mode, results and leaderboard. In the run
screen the kart track is replaced with three phase field vectors and their gold
resultant (top left), and a rolling current-versus-time chart with live values (top
right), updated from the dragged field arrow. The resultant uses the exact same
screen orientation as the motor control. Two separate red north / blue south
glows follow the resultant on the stator rim. They are clipped to the stator
annulus, so no colour spills into the rotor interior.

The game uses a fixed 1 A peak ideal current command with no hardware measurements
or inverter model. Its electrical angles follow the main game's clockwise screen
convention; positive q corresponds to positive game torque. The model assumes
balanced sinusoidal phases, zero sequence = 0 and amplitude-invariant transforms.
In sensorless mode, the panel shows stationary alpha/beta components until the
rotor is fully revealed at 300 RPM, to avoid exposing its hidden angle via d/q.
The chart records actual commanded phase currents against active game time.
It retains a rolling three-second window, resets for each run and stays flat
when the field command is held still. No predicted sine cycle is plotted.
The phase field arrows include 2/3 scaling so their sum equals the control.

Inverse Park converts d/q commands to alpha/beta; inverse Clarke produces abc.
Phase field arrows include the 2/3 scaling so they sum to the resultant vector.
The original standalone `TransformLab` screen remains available in source as an
educational reference; it is not the app entry point for this game variant.

Equation references:
- https://www.microchip.com/en-us/products/fpgas-and-plds/ip-core-tools/foc-transforms
- https://onlinedocs.microchip.com/oxy/GUID-69278EBA-9F00-4CEE-8103-2998236856BD-en-US-2/GUID-F60C965F-09E5-49C9-8BF3-F21E30DADBDB.html

GitHub Pages builds this branch into `/FOC-game/fields/` alongside the existing
main, Lofi, arena and simulation versions. The deployment workflow is synchronized
across the five branches so a push to any game branch preserves all public URLs.
The original private Sites preview is a separate earlier preview; use the public
GitHub Pages link above to share this version.

## Figure layout

The play area gives the figure row and motor equal heights. Figure panels contain
no visible text or legends and use their full available area for the vector sum
and three-second current history. Accessible descriptions remain available to
screen readers. The RPM, torque, angle and timer stay outside the figure blocks.
