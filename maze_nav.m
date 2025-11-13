%% SIMPLE MAZE NAVIGATION - Back to Basics
% Motors: B (left), A (right) - REVERSED, D (head with ultrasonic)
% Sensors: Port 1 (color), Port 2 (ultrasonic on head)

FORWARD_SPEED = -45;
TURN_SPEED = 45;
TURN_TIME = 0.65;
HEAD_SPEED = 30;
HEAD_ANGLE = 90;  % Degrees to turn head left/right

fprintf('========================================\n');
fprintf('MAZE NAVIGATION\n');
fprintf('========================================\n');

if ~exist('brick', 'var')
    brick = ConnectBrick('BALL');
end

fprintf('Connected!\n');
brick.beep();

% Reset head to center position
fprintf('Resetting head to center...\n');
brick.ResetMotorAngle('D');
brick.StopMotor('D', 'Brake');

fprintf('\nReady\n');
input('Press Enter...', 's');

fprintf('GO!\n\n');
brick.beep();

start_time = tic;
goal = false;
last_col = 0;

while toc(start_time) < 600 && ~goal

    % Check color sensor with confirmation
    col = brick.ColorCode(1);

    % Debug: show all color detections
    if col > 0 && col ~= last_col
        fprintf('[COLOR=%d] ', col);
    end

    % If we detect a color, confirm it with 2 more readings
    if (col == 2 || col == 3 || col == 5) && col ~= last_col
        pause(0.1);
        col2 = brick.ColorCode(1);
        pause(0.1);
        col3 = brick.ColorCode(1);

        % Only act if at least 2 out of 3 readings match
        if col == col2 || col == col3 || col2 == col3
            confirmed_col = col;
        else
            confirmed_col = 0;  % Ignore inconsistent readings
        end
    else
        confirmed_col = col;
    end

    switch confirmed_col
        case 5  % RED - Stop 1 second
            if confirmed_col ~= last_col
                fprintf('\n🔴 RED confirmed! Stopping 1 second...\n');
                brick.StopMotor('AB', 'Brake');
                brick.playTone(50, 800, 500);
                pause(1);
                last_col = confirmed_col;
            end

        case 2  % BLUE - GOAL!
            if confirmed_col ~= last_col
                fprintf('\n🔵 BLUE GOAL confirmed! Beeping twice...\n');
                brick.StopMotor('AB', 'Brake');
                pause(0.5);
                brick.playTone(50, 800, 500);
                pause(0.6);
                brick.playTone(50, 800, 500);
                pause(0.6);
                goal = true;
                last_col = confirmed_col;
                break;
            end

        case 3  % GREEN - Beep 3 times, continue
            if confirmed_col ~= last_col
                fprintf('\n🟢 GREEN confirmed! Beeping 3 times...\n');
                brick.StopMotor('AB', 'Brake');
                for i = 1:3
                    brick.playTone(50, 800, 500);
                    pause(0.6);
                end
                last_col = confirmed_col;
            end

        otherwise
            % No special color or inconsistent readings, keep going
    end

    %% LEFT-WALL FOLLOWING ALGORITHM
    % Check distances in three directions using HEAD SCANNING
    % Head motor (D) rotates the ultrasonic sensor (uses absolute positioning)

    % 1. Check FORWARD (head at center = 0 degrees)
    brick.MoveMotorAngleAbs('D', HEAD_SPEED, 0, 'Brake');
    pause(0.6);
    d_forward = brick.UltrasonicDist(2);
    fprintf('[%.0fs] F:%dcm ', toc(start_time), round(d_forward));

    % 2. Turn HEAD LEFT to check left side
    brick.MoveMotorAngleAbs('D', HEAD_SPEED, HEAD_ANGLE, 'Brake');
    pause(0.6);
    d_left = brick.UltrasonicDist(2);
    fprintf('L:%dcm ', round(d_left));

    % 3. Turn HEAD RIGHT to check right side
    brick.MoveMotorAngleAbs('D', HEAD_SPEED, -HEAD_ANGLE, 'Brake');
    pause(0.6);
    d_right = brick.UltrasonicDist(2);
    fprintf('R:%dcm ', round(d_right));

    % 4. Return HEAD to center for movement
    brick.MoveMotorAngleAbs('D', HEAD_SPEED, 0, 'Brake');
    pause(0.6);

    %% DECISION LOGIC - Left-wall following with safe distance
    MIN_WALL_DIST = 20;      % Too close - will collide! (increased for robot width)
    IDEAL_WALL_DIST = 35;    % Perfect following distance
    MAX_WALL_DIST = 60;      % Wall is "gone" - opening detected
    FORWARD_CLEAR = 25;      % Minimum forward clearance

    if d_left < MIN_WALL_DIST
        % TOO CLOSE TO LEFT WALL - Move away (priority 0)
        fprintf('-> TOO CLOSE LEFT! MOVE RIGHT\n');
        brick.MoveMotor('B', -TURN_SPEED);
        brick.MoveMotor('A', TURN_SPEED);
        pause(TURN_TIME * 0.5);  % Turn right away from wall
        brick.StopMotor('AB', 'Brake');
        pause(0.2);

        brick.MoveMotor('AB', FORWARD_SPEED);
        pause(1.2);
        brick.StopMotor('AB', 'Brake');
        pause(0.2);

    elseif d_left > MAX_WALL_DIST && d_forward > FORWARD_CLEAR
        % LEFT OPENING DETECTED - Turn left cautiously (priority 1)
        fprintf('-> LEFT OPENING - TURN LEFT\n');
        brick.MoveMotor('B', TURN_SPEED);
        brick.MoveMotor('A', -TURN_SPEED);
        pause(TURN_TIME * 0.8);  % Gentler turn to avoid over-turning
        brick.StopMotor('AB', 'Brake');
        pause(0.2);

        brick.MoveMotor('AB', FORWARD_SPEED);
        pause(1.2);
        brick.StopMotor('AB', 'Brake');
        pause(0.2);

    elseif d_forward > FORWARD_CLEAR
        % FORWARD CLEAR - Keep going straight (priority 2)
        % Adjust slightly to maintain ideal wall distance
        if d_left < IDEAL_WALL_DIST - 8
            fprintf('-> GO (nudge right)\n');
            brick.MoveMotor('B', -TURN_SPEED);
            brick.MoveMotor('A', TURN_SPEED);
            pause(TURN_TIME * 0.2);  % Small correction
            brick.StopMotor('AB', 'Brake');
            pause(0.1);
        elseif d_left > IDEAL_WALL_DIST + 8
            fprintf('-> GO (nudge left)\n');
            brick.MoveMotor('B', TURN_SPEED);
            brick.MoveMotor('A', -TURN_SPEED);
            pause(TURN_TIME * 0.2);  % Small correction
            brick.StopMotor('AB', 'Brake');
            pause(0.1);
        else
            fprintf('-> GO STRAIGHT (ideal dist)\n');
        end

        brick.MoveMotor('AB', FORWARD_SPEED);
        pause(1.3);
        brick.StopMotor('AB', 'Brake');
        pause(0.2);

    elseif d_right > FORWARD_CLEAR
        % FORWARD BLOCKED, RIGHT FREE - Turn right (priority 3)
        fprintf('-> BLOCKED AHEAD - TURN RIGHT\n');
        brick.MoveMotor('B', -TURN_SPEED);
        brick.MoveMotor('A', TURN_SPEED);
        pause(TURN_TIME);
        brick.StopMotor('AB', 'Brake');
        pause(0.2);

        brick.MoveMotor('AB', FORWARD_SPEED);
        pause(1.5);
        brick.StopMotor('AB', 'Brake');
        pause(0.2);

    else
        % ALL BLOCKED - Turn around 180 degrees (priority 4)
        fprintf('-> DEAD END - TURN AROUND\n');
        brick.MoveMotor('B', -TURN_SPEED);
        brick.MoveMotor('A', TURN_SPEED);
        pause(TURN_TIME * 2);
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
