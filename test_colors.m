%% COLOR SENSOR TEST - For Color Detection Milestone
% Tests color sensor responses: Red, Blue, Green
% This is for demonstrating the color detection milestone

%% COLOR CODES
COLOR_BLACK = 1;
COLOR_BLUE = 2;
COLOR_GREEN = 3;
COLOR_YELLOW = 4;
COLOR_RED = 5;
COLOR_WHITE = 6;

%% CONNECT
fprintf('========================================\n');
fprintf('COLOR SENSOR TEST\n');
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

fprintf('\nThis will test color detection:\n');
fprintf('- RED: Stop 1 second\n');
fprintf('- BLUE: Stop and beep 2 times\n');
fprintf('- GREEN: Stop and beep 3 times\n\n');

fprintf('Place colored papers in front of robot\n');
input('Press Enter to start...', 's');

fprintf('\nMonitoring colors... (Press Ctrl+C to stop)\n\n');

last_color = 0;

try
    while true
        % Read color sensor
        color = brick.ColorCode(1);

        % Only respond when color changes
        if color ~= last_color && color > 0

            % Get color name
            switch color
                case COLOR_BLACK
                    color_name = 'BLACK';
                case COLOR_BLUE
                    color_name = 'BLUE';
                case COLOR_GREEN
                    color_name = 'GREEN';
                case COLOR_YELLOW
                    color_name = 'YELLOW';
                case COLOR_RED
                    color_name = 'RED';
                case COLOR_WHITE
                    color_name = 'WHITE';
                otherwise
                    color_name = sprintf('UNKNOWN (%d)', color);
            end

            fprintf('Detected: %s\n', color_name);

            %% RESPOND TO COLORS
            if color == COLOR_RED
                % RED: Stop for 1 second
                fprintf('  -> RED: Stopping for 1 second\n');
                brick.beep();
                pause(1);
                fprintf('  -> Continuing\n\n');

            elseif color == COLOR_BLUE
                % BLUE: Stop and beep 2 times
                fprintf('  -> BLUE: Beeping 2 times\n');
                brick.beep();
                pause(0.5);
                brick.beep();
                pause(0.5);
                fprintf('  -> Done\n\n');

            elseif color == COLOR_GREEN
                % GREEN: Stop and beep 3 times
                fprintf('  -> GREEN: Beeping 3 times\n');
                brick.beep();
                pause(0.5);
                brick.beep();
                pause(0.5);
                brick.beep();
                pause(0.5);
                fprintf('  -> Done\n\n');
            end

            last_color = color;
        end

        pause(0.2);
    end

catch ME
    if ~strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
        fprintf('\nStopped\n');
    end
end

fprintf('\n========================================\n');
fprintf('Color test complete!\n');
fprintf('========================================\n');
brick.beep();
