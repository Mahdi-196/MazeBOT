%% SUPER SIMPLE MAZE NAVIGATION
% Just goes forward and turns when hitting walls
% No fancy stuff - easiest to debug

%% CONFIG
SPEED = 40;
TURN_TIME = 0.6;
FORWARD_TIME = 1.5;  % Move forward this long before checking again
OBSTACLE_DIST = 25;

%% CONNECT
fprintf('=== SIMPLE MAZE NAV ===\n');

if ~exist('brick', 'var')
    brick = ConnectBrick('BALL');
end

brick.beep();
fprintf('Connected!\n\n');

% Test direction first
fprintf('TESTING: Robot will move for 1 second\n');
fprintf('Watch: Does it go FORWARD or BACKWARD?\n');
input('Press Enter to test...', 's');

brick.MoveMotor('AB', SPEED);
pause(1);
brick.StopMotor('AB', 'Brake');
pause(0.5);

fprintf('\nDid it go FORWARD? (Type Y or N): ');
answer = input('', 's');

if upper(answer) == 'N'
    fprintf('\nReversing motor direction...\n');
    SPEED = -SPEED;  % Flip the direction
end

fprintf('\nStarting maze navigation!\n');
input('Press Enter to start...', 's');

fprintf('3... ');
pause(1);
fprintf('2... ');
pause(1);
fprintf('1... GO!\n\n');
brick.beep();

%% NAVIGATE
start_time = tic;

try
    while toc(start_time) < 180  % 3 minutes

        % Check for obstacle
        dist = brick.UltrasonicDist(2);
        fprintf('[%.0fs] Dist: %.1fcm\n', toc(start_time), dist);

        if dist < OBSTACLE_DIST
            % TURN
            fprintf('  -> Turning right\n');
            brick.StopMotor('AB', 'Brake');
            pause(0.2);

            % Turn right
            brick.MoveMotor('B', SPEED);
            brick.MoveMotor('A', -SPEED);
            pause(TURN_TIME);

            brick.StopMotor('AB', 'Brake');
            pause(0.2);

        else
            % GO FORWARD
            fprintf('  -> Moving forward\n');
            brick.MoveMotor('AB', SPEED);
            pause(FORWARD_TIME);
        end

        pause(0.3);
    end

catch ME
    fprintf('\nError: %s\n', ME.message);
end

%% STOP
fprintf('\nDone!\n');
brick.StopMotor('AB', 'Coast');
brick.beep();
