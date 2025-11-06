%% MAZE NAVIGATION - Straight Priority + Left Wall Following
% Motors: B (left), A (right) - REVERSED
% Sensors: Port 1 (color), Port 2 (ultrasonic)

FORWARD_SPEED = -45;
TURN_SPEED = 45;
TURN_TIME = 0.65;

fprintf('========================================\n');
fprintf('MAZE NAVIGATION - Left Wall Following\n');
fprintf('========================================\n');

if ~exist('brick', 'var')
    brick = ConnectBrick('BALL');
end

fprintf('Connected!\n');
brick.beep();

brick.StopMotor('D', 'Coast');

fprintf('\nPosition sensor pointing FORWARD\n');
input('Press Enter...', 's');

fprintf('3... 2... 1... GO!\n\n');
brick.beep();

start_time = tic;
goal = false;
last_col = 0;

while toc(start_time) < 600 && ~goal

    % Check color
    col = brick.ColorCode(1);

    if col == 2 && col ~= last_col  % Blue = GOAL
        fprintf('\n*** BLUE GOAL! ***\n');
        brick.StopMotor('AB', 'Brake');
        brick.beep();
        pause(0.5);
        brick.beep();
        goal = true;
        break;
    end

    if col == 5 && col ~= last_col  % Red
        fprintf('[%.0fs] RED\n', toc(start_time));
        brick.StopMotor('AB', 'Brake');
        brick.beep();
        pause(1);
    end

    if col == 3 && col ~= last_col  % Green
        fprintf('[%.0fs] GREEN\n', toc(start_time));
        brick.StopMotor('AB', 'Brake');
        brick.beep();
        pause(0.5);
        brick.beep();
        pause(0.5);
        brick.beep();
        pause(0.5);
    end

    last_col = col;

    % Check distance forward
    d = brick.UltrasonicDist(2);

    fprintf('[%.0fs] D=%dcm ', toc(start_time), round(d));

    %% DECISION LOGIC

    if d < 15
        % BLOCKED - Turn right until clear
        fprintf('BLOCKED - Turn right\n');
        brick.StopMotor('AB', 'Brake');
        pause(0.2);

        % Back up a bit
        brick.MoveMotor('AB', -FORWARD_SPEED);
        pause(0.8);
        brick.StopMotor('AB', 'Brake');
        pause(0.2);

        % Turn right until path is clear
        turned = false;
        for turn_count = 1:4  % Max 4 turns (360 degrees)
            brick.MoveMotor('B', -TURN_SPEED);
            brick.MoveMotor('A', TURN_SPEED);
            pause(TURN_TIME);
            brick.StopMotor('AB', 'Brake');
            pause(0.3);

            % Check if clear now
            check_d = brick.UltrasonicDist(2);
            fprintf('  Check: %dcm\n', round(check_d));
            if check_d > 30
                fprintf('  Clear! Moving forward\n');
                turned = true;
                break;
            end
        end

        if turned
            % Move forward after finding clear path
            brick.MoveMotor('AB', FORWARD_SPEED);
            pause(2.5);
            brick.StopMotor('AB', 'Brake');
        end

    elseif d > 50
        % CLEAR - Go straight with monitoring!
        fprintf('CLEAR - Go straight!\n');
        brick.MoveMotor('AB', FORWARD_SPEED);

        % Move but monitor for obstacles
        move_start = tic;
        while toc(move_start) < 5
            check = brick.UltrasonicDist(2);
            if check < 15
                fprintf('  Obstacle detected during movement!\n');
                break;
            end
            pause(0.5);
        end

        brick.StopMotor('AB', 'Brake');
        pause(0.5);  % Let sensor stabilize after stopping

    else
        % Moderate distance - go forward with monitoring
        fprintf('Forward\n');
        brick.MoveMotor('AB', FORWARD_SPEED);

        move_start = tic;
        while toc(move_start) < 2
            check = brick.UltrasonicDist(2);
            if check < 15
                fprintf('  Stop - obstacle!\n');
                break;
            end
            pause(0.3);
        end

        brick.StopMotor('AB', 'Brake');
        pause(0.3);  % Stabilize
    end

    pause(0.2);
end

if goal
    fprintf('\n========================================\n');
    fprintf('SUCCESS!\n');
    fprintf('Time: %.0fs\n', toc(start_time));
    fprintf('========================================\n');
else
    fprintf('\nTime limit\n');
end

brick.StopMotor('ABD', 'Coast');
brick.beep();
pause(0.3);
brick.beep();
