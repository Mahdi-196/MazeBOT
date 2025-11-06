%% SIMPLE AUTONOMOUS MAZE NAVIGATION
% A simplified version using basic obstacle avoidance
% Good for beginners or as a backup approach
%
% HARDWARE: Motors on B & C, Ultrasonic on Port 2

%% CONFIGURATION
FORWARD_SPEED = 35;
TURN_TIME = 0.6;        % Seconds to turn 90 degrees
OBSTACLE_DISTANCE = 20;  % Stop if obstacle closer than this (cm)
RUNTIME_SECONDS = 180;   % 3 minutes

%% CONNECT
fprintf('=== SIMPLE MAZE NAVIGATION ===\n');
try
    clear brick
    fclose(instrfind);
    delete(instrfind);
catch
end

brick = ConnectBrick('BALL');
fprintf('Connected!\n');
brick.beep();

% Countdown
fprintf('Starting in: 3... ');
pause(1);
fprintf('2... ');
pause(1);
fprintf('1... GO!\n');
brick.beep();

%% NAVIGATE
start_time = tic;

try
    while toc(start_time) < RUNTIME_SECONDS

        % Check distance ahead
        distance = brick.UltrasonicDist(2);

        if distance < OBSTACLE_DISTANCE
            % OBSTACLE DETECTED - Turn right
            fprintf('Obstacle at %.1f cm - Turning right\n', distance);

            % Stop
            brick.StopMotor('BC', 'Brake');
            pause(0.2);

            % Turn right (90 degrees)
            brick.MoveMotor('B', FORWARD_SPEED);
            brick.MoveMotor('C', -FORWARD_SPEED);
            pause(TURN_TIME);

            % Stop after turn
            brick.StopMotor('BC', 'Brake');
            pause(0.2);

        else
            % PATH CLEAR - Move forward
            brick.MoveMotor('BC', FORWARD_SPEED);
        end

        pause(0.1);  % Small delay
    end

catch ME
    fprintf('Error: %s\n', ME.message);
end

%% STOP
fprintf('\nNavigation complete!\n');
brick.StopMotor('BC', 'Coast');
brick.beep();
pause(0.3);
brick.beep();
