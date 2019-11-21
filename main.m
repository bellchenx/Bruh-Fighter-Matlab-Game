%% initialization
clc
clear
close('all');
timer = tic;

% overall variables
idx = 0;
frame_rate = 30;
h = 500;
w = 1000;
boss = 0;
key = "";
scene = engine('retro_images/FINAL3.png', 31, 23, h, w);
[background, ~, ~] = imread('retro_images/city_background.png');
background = imresize(background, 5, 'nearest');
background = flipud(background);
background = background - 120;
foreground = zeros(h, w);
foregroundZoom = ones(h, w);

% characters
c1 = character(1, w, h);
c2 = character(2, w, h);

%% start scene
tic
while true
    time = toc;
    if time > (1/frame_rate) || idx == 0
        % initialize canvas
        foreground = zeros(h, w);

        % update user input
        c1.startAction(key);
        c1.duringJump(scene);

        % update game status
        AI(c1, c2);
        c1.updateStatus();
        c2.updateStatus();

        % attack detection
        c1.attackDetection(c2);
        c2.attackDetection(c1);

        % boundary check
        c1.boundaryCheck();
        c2.boundaryCheck();
        
        [foreground, foregroundZoom] = c1.updateScene(foreground, foregroundZoom);
        [foreground, foregroundZoom] = c2.updateScene(foreground, foregroundZoom);

        % draw the frame
        scene.drawScene(background, foreground, foregroundZoom);

        % read user input
        figure(scene.my_figure);
        key = scene.key_pressed;

        % display health
        clc;
        fprintf("          You [");
        hp1 = floor(c1.hp/2);
        for i=1:hp1
            fprintf("O");
        end
        for i=1:(25-hp1)
            fprintf(" ");
        end
        fprintf("]\n");
        if boss == 0
            fprintf("   Little boy [");
        else
            fprintf("  BIG BROTHER [");
        end
        r = 25;
        if boss == 1
            r = 50;
        end
        hp2 = floor(c2.hp/2);
        for i=1:hp2
            fprintf("O");
        end
        for i=1:(r-hp2)
            fprintf(" ");
        end
        fprintf("]\n");
        
        % game over check
        if c1.hp <= 0
            clc;
            fprintf("GAME OVER: YOU DIED.\n");
            pause(3);
            break;
        elseif c2.hp <= 0 && boss == 0
            clc;
            fprintf("YOU WIN!\n");
            pause(1);
            clc;
            fprintf("HIS BROTHER IS COMING!\n");
            pause(2);
            clc;
            fprintf("Ready?\n");
            pause(1);
            clc;
            boss = 1;
            c2 = character(3, w, h);
            c1.x = 50;
            c1.direction = 1;
            close('all');
        elseif c2.hp <= 0 && boss == 1
            clc;
            fprintf("YOU WIN!\n");
            pause(1);
            clc;
            fprintf("THANKS FOR PLAYING!\n");
            pause(2);
            clc;
            fprintf("ENGR 1181 SDP TEAM I\n");
            pause(2);
            clc;
            break;
        end
        idx = idx + 1;
        tic;
    end

    % exit trigger
    if key == "escape" || key == "q"
        break
    end
end

close('all');