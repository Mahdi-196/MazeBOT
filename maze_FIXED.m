%% MAZE NAVIGATION - FIXED FOR REVERSED MOTORS
% If your robot goes backward instead of forward, use this version!
% Motors: B (left), A (right), D (head)
% Sensors: 2 (ultrasonic), 1 (color)

%% CONFIGURATION
FORWARD_SPEED = -40;     % NEGATIVE because motors are reversed!
TURN_SPEED = 40;
OBSTACLE_DISTANCE = 25;  % Turn if obstacle closer than this (cm)
MOVE_FORWARD_TIME = 1.0; % Move forward for this long
RUNTIME_MINUTES = 5;

%% CONNECT
fprintf('========================================\n');
fprintf('MAZE NAVIGATION - MOTOR FIX\n');
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

% Center the head
fprintf('Centering head...\n');
brick.MoveMotorAngleRel('D', 20, 0, 'Brake');
pause(0.5);

fprintf('\nPlace robot at maze entrance\n');
input('Press Enter when ready...', 's');

fprintf('Starting: 3... ');
brick.beep();
pause(1);
fprintf('2... ');
brick.beep();
pause(1);
fprintf('1... GO!\n\n');
brick.beep();

%% NAVIGATION
start_time = tic;
iteration = 0;

try
    while toc(start_time) < (RUNTIME_MINUTES * 60)
        iteration = iteration + 1;

        % Check distance
        distance = brick.UltrasonicDist(2);

        % Status every 5 iterations
        if mod(iteration, 5) == 0
            fprintf('[%.1fs] Distance: %.1f cm\n', toc(start_time), distance);
        end

        %% DECISION

        if distance < OBSTACLE_DISTANCE
            % OBSTACLE - Turn right
            fprintf('[%.1fs] Obstacle detected - TURNING RIGHT\n', toc(start_time));

            % Stop
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            % Turn right: B forward, A backward
            brick.MoveMotor('B', -TURN_SPEED);  % Negative for reversed motors
            brick.MoveMotor('A', TURN_SPEED);   % Positive (opposite direction)
            pause(0.6);  % Turn duration

            % Stop
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            fprintf('[%.1fs] Turn complete - moving forward\n', toc(start_time));

        else
            % PATH CLEAR - Move forward
            brick.MoveMotor('AB', FORWARD_SPEED);  % Negative = forward for reversed motors
            pause(MOVE_FORWARD_TIME);
        end

        pause(0.1);
    end

catch ME
    fprintf('\n!!! ERROR: %s\n', ME.message);
end

%% CLEANUP
fprintf('\n========================================\n');
fprintf('Navigation Complete!\n');
fprintf('Total time: %.1f seconds\n', toc(start_time));
fprintf('========================================\n');

brick.StopMotor('AB', 'Coast');
brick.beep();
pause(0.3);
brick.beep();

fprintf('\nDone! Robot stopped.\n');
