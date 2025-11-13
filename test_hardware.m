%% HARDWARE DIAGNOSTIC TEST
% Test head motor (D) and ultrasonic sensor (Port 2)

fprintf('========================================\n');
fprintf('HARDWARE DIAGNOSTIC TEST\n');
fprintf('========================================\n');

if ~exist('brick', 'var')
    brick = ConnectBrick('BALL');
end

fprintf('Connected!\n\n');

%% TEST 1: Ultrasonic Sensor
fprintf('TEST 1: Ultrasonic Sensor on Port 2\n');
fprintf('Reading distance 5 times...\n');
for i = 1:5
    d = brick.UltrasonicDist(2);
    fprintf('  Reading %d: %d cm\n', i, d);
    pause(0.5);
end
fprintf('\n');

%% TEST 2: Head Motor Position
fprintf('TEST 2: Head Motor (D) Current Position\n');
angle = brick.GetMotorAngle('D');
fprintf('  Current angle: %d degrees\n\n', angle);

%% TEST 3: Reset Head Motor
fprintf('TEST 3: Resetting Head Motor Angle to 0\n');
brick.ResetMotorAngle('D');
pause(0.5);
angle = brick.GetMotorAngle('D');
fprintf('  After reset: %d degrees\n\n', angle);

%% TEST 4: Turn Head Left
fprintf('TEST 4: Turning head LEFT 90 degrees\n');
fprintf('  Command: MoveMotorAngleAbs(D, 50, 90, Brake)\n');
brick.MoveMotorAngleAbs('D', 50, 90, 'Brake');
pause(2.0);
angle = brick.GetMotorAngle('D');
fprintf('  Target: 90 degrees\n');
fprintf('  Actual: %d degrees\n', angle);
if abs(angle - 90) < 10
    fprintf('  ✓ SUCCESS - Head moved!\n');
else
    fprintf('  ✗ FAILED - Head did not move to target\n');
end
fprintf('\n');

%% TEST 5: Turn Head Right
fprintf('TEST 5: Turning head RIGHT -90 degrees\n');
fprintf('  Command: MoveMotorAngleAbs(D, 50, -90, Brake)\n');
brick.MoveMotorAngleAbs('D', 50, -90, 'Brake');
pause(2.0);
angle = brick.GetMotorAngle('D');
fprintf('  Target: -90 degrees\n');
fprintf('  Actual: %d degrees\n', angle);
if abs(angle + 90) < 10
    fprintf('  ✓ SUCCESS - Head moved!\n');
else
    fprintf('  ✗ FAILED - Head did not move to target\n');
end
fprintf('\n');

%% TEST 6: Return to Center
fprintf('TEST 6: Returning head to CENTER (0 degrees)\n');
brick.MoveMotorAngleAbs('D', 50, 0, 'Brake');
pause(2.0);
angle = brick.GetMotorAngle('D');
fprintf('  Target: 0 degrees\n');
fprintf('  Actual: %d degrees\n', angle);
fprintf('\n');

%% TEST 7: Try Using Relative Movement Instead
fprintf('TEST 7: Testing RELATIVE movement (MoveMotorAngleRel)\n');
fprintf('  Turning 90 degrees relative...\n');
brick.MoveMotorAngleRel('D', 50, 90, 'Brake');
pause(2.0);
angle = brick.GetMotorAngle('D');
fprintf('  Angle after relative turn: %d degrees\n', angle);
fprintf('\n');

%% TEST 8: Try Different Motor Port
fprintf('TEST 8: Is motor actually on Port D?\n');
fprintf('  Trying to move motor on port C instead...\n');
brick.MoveMotorAngleRel('C', 50, 90, 'Brake');
pause(2.0);
angle_c = brick.GetMotorAngle('C');
fprintf('  Motor C angle: %d degrees\n', angle_c);
fprintf('\n');

%% SUMMARY
fprintf('========================================\n');
fprintf('DIAGNOSTIC SUMMARY\n');
fprintf('========================================\n');
fprintf('Ultrasonic sensor readings: Check if values were > 0\n');
fprintf('Head motor (D) movement: Check if angles changed\n');
fprintf('\n');
fprintf('If motor D did NOT move, check:\n');
fprintf('  1. Is motor plugged into Port D on the brick?\n');
fprintf('  2. Is the motor cable fully inserted?\n');
fprintf('  3. Try different motor port (A, B, C)?\n');
fprintf('\n');
fprintf('If ultrasonic reads 0cm always, check:\n');
fprintf('  1. Is sensor plugged into Port 2?\n');
fprintf('  2. Is sensor pointing forward (not at ground)?\n');
fprintf('  3. Try different sensor port (1, 3, 4)?\n');
fprintf('========================================\n');

brick.StopMotor('ABCD', 'Coast');
