%% SMART MAZE NAVIGATION - Uses Head Scanning
% This version scans with head, backs up if stuck, and navigates properly
% Motors: B (left), A (right), D (head) - REVERSED MOTORS
% Sensors: 2 (ultrasonic), 1 (color)

%% CONFIGURATION
FORWARD_SPEED = -45;      % Negative = forward (motors reversed)
BACKWARD_SPEED = 45;      % Positive = backward
TURN_SPEED = 45;
SCAN_SPEED = 40;
OBSTACLE_DIST = 30;       % cm - start looking for turns
TOO_CLOSE = 15;           % cm - must turn now!
STUCK_THRESHOLD = 5;      % If same distance 3 times = stuck
RUNTIME_MINUTES = 5;

%% CONNECT
fprintf('========================================\n');
fprintf('SMART MAZE NAVIGATION with HEAD SCANNING\n');
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
fprintf('Centering head...\n');
brick.MoveMotorAngleRel('D', 30, 0, 'Brake');
pause(0.5);
fprintf('✓ Head centered\n\n');

input('Press Enter to start...', 's');

fprintf('3... ');
brick.beep();
pause(1);
fprintf('2... ');
brick.beep();
pause(1);
fprintf('1... GO!\n\n');
brick.beep();

%% NAVIGATION
start_time = tic;
stuck_count = 0;
last_distance = 0;

try
    while toc(start_time) < (RUNTIME_MINUTES * 60)

        % Center head and check forward
        brick.MoveMotorAngleRel('D', SCAN_SPEED, 0, 'Brake');
        pause(0.3);
        dist_forward = brick.UltrasonicDist(2);

        fprintf('[%.0fs] Forward: %.1fcm\n', toc(start_time), dist_forward);

        % Check if stuck (same distance multiple times)
        if abs(dist_forward - last_distance) < 3
            stuck_count = stuck_count + 1;
        else
            stuck_count = 0;
        end
        last_distance = dist_forward;

        %% STUCK DETECTION - Back up and try different direction
        if stuck_count > 3
            fprintf('  !! STUCK - Backing up\n');

            % Back up
            brick.MoveMotor('AB', BACKWARD_SPEED);
            pause(1.0);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            % Turn around (180 degrees)
            fprintf('  !! Turning around\n');
            brick.MoveMotor('B', -TURN_SPEED);
            brick.MoveMotor('A', TURN_SPEED);
            pause(1.2);  % Double turn time for 180
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            stuck_count = 0;
            continue;
        end

        %% OBSTACLE DETECTION
        if dist_forward < OBSTACLE_DIST
            fprintf('  -> Obstacle ahead - SCANNING\n');

            % Stop
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            % SCAN RIGHT - Turn head right
            brick.MoveMotorAngleRel('D', SCAN_SPEED, -90, 'Brake');
            brick.WaitForMotor('D');
            pause(0.3);
            dist_right = brick.UltrasonicDist(2);
            fprintf('     Right: %.1fcm\n', dist_right);

            % SCAN LEFT - Turn head left (180 from right)
            brick.MoveMotorAngleRel('D', SCAN_SPEED, 180, 'Brake');
            brick.WaitForMotor('D');
            pause(0.3);
            dist_left = brick.UltrasonicDist(2);
            fprintf('     Left: %.1fcm\n', dist_left);

            % Center head again
            brick.MoveMotorAngleRel('D', SCAN_SPEED, -90, 'Brake');
            brick.WaitForMotor('D');
            pause(0.3);

            %% DECIDE WHICH WAY TO TURN
            if dist_right > dist_left && dist_right > 20
                % Turn RIGHT
                fprintf('  -> Decision: TURN RIGHT\n');
                brick.MoveMotor('B', -TURN_SPEED);
                brick.MoveMotor('A', TURN_SPEED);
                pause(0.7);

            elseif dist_left > 20
                % Turn LEFT
                fprintf('  -> Decision: TURN LEFT\n');
                brick.MoveMotor('B', TURN_SPEED);
                brick.MoveMotor('A', -TURN_SPEED);
                pause(0.7);

            else
                % Both blocked - turn around
                fprintf('  -> Decision: TURN AROUND\n');
                brick.MoveMotor('B', -TURN_SPEED);
                brick.MoveMotor('A', TURN_SPEED);
                pause(1.2);  % 180 degrees
            end

            % Stop after turn
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            % Move forward after turning
            fprintf('  -> Moving forward after turn\n');
            brick.MoveMotor('AB', FORWARD_SPEED);
            pause(1.5);  % Move forward for 1.5 seconds
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

        else
            % PATH CLEAR - Keep moving
            fprintf('  -> Path clear - moving forward\n');
            brick.MoveMotor('AB', FORWARD_SPEED);
            pause(1.5);  % Move forward for 1.5 seconds
            brick.StopMotor('AB', 'Brake');
            pause(0.3);
        end

        pause(0.2);
    end

    fprintf('\nTime limit reached\n');

catch ME
    fprintf('\n!!! ERROR: %s\n', ME.message);
end

%% CLEANUP
fprintf('\n========================================\n');
fprintf('Navigation Complete!\n');
fprintf('Total time: %.0f seconds\n', toc(start_time));
fprintf('========================================\n');

brick.StopMotor('ABD', 'Coast');
brick.beep();
pause(0.3);
brick.beep();

fprintf('\nDone!\n');
