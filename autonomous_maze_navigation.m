%% AUTONOMOUS MAZE NAVIGATION SCRIPT
% Project Spyn - Maze Navigation Milestone
% This script autonomously navigates a maze using right-hand wall following
%
% HARDWARE SETUP REQUIRED:
% - Motors: Port B (left wheel), Port C (right wheel)
% - Ultrasonic Sensor: Port 2 (measures distance to right wall)
% - Touch Sensor: Port 1 (optional, for collision detection)
%
% ALGORITHM: Right-Hand Wall Following
% The robot keeps the right wall at a constant distance and follows it
% through the maze until it reaches the exit.

%% CONFIGURATION PARAMETERS
% Adjust these based on your maze and robot
DESIRED_WALL_DISTANCE = 15;  % Target distance from right wall (cm)
DISTANCE_TOLERANCE = 3;       % Acceptable deviation from target (cm)
FORWARD_SPEED = 30;           % Base motor speed (0-100)
TURN_SPEED = 25;              % Speed during turns
MAX_DISTANCE = 50;            % Distance considered "no wall" (cm)
MIN_DISTANCE = 5;             % Too close to wall (cm)
RUNTIME_MINUTES = 5;          % Maximum runtime before auto-stop

%% SETUP AND INITIALIZATION
fprintf('========================================\n');
fprintf('AUTONOMOUS MAZE NAVIGATION - STARTING\n');
fprintf('========================================\n');

% Clean up any existing connections
try
    clear brick
    fclose(instrfind);
    delete(instrfind);
catch
    % Ignore errors if nothing to clear
end

% Connect to EV3 brick
fprintf('Connecting to EV3 brick (BALL)...\n');
brick = ConnectBrick('BALL');
fprintf('✓ Connected successfully!\n');

% Test connection with beep
brick.beep();
pause(0.5);

% Reset motor angles
brick.ResetMotorAngle('B');
brick.ResetMotorAngle('C');
fprintf('✓ Motors initialized\n');

% Countdown before starting
fprintf('\nStarting autonomous navigation in:\n');
for i = 3:-1:1
    fprintf('%d...\n', i);
    brick.beep();
    pause(1);
end
fprintf('GO!\n\n');

% Start timer
start_time = tic;
max_runtime = RUNTIME_MINUTES * 60; % Convert to seconds

%% MAIN NAVIGATION LOOP
try
    iteration = 0;
    while toc(start_time) < max_runtime
        iteration = iteration + 1;

        % Read ultrasonic sensor (distance to right wall)
        distance = brick.UltrasonicDist(2);

        % Read touch sensor (collision detection) - optional
        % touch = brick.TouchPressed(1);

        % Display status every 10 iterations
        if mod(iteration, 10) == 0
            fprintf('Time: %.1fs | Distance: %.1f cm\n', toc(start_time), distance);
        end

        %% DECISION LOGIC - Right-Hand Wall Following

        if distance > MAX_DISTANCE
            % NO WALL ON RIGHT - Turn right to follow wall
            fprintf('No wall detected - Turning right\n');
            brick.StopMotor('BC', 'Brake');
            pause(0.1);

            % Turn right: left motor forward, right motor backward
            brick.MoveMotor('B', TURN_SPEED);
            brick.MoveMotor('C', -TURN_SPEED);
            pause(0.5);  % Turn duration

        elseif distance < MIN_DISTANCE
            % TOO CLOSE TO WALL - Turn left to avoid collision
            fprintf('Too close to wall - Turning left\n');
            brick.StopMotor('BC', 'Brake');
            pause(0.1);

            % Turn left: right motor forward, left motor backward
            brick.MoveMotor('B', -TURN_SPEED);
            brick.MoveMotor('C', TURN_SPEED);
            pause(0.5);  % Turn duration

        elseif distance < DESIRED_WALL_DISTANCE - DISTANCE_TOLERANCE
            % SLIGHTLY TOO CLOSE - Gentle turn left
            left_speed = FORWARD_SPEED * 0.7;
            right_speed = FORWARD_SPEED;
            brick.MoveMotor('B', left_speed);
            brick.MoveMotor('C', right_speed);

        elseif distance > DESIRED_WALL_DISTANCE + DISTANCE_TOLERANCE
            % SLIGHTLY TOO FAR - Gentle turn right
            left_speed = FORWARD_SPEED;
            right_speed = FORWARD_SPEED * 0.7;
            brick.MoveMotor('B', left_speed);
            brick.MoveMotor('C', right_speed);

        else
            % PERFECT DISTANCE - Move straight
            brick.MoveMotor('BC', FORWARD_SPEED);
        end

        % Small delay to prevent sensor reading too fast
        pause(0.05);
    end

    fprintf('\n========================================\n');
    fprintf('Maximum runtime reached - Stopping\n');
    fprintf('========================================\n');

catch ME
    % Error handling
    fprintf('\n!!! ERROR OCCURRED !!!\n');
    fprintf('Error: %s\n', ME.message);
end

%% CLEANUP
fprintf('\nStopping motors...\n');
brick.StopMotor('BC', 'Coast');
brick.beep();
pause(0.2);
brick.beep();

fprintf('\n========================================\n');
fprintf('Navigation Complete!\n');
fprintf('Total Runtime: %.1f seconds\n', toc(start_time));
fprintf('========================================\n');

% Optionally disconnect
% DisconnectBrick(brick);
