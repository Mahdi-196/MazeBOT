%% BASIC MAZE NAVIGATION - Simplest Version
% Goes forward until obstacle detected, then turns right
% This is the easiest to debug and understand

%% CONFIG
SPEED = 40;
OBSTACLE_DISTANCE = 25;  % cm - turn if obstacle closer than this
RUNTIME_MINUTES = 3;

%% CONNECT
fprintf('=== BASIC MAZE NAVIGATION ===\n\n');

if ~exist('brick', 'var')
    try
        clear brick
        fclose(instrfind);
        delete(instrfind);
    catch
    end
    brick = ConnectBrick('BALL');
end

fprintf('Connected!\n');
brick.beep();

fprintf('\nPlace robot in maze entrance.\n');
input('Press Enter to start...', 's');

fprintf('\nCountdown: 3... ');
pause(1);
fprintf('2... ');
pause(1);
fprintf('1... GO!\n\n');
brick.beep();

%% NAVIGATE
start_time = tic;

try
    fprintf('Starting navigation...\n');

    while toc(start_time) < (RUNTIME_MINUTES * 60)

        % Check what's ahead
        distance = brick.UltrasonicDist(2);

        if distance < OBSTACLE_DISTANCE
            % OBSTACLE AHEAD - Stop and turn right
            fprintf('[%.1fs] Obstacle at %.1fcm - Turning right\n', ...
                    toc(start_time), distance);

            % Stop
            brick.StopMotor('BC', 'Brake');
            pause(0.2);

            % Turn right (90 degrees)
            brick.MoveMotor('B', SPEED);    % Left forward
            brick.MoveMotor('C', -SPEED);   % Right backward
            pause(0.5);  % Adjust this if turn isn't 90 degrees

            % Stop after turn
            brick.StopMotor('BC', 'Brake');
            pause(0.2);

            fprintf('[%.1fs] Turn complete - continuing forward\n', toc(start_time));

        else
            % PATH CLEAR - Keep moving forward
            brick.MoveMotor('BC', SPEED);
        end

        % Small delay between sensor checks
        pause(0.2);
    end

    fprintf('\nTime limit reached - stopping\n');

catch ME
    fprintf('\nERROR: %s\n', ME.message);
end

%% STOP
fprintf('\n=== Navigation Complete ===\n');
fprintf('Total time: %.1f seconds\n', toc(start_time));

brick.StopMotor('BC', 'Coast');
brick.beep();
pause(0.3);
brick.beep();
