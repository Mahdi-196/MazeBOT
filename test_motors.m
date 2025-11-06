%% MOTOR TEST SCRIPT
% Tests that your motors are working properly

fprintf('=== MOTOR TEST ===\n\n');

% Make sure brick is connected
if ~exist('brick', 'var')
    fprintf('Connecting to brick...\n');
    try
        clear brick
        fclose(instrfind);
        delete(instrfind);
    catch
    end
    brick = ConnectBrick('BALL');
end

brick.beep();
fprintf('Connected!\n\n');

%% TEST 1: Forward
fprintf('TEST 1: Moving FORWARD for 2 seconds\n');
fprintf('Watch the robot - both wheels should turn FORWARD\n');
input('Press Enter to start...', 's');

brick.MoveMotor('AB', 50);  % Motors A and B (not BC!)
pause(2);
brick.StopMotor('AB', 'Brake');

fprintf('✓ Forward test complete\n\n');
pause(1);

%% TEST 2: Backward
fprintf('TEST 2: Moving BACKWARD for 2 seconds\n');
fprintf('Watch the robot - both wheels should turn BACKWARD\n');
input('Press Enter to start...', 's');

brick.MoveMotor('AB', -50);  % Motors A and B
pause(2);
brick.StopMotor('AB', 'Brake');

fprintf('✓ Backward test complete\n\n');
pause(1);

%% TEST 3: Turn Right
fprintf('TEST 3: Turning RIGHT (in place)\n');
fprintf('Left wheel (B) forward, right wheel (A) backward\n');
input('Press Enter to start...', 's');

brick.MoveMotor('B', 50);   % Left forward
brick.MoveMotor('A', -50);  % Right backward
pause(1);
brick.StopMotor('AB', 'Brake');

fprintf('✓ Right turn test complete\n\n');
pause(1);

%% TEST 4: Turn Left
fprintf('TEST 4: Turning LEFT (in place)\n');
fprintf('Left wheel (B) backward, right wheel (A) forward\n');
input('Press Enter to start...', 's');

brick.MoveMotor('B', -50);  % Left backward
brick.MoveMotor('A', 50);   % Right forward
pause(1);
brick.StopMotor('AB', 'Brake');

fprintf('✓ Left turn test complete\n\n');
pause(1);

%% TEST 5: Square Pattern
fprintf('TEST 5: Drive in a SQUARE\n');
fprintf('Robot will move forward, turn right, repeat 4 times\n');
input('Press Enter to start...', 's');

for i = 1:4
    % Forward
    fprintf('Side %d: Moving forward\n', i);
    brick.MoveMotor('AB', 50);
    pause(1.5);

    % Stop
    brick.StopMotor('AB', 'Brake');
    pause(0.3);

    % Turn right
    fprintf('Side %d: Turning right\n', i);
    brick.MoveMotor('B', 50);   % Left forward
    brick.MoveMotor('A', -50);  % Right backward
    pause(0.5);  % Adjust if not 90 degrees

    % Stop
    brick.StopMotor('AB', 'Brake');
    pause(0.3);
end

fprintf('✓ Square pattern complete\n\n');

%% DONE
fprintf('========================================\n');
fprintf('ALL MOTOR TESTS COMPLETE!\n');
fprintf('========================================\n');
fprintf('\nDid all tests work correctly?\n');
fprintf('- If YES: Motors are working! Try maze navigation.\n');
fprintf('- If NO: Check motor connections and power.\n\n');

brick.beep();
pause(0.3);
brick.beep();
