# Ball and Beam System Simulation

## Overview

This repository contains a MATLAB implementation of a **ball and beam system simulation**. The system simulates the dynamic behavior of a ball rolling on a beam that can rotate about its center, controlled using state-space feedback and pole placement techniques.

The simulation allows **interactive adjustments of the control poles**, enabling real-time modifications to the control strategy. It also visualizes both the physical system and the pole placement in the complex plane.

---

## Features

- **State-space modeling**: The system is modeled using linear state-space equations.
- **Pole placement control**: Uses MATLAB's `place` function for control system design.
- **Real-time visualization**: Animates the ball and beam motion and visualizes the control poles in the complex plane.
- **Interactive pole adjustment**: Drag poles in the complex plane to dynamically change the controller, and see the effects on the system in real-time.
- **Simulation termination**: Exit the simulation by pressing the `Escape` key.

---

## Files

- **`ball_and_beam_pole.m`**  
  The main MATLAB script that runs the simulation and provides the interactive visualization.

---

## Requirements

- MATLAB
- Control System Toolbox (for pole placement functionality)

---

### Interaction

- **Pole Adjustment**:  
  In the right-hand panel (complex plane visualization), click and drag the poles to adjust their positions. The system immediately updates the control law, and the effect of the new poles is reflected in the ball and beam animation.
- **Stop Simulation**:  
  Press the `Escape` key to exit the simulation.

---

## Simulation Details

- **Controller**:  
  A feedback controller is designed using pole placement to stabilize the ball and beam system.
- **Visualization**:  
  - **Left Panel**: Animation of the beam and the ball.
  - **Right Panel**: Pole locations in the complex plane. Adjusting the poles here directly affects the controller.

## Output
![ball_and_beam_output](https://github.com/user-attachments/assets/7b69d089-829a-414a-9423-a4cff048f482)
