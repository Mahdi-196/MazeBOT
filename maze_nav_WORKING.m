%% WORKING MAZE NAVIGATION - Correct Ports!
% Motors: B (left), A (right), D (head)
% Sensors: 2 (ultrasonic), 1 (color)

%% CONFIGURATION
FORWARD_SPEED = 40;
TURN_SPEED = 35;
OBSTACLE_DISTANCE = 25;  % Turn if obstacle closer than this (cm)
WALL_DISTANCE = 20;      % Preferred distance from wall
RUNTIME_MINUTES = 5;

%% CONNECT
fprintf('========================================\n');
fprintf('MAZE NAVIGATION - CORRECT PORTS\n');
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

% Center the head (ultrasonic sensor)
fprintf('Centering head sensor...\n');
brick.MoveMotorAngleRel('D', 20, 0, 'Brake');  % Center position
pause(0.5);
fprintf('✓ Head centered\n');

% Countdown
fprintf('\nPlace robot at maze entrance\n');
input('Press Enter when ready...', 's');

fprintf('Starting in: 3... ');
brick.beep();
pause(1);
fprintf('2... ');
brick.beep();
pause(1);
fprintf('1... GO!\n\n');
brick.beep();

%% MAIN NAVIGATION LOOP
start_time = tic;
iteration = 0;

try
    while toc(start_time) < (RUNTIME_MINUTES * 60)
        iteration = iteration + 1;

        % Read ultrasonic sensor (distance ahead/to side)
        distance = brick.UltrasonicDist(2);

        % Display status every 10 iterations
        if mod(iteration, 10) == 0
            fprintf('[%.1fs] Distance: %.1f cm\n', toc(start_time), distance);
        end

        %% NAVIGATION LOGIC

        if distance < OBSTACLE_DISTANCE
            % OBSTACLE DETECTED - Turn right
            fprintf('[%.1fs] Obstacle at %.1fcm - Turning RIGHT\n', toc(start_time), distance);

            % Stop
            brick.StopMotor('AB', 'Brake');
            pause(0.2);

            % Turn right: left (B) forward, right (A) backward
            brick.MoveMotor('B', TURN_SPEED);   % Left forward
            brick.MoveMotor('A', -TURN_SPEED);  % Right backward
            pause(0.5);  % Turn duration - adjust if needed

            % Stop after turn
            brick.StopMotor('AB', 'Brake');
            pause(0.2);

        else
            % PATH CLEAR - Move forward
            brick.MoveMotor('AB', FORWARD_SPEED);
        end

        % Delay between sensor checks
        pause(0.15);
    end

    fprintf('\nTime limit reached\n');

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

fprintf('\nRobot stopped. You can disconnect or run again.\n');
