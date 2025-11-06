%% FIXED AUTONOMOUS MAZE NAVIGATION
% This version moves forward properly between sensor checks
% Hardware: Motors B & C, Ultrasonic Sensor Port 2

%% CONFIGURATION
FORWARD_SPEED = 40;
TURN_SPEED = 35;
WALL_DISTANCE = 20;      % Target distance from wall (cm)
TOO_CLOSE = 12;          % Turn away if closer than this
TOO_FAR = 40;            % Turn toward wall if farther than this
MOVE_TIME = 0.8;         % Move forward for this long between checks
TURN_TIME = 0.4;         % Duration of 90-degree turn
RUNTIME_MINUTES = 5;

%% CONNECT
fprintf('========================================\n');
fprintf('FIXED MAZE NAVIGATION\n');
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

% Countdown
fprintf('\nStarting in: ');
for i = 3:-1:1
    fprintf('%d... ', i);
    brick.beep();
    pause(1);
end
fprintf('GO!\n\n');

%% MAIN LOOP
start_time = tic;
iteration = 0;

try
    while toc(start_time) < (RUNTIME_MINUTES * 60)
        iteration = iteration + 1;

        % Read sensor
        distance = brick.UltrasonicDist(2);

        % Display status
        if mod(iteration, 5) == 0
            fprintf('Time: %.1fs | Distance: %.1f cm\n', toc(start_time), distance);
        end

        %% DECISION MAKING

        if distance > TOO_FAR
            % NO WALL ON RIGHT - Turn right and move forward
            fprintf('[%.1fs] No wall - turning right\n', toc(start_time));

            brick.StopMotor('BC', 'Brake');
            pause(0.1);

            % Turn right
            brick.MoveMotor('B', TURN_SPEED);
            brick.MoveMotor('C', -TURN_SPEED);
            pause(TURN_TIME);

            % Move forward
            brick.MoveMotor('BC', FORWARD_SPEED);
            pause(MOVE_TIME);

        elseif distance < TOO_CLOSE
            % TOO CLOSE - Turn left and move forward
            fprintf('[%.1fs] Too close - turning left\n', toc(start_time));

            brick.StopMotor('BC', 'Brake');
            pause(0.1);

            % Turn left
            brick.MoveMotor('B', -TURN_SPEED);
            brick.MoveMotor('C', TURN_SPEED);
            pause(TURN_TIME);

            % Move forward
            brick.MoveMotor('BC', FORWARD_SPEED);
            pause(MOVE_TIME);

        else
            % GOOD DISTANCE - Just move forward
            brick.MoveMotor('BC', FORWARD_SPEED);
            pause(MOVE_TIME);
        end

        % Small delay before next sensor reading
        pause(0.1);
    end

catch ME
    fprintf('\n!!! ERROR: %s\n', ME.message);
end

%% CLEANUP
fprintf('\n========================================\n');
fprintf('Navigation Complete!\n');
fprintf('Total time: %.1f seconds\n', toc(start_time));
fprintf('========================================\n');

brick.StopMotor('BC', 'Coast');
brick.beep();
pause(0.3);
brick.beep();
