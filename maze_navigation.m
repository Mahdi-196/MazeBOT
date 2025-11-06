%% SMART MAZE NAVIGATION - Scan First Strategy
% 1. Stop and scan all directions
% 2. Choose best direction
% 3. Move confidently for 3 seconds
% 4. Repeat
% Motors: B (left), A (right), D (head) - REVERSED
% Sensors: Port 1 (color), Port 2 (ultrasonic)

%% CONFIGURATION
FORWARD_SPEED = -45;      % Faster for confident movement
TURN_SPEED = 45;
SCAN_SPEED = 40;
MOVE_TIME = 3.0;          % Move 3 seconds after each decision
TURN_TIME = 0.65;         % 90 degree turn
RUNTIME_MINUTES = 10;

% Color codes
COLOR_BLUE = 2;
COLOR_GREEN = 3;
COLOR_YELLOW = 4;
COLOR_RED = 5;

%% CONNECT
fprintf('========================================\n');
fprintf('SMART MAZE NAVIGATION: YELLOW -> BLUE\n');
fprintf('Scan -> Decide -> Move Strategy\n');
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

% Set head to coast for manual positioning
brick.StopMotor('D', 'Coast');
fprintf('✓ Head set to coast - position it to point FORWARD\n');

fprintf('\nPlace robot on YELLOW start\n');
input('Press Enter when ready...', 's');

% Lock head
brick.StopMotor('D', 'Brake');

fprintf('\n3... ');
brick.beep();
pause(1);
fprintf('2... ');
pause(1);
fprintf('1... GO!\n\n');
brick.beep();

%% SMART NAVIGATION LOOP
start_time = tic;
goal_reached = false;
last_color = 0;
moves_count = 0;

try
    while toc(start_time) < (RUNTIME_MINUTES * 60) && ~goal_reached
        moves_count = moves_count + 1;

        fprintf('\n[%.0fs] === SCAN CYCLE %d ===\n', toc(start_time), moves_count);

        %% STEP 1: CHECK COLOR SENSOR
        color = brick.ColorCode(1);

        if color ~= last_color && color > 0
            fprintf('[%.0fs] COLOR: %d\n', toc(start_time), color);

            switch color
                case COLOR_BLUE
                    % BLUE = GOAL!
                    fprintf('\n*** BLUE GOAL REACHED! ***\n');
                    brick.StopMotor('AB', 'Brake');
                    pause(0.3);
                    brick.beep();
                    pause(0.5);
                    brick.beep();
                    pause(0.5);
                    goal_reached = true;
                    break;

                case COLOR_RED
                    fprintf('RED detected - Stopping 1s + BEEP\n');
                    brick.StopMotor('AB', 'Brake');
                    pause(0.3);
                    brick.beep();
                    pause(1);

                case COLOR_GREEN
                    fprintf('GREEN detected - Beeping 3x\n');
                    brick.StopMotor('AB', 'Brake');
                    pause(0.3);
                    brick.beep();
                    pause(0.5);
                    brick.beep();
                    pause(0.5);
                    brick.beep();
                    pause(0.5);
            end

            last_color = color;
        end

        %% STEP 2: STOP AND SCAN ALL DIRECTIONS
        brick.StopMotor('AB', 'Brake');
        pause(0.3);

        fprintf('Scanning... ');

        % Look LEFT (90 degrees left)
        brick.MoveMotorAngleRel('D', SCAN_SPEED, 90, 'Brake');
        brick.WaitForMotor('D');
        pause(0.3);
        dist_left = brick.UltrasonicDist(2);

        % Look FORWARD (center)
        brick.MoveMotorAngleRel('D', SCAN_SPEED, -90, 'Brake');
        brick.WaitForMotor('D');
        pause(0.3);
        dist_forward = brick.UltrasonicDist(2);

        % Look RIGHT (90 degrees right)
        brick.MoveMotorAngleRel('D', SCAN_SPEED, -90, 'Brake');
        brick.WaitForMotor('D');
        pause(0.3);
        dist_right = brick.UltrasonicDist(2);

        % Return to CENTER
        brick.MoveMotorAngleRel('D', SCAN_SPEED, 90, 'Brake');
        brick.WaitForMotor('D');
        pause(0.3);

        fprintf('L=%.0f F=%.0f R=%.0f\n', dist_left, dist_forward, dist_right);

        %% STEP 3: DECIDE BEST DIRECTION
        best_dist = max([dist_left, dist_forward, dist_right]);

        % If everything is blocked, back up
        if best_dist < 20
            fprintf('All blocked! Backing up and turning around\n');
            brick.MoveMotor('AB', -FORWARD_SPEED);  % Backward
            pause(1.5);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            % Turn 180
            brick.MoveMotor('B', -TURN_SPEED);
            brick.MoveMotor('A', TURN_SPEED);
            pause(TURN_TIME * 2);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);
            continue;
        end

        %% STEP 4: TURN TOWARD BEST DIRECTION AND MOVE
        if dist_forward >= best_dist - 10 && dist_forward > 30
            % Forward is best or close enough
            fprintf('Decision: FORWARD (%.0fcm clear)\n', dist_forward);
            % Already facing forward, just go

        elseif dist_right > dist_left && dist_right > 30
            % Right is best
            fprintf('Decision: TURN RIGHT (%.0fcm clear)\n', dist_right);
            brick.MoveMotor('B', -TURN_SPEED);
            brick.MoveMotor('A', TURN_SPEED);
            pause(TURN_TIME);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

        elseif dist_left > 30
            % Left is best
            fprintf('Decision: TURN LEFT (%.0fcm clear)\n', dist_left);
            brick.MoveMotor('B', TURN_SPEED);
            brick.MoveMotor('A', -TURN_SPEED);
            pause(TURN_TIME);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

        else
            % Nothing great, just pick biggest
            if dist_right >= dist_left
                fprintf('Decision: DEFAULT RIGHT (%.0fcm)\n', dist_right);
                brick.MoveMotor('B', -TURN_SPEED);
                brick.MoveMotor('A', TURN_SPEED);
                pause(TURN_TIME);
            else
                fprintf('Decision: DEFAULT LEFT (%.0fcm)\n', dist_left);
                brick.MoveMotor('B', TURN_SPEED);
                brick.MoveMotor('A', -TURN_SPEED);
                pause(TURN_TIME);
            end
            brick.StopMotor('AB', 'Brake');
            pause(0.3);
        end

        %% STEP 5: MOVE FORWARD CONFIDENTLY
        fprintf('Moving forward for %.1f seconds...\n', MOVE_TIME);

        brick.MoveMotor('AB', FORWARD_SPEED);

        % Move but check for emergency stops
        move_start = tic;
        emergency = false;

        while toc(move_start) < MOVE_TIME
            % Quick distance check every 0.3s during movement
            dist_check = brick.UltrasonicDist(2);

            if dist_check < 10
                fprintf('  EMERGENCY STOP at %.1fs!\n', toc(move_start));
                brick.StopMotor('AB', 'Brake');
                emergency = true;
                break;
            end

            % Check color during movement
            color_check = brick.ColorCode(1);
            if color_check == COLOR_BLUE
                fprintf('  BLUE detected during movement!\n');
                brick.StopMotor('AB', 'Brake');
                pause(0.3);
                brick.beep();
                pause(0.5);
                brick.beep();
                goal_reached = true;
                break;
            end

            pause(0.3);
        end

        if ~emergency && ~goal_reached
            brick.StopMotor('AB', 'Brake');
            fprintf('Move complete.\n');
        end

        pause(0.2);
    end

    %% FINISH
    if goal_reached
        fprintf('\n========================================\n');
        fprintf('*** SUCCESS! REACHED BLUE GOAL! ***\n');
        fprintf('Time: %.0f seconds\n', toc(start_time));
        fprintf('Total scan cycles: %d\n', moves_count);
        fprintf('========================================\n');
    else
        fprintf('\nTime limit reached\n');
    end

catch ME
    fprintf('\n!!! ERROR: %s\n', ME.message);
end

%% CLEANUP
brick.StopMotor('ABD', 'Coast');
brick.beep();
pause(0.3);
brick.beep();
pause(0.3);
brick.beep();

fprintf('\nNavigation complete!\n');
