%% SIMPLE MAZE NAVIGATION - Back to Basics
% Motors: B (left), A (right) - REVERSED
% Sensors: Port 1 (color), Port 2 (ultrasonic)

FORWARD_SPEED = -45;
TURN_SPEED = 45;
TURN_TIME = 0.65;

fprintf('========================================\n');
fprintf('MAZE NAVIGATION\n');
fprintf('========================================\n');

if ~exist('brick', 'var')
    brick = ConnectBrick('BALL');
end

fprintf('Connected!\n');
brick.beep();

brick.StopMotor('D', 'Coast');

fprintf('\nReady\n');
input('Press Enter...', 's');

fprintf('GO!\n\n');
brick.beep();

start_time = tic;
goal = false;
last_col = 0;

while toc(start_time) < 600 && ~goal

    % Check color
    col = brick.ColorCode(1);

    if col == 2 && col ~= last_col  % Blue
        fprintf('\n*** BLUE GOAL! ***\n');
        brick.StopMotor('AB', 'Brake');
        brick.beep();
        pause(0.5);
        brick.beep();
        goal = true;
        break;
    end

    if col == 5 && col ~= last_col  % Red
        brick.StopMotor('AB', 'Brake');
        brick.beep();
        pause(1);
    end

    if col == 3 && col ~= last_col  % Green
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

    fprintf('[%.0fs] F=%dcm ', toc(start_time), round(d));

    if d < 25
        % OBSTACLE - Scan left and right with head
        fprintf('SCAN ');

        % Look LEFT
        brick.MoveMotorAngleRel('D', 40, 90, 'Brake');
        pause(0.4);
        d_left = brick.UltrasonicDist(2);

        % Look RIGHT
        brick.MoveMotorAngleRel('D', 40, -180, 'Brake');
        pause(0.4);
        d_right = brick.UltrasonicDist(2);

        % Center head
        brick.MoveMotorAngleRel('D', 40, 90, 'Brake');
        pause(0.3);

        fprintf('L=%d R=%d ', round(d_left), round(d_right));

        % Choose best direction
        if d_left > d_right && d_left > 30
            fprintf('TURN LEFT\n');
            brick.MoveMotor('B', TURN_SPEED);   % Left backward
            brick.MoveMotor('A', -TURN_SPEED);  % Right forward
            pause(TURN_TIME);
            brick.StopMotor('AB', 'Brake');
        elseif d_right > 30
            fprintf('TURN RIGHT\n');
            brick.MoveMotor('B', -TURN_SPEED);  % Left forward
            brick.MoveMotor('A', TURN_SPEED);   % Right backward
            pause(TURN_TIME);
            brick.StopMotor('AB', 'Brake');
        else
            fprintf('BOTH BLOCKED - BACK UP\n');
            brick.MoveMotor('AB', -FORWARD_SPEED);  % Backward
            pause(1.5);
            brick.StopMotor('AB', 'Brake');
        end

        pause(0.2);
    else
        % Go straight
        fprintf('GO\n');
        brick.MoveMotor('AB', FORWARD_SPEED);
        pause(3);
        brick.StopMotor('AB', 'Brake');
        pause(0.2);
    end

    pause(0.1);
end

if goal
    fprintf('\nSUCCESS! Time: %.0fs\n', toc(start_time));
else
    fprintf('\nTime up\n');
end

brick.StopMotor('ABD', 'Coast');
brick.beep();
