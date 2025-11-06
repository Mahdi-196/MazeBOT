# Project Spyn - Maze Navigation Milestone
## Submission Guide

This document will help you complete and submit your maze navigation milestone.

---

## Deliverables Checklist

### 1. Team Photo with Robot Vehicle
- [ ] Take a photo of your entire team with the robot
- [ ] Ensure the robot is clearly visible
- [ ] Make sure all team members are in the photo
- [ ] Save as `team_photo.jpg` or similar

### 2. MATLAB Code (Already Done!)
Your autonomous navigation code is ready:
- **Main Script**: `autonomous_maze_navigation.m`
- **Alternative (simpler)**: `simple_maze_navigation.m` (being created)

**To share your code:**
1. Create a Google Drive folder named "MazeBOT_Code"
2. Upload all `.m` files from this project
3. Set sharing to "Anyone with the link can view"
4. Copy the sharing link

**Required files to upload:**
- `autonomous_maze_navigation.m` (main autonomous script)
- `connect_robot.m` (connection script)
- `ConnectBrickBT.m` (Bluetooth connection)
- Any other custom scripts you created

### 3. Video Demonstration
Record a video showing your robot autonomously navigating the maze.

**Video Requirements:**
- Show the robot starting position
- Show the entire maze navigation from start to finish
- Robot must operate AUTONOMOUSLY (no remote control)
- Clearly show the robot completing the maze
- Recommended length: 1-3 minutes

**Steps to create and upload:**
1. Record video on your phone/camera
2. Upload to YouTube (can be unlisted)
3. Title: "MazeBOT - Autonomous Maze Navigation - [Team Name]"
4. Add description with team members' names
5. Copy the YouTube link

---

## How to Run the Autonomous Navigation

### Method 1: Using the Main Script (Recommended)

1. **Connect to the robot:**
   ```matlab
   run('connect_robot.m')
   ```

2. **Run autonomous navigation:**
   ```matlab
   run('autonomous_maze_navigation.m')
   ```

3. **Place robot at maze entrance and let it run!**

### Method 2: Step-by-Step

```matlab
% In MATLAB, run these commands:

% 1. Connect
brick = ConnectBrick('BALL');

% 2. Run the autonomous script
autonomous_maze_navigation

% 3. Watch your robot navigate!
```

---

## Hardware Setup

Make sure your robot is configured correctly:

### Required Sensors and Motors:
- **Motor B**: Left wheel (must be connected to port B)
- **Motor C**: Right wheel (must be connected to port C)
- **Ultrasonic Sensor**: Port 2 (measures distance to walls)
- **Touch Sensor** (optional): Port 1 (detects collisions)

### If Your Configuration is Different:
Edit `autonomous_maze_navigation.m` and change the port numbers in the code.

---

## Troubleshooting

### Robot won't connect
- Make sure Bluetooth is on
- Check the robot name is 'BALL' (or update in the script)
- Try running `fix_connection.m`

### Robot doesn't navigate well
- Adjust `DESIRED_WALL_DISTANCE` in the script (try values 10-25)
- Adjust `FORWARD_SPEED` (try values 20-40)
- Make sure sensors are properly mounted
- Calibrate on a test wall before running in maze

### Robot gets stuck
- Decrease `FORWARD_SPEED`
- Increase `DISTANCE_TOLERANCE`
- Check that wheels aren't slipping
- Ensure maze walls are high enough for sensors

---

## Submission Template

When submitting, include:

```
PROJECT SPYN - MAZE NAVIGATION MILESTONE
Team: [Your Team Name]
Date: [Date]

1. Team Photo:
   [Attach or link to photo]

2. MATLAB Code:
   Google Drive Link: [Your Google Drive link]

3. Video Demonstration:
   YouTube Link: [Your YouTube link]

Team Members:
- [Name 1]
- [Name 2]
- [Name 3]
- [etc.]
```

---

## Tips for Success

1. **Test in a simple environment first**
   - Start with just two walls
   - Make sure basic wall following works
   - Then try the full maze

2. **Record multiple attempts**
   - You can edit the best run for submission
   - Keep trying if first attempts don't work perfectly

3. **Tune the parameters**
   - Experiment with speed and distance settings
   - What works for one maze might need adjustment for another

4. **Have fun!**
   - This is the exciting part where you see it all work!
   - Celebrate when it successfully navigates!

---

## Late Submission Note

From the project requirements:
- This milestone can be submitted late for half credit
- Last day to submit: Evening before final demonstration
- Plan ahead to avoid last-minute issues!

---

Good luck! 🤖
