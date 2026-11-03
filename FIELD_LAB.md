# FOC FAST field lab

Preview: https://foc-fast-field-lab.pretty-mint-6178.chatgpt.site

Branch: `codex/stator-transform-lab`. The entry point uses the main game's home
screen, controls, timed runs, sensorless mode, results and leaderboard. In the run
screen the kart track is replaced with three phase field vectors and their gold
resultant (top left), and three sinusoidal phase currents with live values (top
right), updated from the dragged field arrow. The resultant uses the exact same
screen orientation as the motor control. A transparent red north / blue south
stator magnet follows that resultant behind the actual rotor.

The game uses a fixed 1 A peak ideal current command with no hardware measurements
or inverter model. Its electrical angles follow the main game's clockwise screen
convention; positive q corresponds to positive game torque. The model assumes
balanced sinusoidal phases, zero sequence = 0 and amplitude-invariant transforms.
In sensorless mode, the panel shows stationary alpha/beta components until the
rotor is fully revealed at 300 RPM, to avoid exposing its hidden angle via d/q.
The sinusoid chart spans a full 0–360 degree commanded field cycle, rather than
time. Its cursor and three dots mark the exact current commands. The phase field
arrows include 2/3 scaling, so their vector sum equals the control arrow.

Inverse Park converts d/q commands to alpha/beta; inverse Clarke produces abc.
Phase field arrows include the 2/3 scaling so they sum to the resultant vector.
The original standalone `TransformLab` screen remains available in source as an
educational reference; it is not the app entry point for this game variant.

Equation references:
- https://www.microchip.com/en-us/products/fpgas-and-plds/ip-core-tools/foc-transforms
- https://onlinedocs.microchip.com/oxy/GUID-69278EBA-9F00-4CEE-8103-2998236856BD-en-US-2/GUID-F60C965F-09E5-49C9-8BF3-F21E30DADBDB.html

This branch has its own Sites preview. The existing GitHub Pages workflows are
unchanged. To refresh the preview after editing this branch, rebuild Flutter Web
with base href `/` and republish the matching Sites source and static build.
