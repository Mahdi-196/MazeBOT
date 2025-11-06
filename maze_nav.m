%% MAZE NAVIGATION - Fresh Version
% Simple right-turn navigation
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

fprintf('\nReady to start\n');
input('Press Enter...', 's');

fprintf('3... 2... 1... GO!\n\n');
brick.beep();

start_time = tic;
goal = false;
last_col = 0;

while toc(start_time) < 600 && ~goal

    % Check color
    col = brick.ColorCode(1);

    if col == 2 && col ~= last_col  % Blue
        fprintf('BLUE GOAL!\n');
        brick.StopMotor('AB', 'Brake');
        brick.beep();
        pause(0.5);
        brick.beep();
        goal = true;
        break;
    end

    if col == 5 && col ~= last_col  % Red
        fprintf('RED\n');
        brick.StopMotor('AB', 'Brake');
        brick.beep();
        pause(1);
    end

    if col == 3 && col ~= last_col  % Green
        fprintf('GREEN\n');
        brick.StopMotor('AB', 'Brake');
        brick.beep();
        pause(0.5);
        brick.beep();
        pause(0.5);
        brick.beep();
        pause(0.5);
    end

    last_col = col;

    % Check distance
    d = brick.UltrasonicDist(2);

    fprintf('[%.0fs] D=%dcm', toc(start_time), round(d));

    if d < 30
        % Turn right
        fprintf(' TURN\n');
        brick.StopMotor('AB', 'Brake');
        pause(0.2);
        brick.MoveMotor('B', -TURN_SPEED);
        brick.MoveMotor('A', TURN_SPEED);
        pause(TURN_TIME);
        brick.StopMotor('AB', 'Brake');
        pause(0.2);
    else
        % Go forward
        fprintf(' GO\n');
        brick.MoveMotor('AB', FORWARD_SPEED);
        pause(2);
        brick.StopMotor('AB', 'Brake');
    end

    pause(0.1);
end

if goal
    fprintf('\nSUCCESS!\n');
else
    fprintf('\nTime up\n');
end

brick.StopMotor('ABD', 'Coast');
brick.beep();
