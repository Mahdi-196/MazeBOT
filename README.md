# MazeBOT - Autonomous Maze Navigation
## Project Spyn Milestone

A LEGO Mindstorms EV3 robot that autonomously navigates mazes using wall-following algorithms.

---

## Quick Start

1. **Calibrate**: `run('calibrate_robot.m')`
2. **Navigate**: `run('autonomous_maze_navigation.m')`
3. **Record & Submit**: See `SUBMISSION_GUIDE.md`

Full instructions in `QUICK_START.md`

---

## Files Overview

### Main Navigation Scripts
- **`autonomous_maze_navigation.m`** - Advanced wall-following navigation (RECOMMENDED)
- **`simple_maze_navigation.m`** - Simpler obstacle avoidance approach
- **`calibrate_robot.m`** - Test and tune robot before maze run

### Documentation
- **`QUICK_START.md`** - Fast guide to get running
- **`SUBMISSION_GUIDE.md`** - Complete submission instructions
- **`README.md`** - This file

### Connection Scripts
- `connect_robot.m` - Quick connect to EV3
- `ConnectBrickBT.m` - Bluetooth connection
- `fix_connection.m` - Fix connection issues

---

## Hardware Requirements

- **Motors**: Ports B (left) and C (right)
- **Ultrasonic Sensor**: Port 2
- **Touch Sensor** (optional): Port 1
- **EV3 Brick**: Named 'BALL'

---

## Algorithm

Uses **Right-Hand Wall Following**:
1. Keep right wall at constant distance
2. If no wall → turn right
3. If too close → turn left
4. Otherwise → move forward while adjusting

---

## How It Works

The robot uses sensor feedback to make real-time decisions:
- Ultrasonic sensor measures distance to walls
- Adjusts motor speeds to maintain optimal wall distance
- Handles corners, dead ends, and open spaces
- Continues until maze exit or timeout

---

## Project Team

Add your team members here!

---

## License

Educational project for Project Spyn course 
