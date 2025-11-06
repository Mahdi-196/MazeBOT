%% DRIVE WITH COLOR DETECTION - For Video Demo
% Robot drives forward and responds to colors
% Perfect for recording the color detection milestone video
% Motors: B (left), A (right) - REVERSED
% Color Sensor: Port 1

%% CONFIG
FORWARD_SPEED = -30;  % Negative = forward (motors reversed)
RUNTIME_MINUTES = 3;

% Color codes
COLOR_BLACK = 1;
COLOR_BLUE = 2;
COLOR_GREEN = 3;
COLOR_YELLOW = 4;
COLOR_RED = 5;
COLOR_WHITE = 6;

%% CONNECT
fprintf('========================================\n');
fprintf('DRIVE WITH COLOR DETECTION\n');
fprintf('For Color Detection Milestone Video\n');
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

fprintf('\nColor Responses:\n');
fprintf('  RED   -> Stop 1 second\n');
fprintf('  BLUE  -> Stop, beep 2 times\n');
fprintf('  GREEN -> Stop, beep 3 times\n\n');

fprintf('Place colored papers/tape on floor for robot to drive over\n');
input('Press Enter to start...', 's');

fprintf('\n3... ');
brick.beep();
pause(1);
fprintf('2... ');
pause(1);
fprintf('1... GO!\n\n');
brick.beep();

%% DRIVE WITH COLOR DETECTION
start_time = tic;
last_color = 0;

try
    % Start moving forward
    brick.MoveMotor('AB', FORWARD_SPEED);

    while toc(start_time) < (RUNTIME_MINUTES * 60)

        % Check color
        color = brick.ColorCode(1);

        % Respond to color changes
        if color ~= last_color && color > 0

            % Get color name
            switch color
                case COLOR_RED
                    color_name = 'RED';
                case COLOR_BLUE
                    color_name = 'BLUE';
                case COLOR_GREEN
                    color_name = 'GREEN';
                case COLOR_YELLOW
                    color_name = 'YELLOW';
                case COLOR_BLACK
                    color_name = 'BLACK';
                case COLOR_WHITE
                    color_name = 'WHITE';
                otherwise
                    color_name = sprintf('Color %d', color);
            end

            fprintf('[%.0fs] Detected: %s\n', toc(start_time), color_name);

            %% COLOR RESPONSES
            if color == COLOR_RED
                % RED: Stop for 1 second
                fprintf('  -> Stopping for 1 second (RED)\n');
                brick.StopMotor('AB', 'Brake');
                brick.beep();
                pause(1);
                fprintf('  -> Continuing\n');
                brick.MoveMotor('AB', FORWARD_SPEED);

            elseif color == COLOR_BLUE
                % BLUE: Stop and beep 2 times
                fprintf('  -> Beeping 2 times (BLUE)\n');
                brick.StopMotor('AB', 'Brake');
                brick.beep();
                pause(0.5);
                brick.beep();
                pause(1);
                fprintf('  -> Continuing\n');
                brick.MoveMotor('AB', FORWARD_SPEED);

            elseif color == COLOR_GREEN
                % GREEN: Stop and beep 3 times
                fprintf('  -> Beeping 3 times (GREEN)\n');
                brick.StopMotor('AB', 'Brake');
                brick.beep();
                pause(0.5);
                brick.beep();
                pause(0.5);
                brick.beep();
                pause(1);
                fprintf('  -> Continuing\n');
                brick.MoveMotor('AB', FORWARD_SPEED);
            end

            last_color = color;
        end

        pause(0.1);
    end

catch ME
    fprintf('\n!!! ERROR: %s\n', ME.message);
end

%% STOP
fprintf('\n========================================\n');
fprintf('Demo Complete!\n');
fprintf('Total time: %.0f seconds\n', toc(start_time));
fprintf('========================================\n');

brick.StopMotor('AB', 'Coast');
brick.beep();

fprintf('\nDone! Ready to record another video if needed.\n');
