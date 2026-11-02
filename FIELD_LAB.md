# FOC FAST field lab

Preview: https://joaopedra-amdg.github.io/FOC-game/transforms/

Branch: `codex/stator-transform-lab`. The branch entry point opens a continuous,
interactive field lab instead of the kart game. The original game remains on main.

Drag the stator vector, change d/q current commands, scrub the electrical rotor
angle, or animate rotation. Current values are ideal commands in amperes, with no
hardware measurements or inverter model. Positive electrical angles rotate
counterclockwise from phase A / alpha. The model assumes a balanced sinusoidal
two-pole motor, zero sequence = 0 and amplitude-invariant transforms.

Inverse Park converts d/q commands to alpha/beta; inverse Clarke produces abc.
Phase field arrows include the 2/3 scaling so they sum to the resultant vector.
The forward Clarke/Park formulas show how sensor measurements would return to dq.
The coil sketch shows phase magnetic axes, not a physical slot winding design.

Equation references:
- https://www.microchip.com/en-us/products/fpgas-and-plds/ip-core-tools/foc-transforms
- https://onlinedocs.microchip.com/oxy/GUID-69278EBA-9F00-4CEE-8103-2998236856BD-en-US-2/GUID-F60C965F-09E5-49C9-8BF3-F21E30DADBDB.html

The shared Pages workflow builds this branch into `/transforms/` alongside all
existing sites. Keep that checkout/build/copy step when changing deployment.
