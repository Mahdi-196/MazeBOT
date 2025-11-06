%% COMPLETE MAZE NAVIGATION
% Navigate from YELLOW start to BLUE goal
% Avoids walls, responds to colors, doesn't backtrack
% Motors: B (left), A (right), D (head) - REVERSED
% Sensors: Port 1 (color), Port 2 (ultrasonic)

%% CONFIGURATION
FORWARD_SPEED = -40;      % Faster to get out of loops
TURN_SPEED = 40;
OBSTACLE_DIST = 30;       % Turn when obstacle closer (was 40)
TOO_CLOSE = 15;           % Emergency turn (was 20)
MOVE_TIME = 2.0;          % Move LONGER to escape loops (was 1.5)
TURN_TIME = 0.65;         % 90 degree turn duration
RUNTIME_MINUTES = 10;

% Color codes
COLOR_BLUE = 2;
COLOR_GREEN = 3;
COLOR_YELLOW = 4;
COLOR_RED = 5;

%% CONNECT
fprintf('========================================\n');
fprintf('MAZE NAVIGATION: YELLOW -> BLUE\n');
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

% Set head to coast so you can position it manually
brick.StopMotor('D', 'Coast');
fprintf('✓ Head motor set to coast - you can position it manually\n');

fprintf('\nPosition head to point FORWARD, then place robot on YELLOW start\n');
input('Press Enter when ready...', 's');

% Lock head in forward position
brick.StopMotor('D', 'Brake');

fprintf('\n3... ');
brick.beep();
pause(1);
fprintf('2... ');
brick.beep();
pause(1);
fprintf('1... GO!\n\n');
brick.beep();

%% NAVIGATION WITH ANTI-BACKTRACK
start_time = tic;
goal_reached = false;
last_color = 0;
last_turn = 'none';        % Track last turn to avoid immediate backtrack
consecutive_turns = 0;      % Detect if stuck

try
    while toc(start_time) < (RUNTIME_MINUTES * 60) && ~goal_reached

        %% CHECK COLOR SENSOR - Priority #1
        color = brick.ColorCode(1);

        % Debug output
        if color > 0 && color ~= last_color
            fprintf('[%.0fs] COLOR DETECTED: %d\n', toc(start_time), color);
        end

        if color ~= last_color && color > 0

            switch color
                case COLOR_BLUE
                    % BLUE = GOAL REACHED!
                    fprintf('[%.0fs] *** BLUE GOAL REACHED! ***\n', toc(start_time));
                    brick.StopMotor('AB', 'Brake');
                    pause(0.3);
                    brick.beep();
                    pause(0.5);
                    brick.beep();
                    pause(0.5);
                    goal_reached = true;
                    break;

                case COLOR_RED
                    fprintf('[%.0fs] RED - Stopping 1 second + BEEP\n', toc(start_time));
                    brick.StopMotor('AB', 'Brake');
                    pause(0.3);
                    brick.beep();
                    pause(1);
                    fprintf('[%.0fs] RED - Continuing\n', toc(start_time));

                case COLOR_GREEN
                    fprintf('[%.0fs] GREEN - Beeping 3 times\n', toc(start_time));
                    brick.StopMotor('AB', 'Brake');
                    pause(0.3);
                    brick.beep();
                    pause(0.5);
                    brick.beep();
                    pause(0.5);
                    brick.beep();
                    pause(0.5);
                    fprintf('[%.0fs] GREEN - Continuing\n', toc(start_time));

                case COLOR_YELLOW
                    fprintf('[%.0fs] Yellow detected\n', toc(start_time));
            end

            last_color = color;
        end

        %% CHECK ULTRASONIC - Avoid obstacles
        dist = brick.UltrasonicDist(2);

        % Filter out weird 32.6cm readings (sensor glitch)
        if abs(dist - 32.6) < 0.5
            dist = 255;  % Treat as no obstacle
        end

        fprintf('[%.0fs] Dist: %.1fcm', toc(start_time), dist);

        %% EMERGENCY - Too close!
        if dist < TOO_CLOSE
            fprintf(' -> EMERGENCY BACKUP\n');
            brick.StopMotor('AB', 'Brake');
            pause(0.2);

            % Back up LONGER
            brick.MoveMotor('AB', -FORWARD_SPEED);
            pause(1.2);  % Was 0.6
            brick.StopMotor('AB', 'Brake');
            pause(0.2);

            % Turn away (prefer opposite of last turn to avoid backtrack)
            if strcmp(last_turn, 'left')
                fprintf('     Emergency turn RIGHT\n');
                brick.MoveMotor('B', -TURN_SPEED);
                brick.MoveMotor('A', TURN_SPEED);
                pause(TURN_TIME);
                last_turn = 'right';
            else
                fprintf('     Emergency turn LEFT\n');
                brick.MoveMotor('B', TURN_SPEED);
                brick.MoveMotor('A', -TURN_SPEED);
                pause(TURN_TIME);
                last_turn = 'left';
            end

            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            % Move forward LONG after emergency to escape area
            fprintf('     Emergency forward escape\n');
            brick.MoveMotor('AB', FORWARD_SPEED);
            pause(3.0);  % Move 3 seconds to get away
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            consecutive_turns = consecutive_turns + 1;

        %% OBSTACLE AHEAD - Scan and decide
        elseif dist < OBSTACLE_DIST
            fprintf(' -> Obstacle\n');
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            % Scan with head
            fprintf('     Scanning... ');

            % Look right
            brick.MoveMotorAngleRel('D', 40, -70, 'Brake');
            brick.WaitForMotor('D');
            pause(0.2);
            dist_right = brick.UltrasonicDist(2);

            % Look left
            brick.MoveMotorAngleRel('D', 40, 140, 'Brake');
            brick.WaitForMotor('D');
            pause(0.2);
            dist_left = brick.UltrasonicDist(2);

            % Center head
            brick.MoveMotorAngleRel('D', 40, -70, 'Brake');
            brick.WaitForMotor('D');
            pause(0.2);

            fprintf('L=%.0f R=%.0f\n', dist_left, dist_right);

            %% SMART TURN DECISION - Avoid backtracking

            % If stuck (turned many times), force turn around
            if consecutive_turns > 3
                fprintf('     -> STUCK! Turning around\n');
                brick.MoveMotor('B', -TURN_SPEED);
                brick.MoveMotor('A', TURN_SPEED);
                pause(TURN_TIME * 2);
                last_turn = 'around';
                consecutive_turns = 0;

            % Both paths blocked - turn around
            elseif dist_left < 25 && dist_right < 25
                fprintf('     -> Both blocked - Turning around\n');
                brick.MoveMotor('B', -TURN_SPEED);
                brick.MoveMotor('A', TURN_SPEED);
                pause(TURN_TIME * 2);
                last_turn = 'around';
                consecutive_turns = consecutive_turns + 1;

            % Right is better AND (left is blocked OR we just turned left)
            elseif dist_right > dist_left + 10 || (dist_right > 25 && strcmp(last_turn, 'left'))
                fprintf('     -> Turning RIGHT\n');
                brick.MoveMotor('B', -TURN_SPEED);
                brick.MoveMotor('A', TURN_SPEED);
                pause(TURN_TIME);
                last_turn = 'right';
                consecutive_turns = consecutive_turns + 1;

            % Left is better OR right is blocked
            elseif dist_left > 25
                fprintf('     -> Turning LEFT\n');
                brick.MoveMotor('B', TURN_SPEED);
                brick.MoveMotor('A', -TURN_SPEED);
                pause(TURN_TIME);
                last_turn = 'left';
                consecutive_turns = consecutive_turns + 1;

            % Default to right
            else
                fprintf('     -> Default RIGHT turn\n');
                brick.MoveMotor('B', -TURN_SPEED);
                brick.MoveMotor('A', TURN_SPEED);
                pause(TURN_TIME);
                last_turn = 'right';
                consecutive_turns = consecutive_turns + 1;
            end

            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            % Move forward after turning to get away from wall
            fprintf('     Moving forward after turn\n');
            brick.MoveMotor('AB', FORWARD_SPEED);
            pause(2.5);  % Even longer to escape loops (was 2.0)
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

        %% PATH CLEAR - Move forward
        else
            fprintf(' -> Moving forward\n');
            brick.MoveMotor('AB', FORWARD_SPEED);
            pause(MOVE_TIME);
            brick.StopMotor('AB', 'Brake');
            pause(0.2);

            % Reset turn counter when moving straight
            consecutive_turns = 0;
            last_turn = 'none';
        end

        pause(0.1);
    end

    %% FINISH
    if goal_reached
        fprintf('\n========================================\n');
        fprintf('*** SUCCESS! BLUE GOAL REACHED! ***\n');
        fprintf('Time: %.0f seconds\n', toc(start_time));
        fprintf('========================================\n');
    else
        fprintf('\nTime limit reached - Goal not found\n');
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
