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
        dist_left = brick.UltrasonicDist(2);
        % Filter glitches
        if abs(dist_left - 32.6) < 2 || abs(dist_left - 32) < 2 || abs(dist_left - 33) < 2
            dist_left = 255;
        end

        % Look FORWARD
        brick.MoveMotorAngleRel('D', SCAN_SPEED, -90, 'Brake');
        brick.WaitForMotor('D');
        pause(0.3);
        dist_forward = brick.UltrasonicDist(2);
        % Filter glitches
        if abs(dist_forward - 32.6) < 2 || abs(dist_forward - 32) < 2 || abs(dist_forward - 33) < 2
            dist_forward = 255;
        end

        % Look RIGHT
        brick.MoveMotorAngleRel('D', SCAN_SPEED, -90, 'Brake');
        brick.WaitForMotor('D');
        pause(0.3);
        dist_right = brick.UltrasonicDist(2);
        % Filter glitches
        if abs(dist_right - 32.6) < 2 || abs(dist_right - 32) < 2 || abs(dist_right - 33) < 2
            dist_right = 255;
        end

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

        % Find the clearest path
        [best_dist, best_idx] = max([dist_left, dist_forward, dist_right]);

        % Adjust move time based on how clear the path is
        if best_dist > 200
            move_time = 6.0;  % Very clear - go far!
        elseif best_dist > 100
            move_time = 5.0;  % Clear - go long
        elseif best_dist > 50
            move_time = 4.0;  % Pretty clear
        end

        % Prefer forward if it's clear
        if dist_forward > 50 && dist_forward >= best_dist - 30
            fprintf('-> FORWARD (straight, %dcm, %.1fs)\n', round(dist_forward), move_time);
            direction = 'forward';

        % Turn toward clearest path
        elseif best_idx == 3  % Right is best
            fprintf('-> RIGHT (clearest, %dcm, %.1fs)\n', round(dist_right), move_time);
            brick.MoveMotor('B', -TURN_SPEED);
            brick.MoveMotor('A', TURN_SPEED);
            pause(TURN_TIME);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);
            direction = 'right';
            consecutive_backs = 0;

        elseif best_idx == 1  % Left is best
            fprintf('-> LEFT (clearest, %dcm, %.1fs)\n', round(dist_left), move_time);
            brick.MoveMotor('B', TURN_SPEED);
            brick.MoveMotor('A', -TURN_SPEED);
            pause(TURN_TIME);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);
            direction = 'left';
            consecutive_backs = 0;

        else  % Forward by default
            fprintf('-> FORWARD (default, %dcm, %.1fs)\n', round(dist_forward), move_time);
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
