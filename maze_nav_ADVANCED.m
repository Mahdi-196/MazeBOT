%% ADVANCED MAZE NAVIGATION - Uses Head Scanning!
% This version rotates the head to scan for the best path
% Motors: B (left), A (right), D (head)
% Sensors: 2 (ultrasonic), 1 (color)

%% CONFIGURATION
FORWARD_SPEED = 40;
TURN_SPEED = 35;
SCAN_SPEED = 30;
OBSTACLE_DISTANCE = 25;
RUNTIME_MINUTES = 5;

%% CONNECT
fprintf('========================================\n');
fprintf('ADVANCED MAZE NAVIGATION - Head Scanning\n');
fprintf('========================================\n');

if ~exist('brick', 'var')
    try
        clear brick
        fclose(instrfind);
        delete(instrfind);
    catch
    end
    brick = ConnectBrick('BALL');
end

fprintf('✓ Connected!\n');
brick.beep();

% Center head
fprintf('Initializing head position...\n');
brick.MoveMotorAngleRel('D', 20, 0, 'Brake');
pause(0.5);

fprintf('\nPlace robot at maze entrance\n');
input('Press Enter when ready...', 's');

fprintf('Starting in: 3... ');
brick.beep();
pause(1);
fprintf('2... ');
pause(1);
fprintf('1... GO!\n\n');
brick.beep();

%% NAVIGATION
start_time = tic;

try
    while toc(start_time) < (RUNTIME_MINUTES * 60)

        % Look straight ahead
        brick.MoveMotorAngleRel('D', SCAN_SPEED, 0, 'Brake');
        pause(0.3);
        dist_center = brick.UltrasonicDist(2);

        if dist_center < OBSTACLE_DISTANCE
            % OBSTACLE AHEAD - Need to scan for best direction
            fprintf('[%.1fs] Obstacle ahead (%.1fcm) - Scanning...\n', ...
                    toc(start_time), dist_center);

            % Stop moving
            brick.StopMotor('AB', 'Brake');
            pause(0.2);

            % Look right (turn head right ~45 degrees)
            brick.MoveMotorAngleRel('D', SCAN_SPEED, -60, 'Brake');
            brick.WaitForMotor('D');
            pause(0.2);
            dist_right = brick.UltrasonicDist(2);
            fprintf('  Right: %.1f cm\n', dist_right);

            % Look left (turn head left ~90 degrees from right)
            brick.MoveMotorAngleRel('D', SCAN_SPEED, 120, 'Brake');
            brick.WaitForMotor('D');
            pause(0.2);
            dist_left = brick.UltrasonicDist(2);
            fprintf('  Left: %.1f cm\n', dist_left);

            % Return head to center
            brick.MoveMotorAngleRel('D', SCAN_SPEED, -60, 'Brake');
            brick.WaitForMotor('D');
            pause(0.2);

            % Decide which way to turn
            if dist_right > dist_left && dist_right > OBSTACLE_DISTANCE
                % Turn right
                fprintf('  Decision: Turning RIGHT\n');
                brick.MoveMotor('B', TURN_SPEED);
                brick.MoveMotor('A', -TURN_SPEED);
                pause(0.5);

            elseif dist_left > OBSTACLE_DISTANCE
                % Turn left
                fprintf('  Decision: Turning LEFT\n');
                brick.MoveMotor('B', -TURN_SPEED);
                brick.MoveMotor('A', TURN_SPEED);
                pause(0.5);

            else
                % Both blocked - turn around (180 degrees)
                fprintf('  Decision: TURNING AROUND\n');
                brick.MoveMotor('B', TURN_SPEED);
                brick.MoveMotor('A', -TURN_SPEED);
                pause(1.0);  % Double the turn time
            end

            % Stop after turn
            brick.StopMotor('AB', 'Brake');
            pause(0.2);

        else
            % PATH CLEAR - Move forward
            brick.MoveMotor('AB', FORWARD_SPEED);
        end

        pause(0.2);
    end

catch ME
    fprintf('\n!!! ERROR: %s\n', ME.message);
end

%% CLEANUP
fprintf('\n========================================\n');
fprintf('Navigation Complete!\n');
fprintf('Total time: %.1f seconds\n', toc(start_time));
fprintf('========================================\n');

brick.StopMotor('ABD', 'Coast');
brick.beep();
pause(0.3);
brick.beep();
