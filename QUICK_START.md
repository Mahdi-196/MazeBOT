# QUICK START GUIDE
## Get Your Robot Navigating the Maze in 3 Steps!

---

## Step 1: Calibrate Your Robot (5-10 minutes)

Before running the maze, test that everything works:

```matlab
% In MATLAB:
run('connect_robot.m')
run('calibrate_robot.m')
```

Use the calibration menu to:
- Test motors work correctly
- Test turning (make sure 90-degree turns are accurate)
- Test ultrasonic sensor readings
- Test wall following along a straight wall

**Important**: If turns aren't 90 degrees, note the time needed and adjust `TURN_TIME` in the scripts!

---

## Step 2: Run Autonomous Navigation

Once calibrated, you're ready to navigate the maze!

### Option A: Full Navigation (Recommended)
```matlab
run('autonomous_maze_navigation.m')
```

### Option B: Simple Navigation (Backup)
```matlab
run('simple_maze_navigation.m')
```

**Before starting:**
1. Place robot at maze entrance
2. Make sure the right wall is on the robot's RIGHT side
3. Press Enter when the script prompts you
4. Step back and let it navigate!

---

## Step 3: Record and Submit

### Record Your Video
- Use phone/camera to record the entire run
- Start recording BEFORE the robot starts moving
- Show the full maze navigation
- Upload to YouTube

### Submit Your Milestone
See `SUBMISSION_GUIDE.md` for detailed submission instructions.

You need:
1. Team photo with robot
2. Google Drive link to your code
3. YouTube link to your video

---

## Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| Robot won't connect | Run `fix_connection.m` or restart Bluetooth |
| Robot veers left/right | One motor may be faster - adjust speeds in code |
| Robot hits walls | Decrease `FORWARD_SPEED` (try 25 instead of 35) |
| Robot turns too much | Decrease `TURN_TIME` (try 0.4 or 0.5) |
| Robot turns too little | Increase `TURN_TIME` (try 0.7 or 0.8) |
| Sensor not working | Check it's plugged into Port 2 |

---

## Files Created For You

| File | Purpose |
|------|---------|
| `autonomous_maze_navigation.m` | **Main script** - Wall following algorithm |
| `simple_maze_navigation.m` | Simpler obstacle avoidance approach |
| `calibrate_robot.m` | Test and tune your robot |
| `SUBMISSION_GUIDE.md` | Complete submission instructions |
| `QUICK_START.md` | This file! |

---

## Tips for Best Results

1. **Test on a simple path first** - Don't start with the full maze
2. **Tune the parameters** - Adjust speeds and distances for your maze
3. **Record multiple runs** - Submit your best attempt
4. **Check battery level** - Low battery = weak motors = poor navigation
5. **Stable sensor mount** - Make sure ultrasonic sensor doesn't wobble

---

## Parameters You Can Adjust

In `autonomous_maze_navigation.m`:

```matlab
DESIRED_WALL_DISTANCE = 15;  % Distance to keep from wall (try 10-25)
FORWARD_SPEED = 30;           % How fast to go (try 20-40)
TURN_SPEED = 25;              % Turn speed (try 20-35)
```

In `simple_maze_navigation.m`:

```matlab
FORWARD_SPEED = 35;           % How fast to go
TURN_TIME = 0.6;              % How long to turn (critical!)
OBSTACLE_DISTANCE = 20;       % When to turn (try 15-30)
```

---

## Need Help?

1. Read `SUBMISSION_GUIDE.md` for detailed instructions
2. Use `calibrate_robot.m` to test individual components
3. Try the simpler `simple_maze_navigation.m` if the main script doesn't work
4. Check that your hardware matches the port configuration in the code

---

**You've got this! Good luck with your maze navigation!** 🤖🎯
