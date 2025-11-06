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

    % Debug: show all color detections
    if col > 0 && col ~= last_col
        fprintf('[COLOR=%d] ', col);
    end

    if col == 2 && col ~= last_col  % Blue = GOAL
        fprintf('\n*** BLUE GOAL DETECTED! ***\n');
        brick.StopMotor('AB', 'Brake');
        pause(0.5);
        brick.beep();
        pause(0.5);
        brick.beep();
        pause(0.5);
        goal = true;
        break;
    end

    if col == 5 && col ~= last_col  % Red - stop 1s
        fprintf('[RED] ');
        brick.StopMotor('AB', 'Brake');
        brick.beep();
        pause(1);
    end

    if col == 3 && col ~= last_col  % Green - beep 3x, keep going
        fprintf('[GREEN] ');
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

    fprintf('[%.0fs] %dcm ', toc(start_time), round(d));

    if d < 25
        % OBSTACLE - Turn right (right-hand rule)
        fprintf('TURN RIGHT\n');
        brick.MoveMotor('B', -TURN_SPEED);
        brick.MoveMotor('A', TURN_SPEED);
        pause(TURN_TIME);
        brick.StopMotor('AB', 'Brake');
        pause(0.2);

        % Check if still blocked after turn
        d_check = brick.UltrasonicDist(2);
        if d_check < 20
            % Still blocked - try left instead
            fprintf('  Still blocked, try LEFT\n');
            brick.MoveMotor('B', TURN_SPEED);
            brick.MoveMotor('A', -TURN_SPEED);
            pause(TURN_TIME * 2);  % Turn left 180 from right
            brick.StopMotor('AB', 'Brake');
            pause(0.2);
        end
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
