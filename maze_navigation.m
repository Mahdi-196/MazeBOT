%% IMPROVED MAZE NAVIGATION - Better Decision Logic
% Filters sensor glitches, smart pathfinding, memory-based navigation
% Motors: B (left), A (right), D (head) - REVERSED
% Sensors: Port 1 (color), Port 2 (ultrasonic)

%% CONFIGURATION
FORWARD_SPEED = -45;
TURN_SPEED = 45;
SCAN_SPEED = 40;
TURN_TIME = 0.65;
RUNTIME_MINUTES = 10;

% Color codes
COLOR_BLUE = 2;
COLOR_GREEN = 3;
COLOR_YELLOW = 4;
COLOR_RED = 5;

%% CONNECT
fprintf('========================================\n');
fprintf('IMPROVED MAZE NAVIGATION: YELLOW -> BLUE\n');
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

brick.StopMotor('D', 'Coast');
fprintf('✓ Head set to coast - position it to point FORWARD\n');

fprintf('\nPlace robot on YELLOW start\n');
input('Press Enter when ready...', 's');

brick.StopMotor('D', 'Brake');

fprintf('\n3... ');
brick.beep();
pause(1);
fprintf('2... ');
pause(1);
fprintf('1... GO!\n\n');
brick.beep();

%% HELPER FUNCTION - Clean sensor reading
function clean_dist = cleanDistance(raw_dist)
    % Filter out common sensor glitches
    if abs(raw_dist - 32.6) < 2 || abs(raw_dist - 32) < 2 || abs(raw_dist - 33) < 2
        clean_dist = 255;  % Treat as clear
    else
        clean_dist = raw_dist;
    end
end

%% NAVIGATION
start_time = tic;
goal_reached = false;
last_color = 0;
last_direction = 'forward';  % Track where we came from
consecutive_backs = 0;

try
    while toc(start_time) < (RUNTIME_MINUTES * 60) && ~goal_reached

        fprintf('\n[%.0fs] ========== SCAN ==========\n', toc(start_time));

        %% CHECK COLOR
        color = brick.ColorCode(1);

        if color ~= last_color && color > 0
            switch color
                case COLOR_BLUE
                    fprintf('\n*** BLUE GOAL! ***\n');
                    brick.StopMotor('AB', 'Brake');
                    pause(0.3);
                    brick.beep();
                    pause(0.5);
                    brick.beep();
                    goal_reached = true;
                    break;

                case COLOR_RED
                    fprintf('RED - Stop 1s\n');
                    brick.StopMotor('AB', 'Brake');
                    pause(0.3);
                    brick.beep();
                    pause(1);

                case COLOR_GREEN
                    fprintf('GREEN - Beep 3x\n');
                    brick.StopMotor('AB', 'Brake');
                    pause(0.3);
                    for i=1:3
                        brick.beep();
                        pause(0.5);
                    end
            end
            last_color = color;
        end

        %% SCAN ALL DIRECTIONS
        brick.StopMotor('AB', 'Brake');
        pause(0.3);

        % Look LEFT
        brick.MoveMotorAngleRel('D', SCAN_SPEED, 90, 'Brake');
        brick.WaitForMotor('D');
        pause(0.3);
        raw_left = brick.UltrasonicDist(2);
        dist_left = cleanDistance(raw_left);

        % Look FORWARD
        brick.MoveMotorAngleRel('D', SCAN_SPEED, -90, 'Brake');
        brick.WaitForMotor('D');
        pause(0.3);
        raw_forward = brick.UltrasonicDist(2);
        dist_forward = cleanDistance(raw_forward);

        % Look RIGHT
        brick.MoveMotorAngleRel('D', SCAN_SPEED, -90, 'Brake');
        brick.WaitForMotor('D');
        pause(0.3);
        raw_right = brick.UltrasonicDist(2);
        dist_right = cleanDistance(raw_right);

        % Center head
        brick.MoveMotorAngleRel('D', SCAN_SPEED, 90, 'Brake');
        brick.WaitForMotor('D');
        pause(0.3);

        fprintf('Scan: L=%dcm F=%dcm R=%dcm\n', round(dist_left), round(dist_forward), round(dist_right));

        %% DECISION LOGIC - Smart pathfinding

        % Count open paths
        open_left = dist_left > 40;
        open_forward = dist_forward > 40;
        open_right = dist_right > 40;
        num_open = open_left + open_forward + open_right;

        fprintf('Open paths: %d | Last dir: %s\n', num_open, last_direction);

        %% All blocked - back up and turn around
        if dist_left < 25 && dist_forward < 25 && dist_right < 25
            fprintf('-> ALL BLOCKED! Backing up\n');
            brick.MoveMotor('AB', -FORWARD_SPEED);  % Backward
            pause(2.0);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            % Turn 180
            brick.MoveMotor('B', -TURN_SPEED);
            brick.MoveMotor('A', TURN_SPEED);
            pause(TURN_TIME * 2);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            last_direction = 'back';
            consecutive_backs = consecutive_backs + 1;
            continue;
        end

        %% Choose direction with intelligent preferences
        move_time = 3.0;  % Default move time

        % Prefer forward if it's open and we're not backtracking
        if dist_forward > 50 && ~strcmp(last_direction, 'back')
            fprintf('-> FORWARD (prefer straight, %dcm clear)\n', round(dist_forward));
            direction = 'forward';
            if dist_forward > 100
                move_time = 4.0;  % Move longer when very clear
            end

        % Forward is decent and we didn't just come from there
        elseif dist_forward > 40 && ~strcmp(last_direction, 'back')
            fprintf('-> FORWARD (good path, %dcm)\n', round(dist_forward));
            direction = 'forward';

        % Right is clearly best
        elseif dist_right > dist_left + 20 && dist_right > dist_forward + 20 && dist_right > 40
            fprintf('-> RIGHT (best option, %dcm)\n', round(dist_right));
            brick.MoveMotor('B', -TURN_SPEED);
            brick.MoveMotor('A', TURN_SPEED);
            pause(TURN_TIME);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);
            direction = 'right';
            consecutive_backs = 0;

        % Left is clearly best
        elseif dist_left > dist_right + 20 && dist_left > dist_forward + 20 && dist_left > 40
            fprintf('-> LEFT (best option, %dcm)\n', round(dist_left));
            brick.MoveMotor('B', TURN_SPEED);
            brick.MoveMotor('A', -TURN_SPEED);
            pause(TURN_TIME);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);
            direction = 'left';
            consecutive_backs = 0;

        % Pick biggest available path
        elseif dist_right >= dist_left && dist_right > 30
            fprintf('-> RIGHT (pick biggest, %dcm)\n', round(dist_right));
            brick.MoveMotor('B', -TURN_SPEED);
            brick.MoveMotor('A', TURN_SPEED);
            pause(TURN_TIME);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);
            direction = 'right';

        elseif dist_left > 30
            fprintf('-> LEFT (pick biggest, %dcm)\n', round(dist_left));
            brick.MoveMotor('B', TURN_SPEED);
            brick.MoveMotor('A', -TURN_SPEED);
            pause(TURN_TIME);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);
            direction = 'left';

        else
            fprintf('-> FORWARD (default)\n');
            direction = 'forward';
        end

        last_direction = direction;

        %% MOVE FORWARD with safety monitoring
        fprintf('Moving %.1fs... ', move_time);

        brick.MoveMotor('AB', FORWARD_SPEED);
        move_start = tic;
        stopped_early = false;

        while toc(move_start) < move_time
            % Check distance
            check_dist = brick.UltrasonicDist(2);

            if check_dist < 8  % Emergency threshold
                fprintf('STOP! ');
                brick.StopMotor('AB', 'Brake');
                stopped_early = true;
                break;
            end

            % Check for blue goal
            if brick.ColorCode(1) == COLOR_BLUE
                fprintf('BLUE! ');
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

        if ~stopped_early && ~goal_reached
            brick.StopMotor('AB', 'Brake');
            fprintf('Done\n');
        else
            fprintf('\n');
        end

        pause(0.2);
    end

    %% FINISH
    if goal_reached
        fprintf('\n========================================\n');
        fprintf('*** SUCCESS! ***\n');
        fprintf('Time: %.0fs\n', toc(start_time));
        fprintf('========================================\n');
    else
        fprintf('\nTime limit\n');
    end

catch ME
    fprintf('\nERROR: %s\n', ME.message);
end

%% CLEANUP
brick.StopMotor('ABD', 'Coast');
brick.beep();
pause(0.3);
brick.beep();
pause(0.3);
brick.beep();
