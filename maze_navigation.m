%% SIMPLIFIED MAZE NAVIGATION - No head scanning
% Just go forward, turn when hitting walls
% Motors: B (left), A (right), D (head) - REVERSED
% Sensors: Port 1 (color), Port 2 (ultrasonic)

%% CONFIGURATION
FORWARD_SPEED = -45;
TURN_SPEED = 45;
OBSTACLE_DIST = 30;
TURN_TIME = 0.65;
RUNTIME_MINUTES = 10;

% Color codes
COLOR_BLUE = 2;
COLOR_GREEN = 3;
COLOR_YELLOW = 4;
COLOR_RED = 5;

%% CONNECT
fprintf('========================================\n');
fprintf('SIMPLIFIED MAZE NAVIGATION: YELLOW -> BLUE\n');
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
fprintf('✓ Head set to coast\n');

fprintf('\nPlace robot on YELLOW, sensor pointing FORWARD\n');
input('Press Enter when ready...', 's');

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
move_count = 0;

try
    while toc(start_time) < (RUNTIME_MINUTES * 60) && ~goal_reached
        move_count = move_count + 1;

        %% CHECK COLOR
        color = brick.ColorCode(1);

        if color ~= last_color && color > 0
            switch color
                case COLOR_BLUE
                    fprintf('\n*** BLUE GOAL REACHED! ***\n');
                    brick.StopMotor('AB', 'Brake');
                    pause(0.3);
                    brick.beep();
                    pause(0.5);
                    brick.beep();
                    goal_reached = true;
                    break;

                case COLOR_RED
                    fprintf('[%.0fs] RED - Stop 1s\n', toc(start_time));
                    brick.StopMotor('AB', 'Brake');
                    pause(0.3);
                    brick.beep();
                    pause(1);

                case COLOR_GREEN
                    fprintf('[%.0fs] GREEN - Beep 3x\n', toc(start_time));
                    brick.StopMotor('AB', 'Brake');
                    pause(0.3);
                    for i=1:3
                        brick.beep();
                        pause(0.5);
                    end
            end
            last_color = color;
        end

        %% CHECK DISTANCE FORWARD
        dist = brick.UltrasonicDist(2);

        % Filter glitches
        if abs(dist - 32.6) < 2 || abs(dist - 32) < 2 || abs(dist - 33) < 2
            dist = 255;
        end

        fprintf('[%.0fs] #%d Dist: %dcm', toc(start_time), move_count, round(dist));

        %% DECISION
        if dist < OBSTACLE_DIST
            % OBSTACLE - Turn right
            fprintf(' -> OBSTACLE! Turn right\n');
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            brick.MoveMotor('B', -TURN_SPEED);
            brick.MoveMotor('A', TURN_SPEED);
            pause(TURN_TIME);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

        else
            % CLEAR - Move forward
            if dist > 100
                move_time = 5.0;
                fprintf(' -> CLEAR! Moving 5s\n');
            else
                move_time = 3.0;
                fprintf(' -> Clear, moving 3s\n');
            end

            brick.MoveMotor('AB', FORWARD_SPEED);

            % Move with monitoring
            move_start = tic;
            while toc(move_start) < move_time
                % Emergency check
                check_dist = brick.UltrasonicDist(2);
                if check_dist < 10
                    fprintf('  EMERGENCY STOP!\n');
                    brick.StopMotor('AB', 'Brake');
                    break;
                end

                % Blue check
                if brick.ColorCode(1) == COLOR_BLUE
                    fprintf('  BLUE!\n');
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

            brick.StopMotor('AB', 'Brake');
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
