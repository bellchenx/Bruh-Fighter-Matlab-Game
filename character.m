classdef character < handle
    properties
        retro = 1;
        defaultRetro = 1;
        zoom = 10;
        x = 1;
        y = 25;
        w = 1000;
        h = 500;
        dmg = 1;
        range = 100;
        reversed = 1; % only 1 or -1
        direction = 1;
        hp = 50;

        currentAction = 0;
        currentActionLength = 0;
        currentActionCounter = 0;

        actionRetroLeft = [];
        actionPosLeft = [];
        actionRetroRight = [];
        actionPosRight = [];
        actionRetroJump = [];
        actionPosJump = [];
        actionAttack = [];

        rightKey = 0;
        leftKey = 0;
        jumpKey = 0;
        attackKey = 0;
    end 

    methods
        function obj = character(num, w, h)
            if num == 1
                % Charactor 1
                obj.retro = 1;
                obj.defaultRetro = 1;
                obj.zoom = 10;
                obj.x = 100;
                obj.y = 25;
                obj.w = w;
                obj.h = h;
                obj.reversed = 1;
                obj.direction = 1;
                obj.dmg = 1.25;

                % Action 1: Move Left
                obj.actionRetroLeft = [2, 1];
                obj.actionPosLeft = [-50, -50];

                % Action 2: Move Right
                obj.actionRetroRight = [2, 1];
                obj.actionPosRight = [50, 50];

                % Action 3: Jump
                obj.actionRetroJump = [1, 3, 3, 1];
                obj.actionPosJump = [150, 75, -75, -150];

                % Action 4: Attack
                obj.actionAttack = [4, 5, 5, 1];

                % Key definition
                obj.leftKey = "leftarrow";
                obj.rightKey = "rightarrow";
                obj.jumpKey = "space";
                obj.attackKey = "f";
            end
            if num == 2
                % Charactor 2
                obj.retro = 6;
                obj.defaultRetro = 6;
                obj.zoom = 10;
                obj.x = 900;
                obj.y = 25;
                obj.w = w;
                obj.h = h;
                obj.reversed = -1;
                obj.direction = -1;
                obj.dmg = 0.3;

                % Action 1: Move Left
                obj.actionRetroLeft = [6, 7];
                obj.actionPosLeft = [-20, -20];

                % Action 2: Move Right
                obj.actionRetroRight = [6, 7];
                obj.actionPosRight = [20, 20];

                % Action 3: Jump
                obj.actionRetroJump = [6, 8, 8, 6];
                obj.actionPosJump = [150, 75, -75, -150];

                % Action 4: Attack
                obj.actionAttack = [9, 10, 10, 6];
            end
            if num == 3
                % Charactor 3
                obj.retro = 6;
                obj.defaultRetro = 6;
                obj.zoom = 20;
                obj.x = 900;
                obj.y = 25;
                obj.w = w;
                obj.h = h;
                obj.reversed = -1;
                obj.direction = -1;
                obj.dmg = 1.5;
                obj.range = 200;
                obj.hp = 100;

                % Action 1: Move Left
                obj.actionRetroLeft = [6, 6, 6, 6, 6, 7, 7, 7, 7, 7];
                obj.actionPosLeft = [-10, -10, -10, -10, -10, -10, -10, -10, -10, -10];

                % Action 2: Move Right
                obj.actionRetroRight = [6, 6, 6, 6, 6, 7, 7, 7, 7, 7];
                obj.actionPosRight = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10];

                % Action 3: Jump
                obj.actionRetroJump = [6, 6, 8, 8, 8, 8, 8, 8, 6, 6];
                obj.actionPosJump = [-10, 100, 50, 25, 5, -5, -25, -50, -90, 0];

                % Action 4: Attack
                obj.actionAttack = [6, 9, 10, 10, 9, 6];
            end
        end

        function startAction(obj, key)
            if obj.currentAction == 0
                obj.currentActionCounter = 1;
                if (isnumeric(key) && key == 1) || strcmp(key, obj.leftKey)
                    obj.currentAction = 1;
                    obj.direction = -1 * obj.reversed;
                    obj.currentActionLength = length(obj.actionRetroLeft);
                end
                if (isnumeric(key) && key == 2) || strcmp(key, obj.rightKey)
                    obj.currentAction = 2;
                    obj.direction = obj.reversed;
                    obj.currentActionLength = length(obj.actionRetroRight);
                end
                if (isnumeric(key) && key == 3) || strcmp(key, obj.jumpKey)
                    obj.currentAction = 3;
                    obj.currentActionLength = length(obj.actionRetroJump);
                end
                if (isnumeric(key) && key == 4) || strcmp(key, obj.attackKey)
                    obj.currentAction = 4;
                    obj.currentActionLength = length(obj.actionAttack);
                end
            end
        end

        function updateStatus(obj)
            if obj.currentAction ~= 0 && obj.currentActionCounter <= obj.currentActionLength
                % fprintf('Action is %i\n', obj.currentAction);
                if obj.currentAction == 1
                    obj.x = obj.x + obj.reversed * obj.actionPosLeft(obj.currentActionCounter);
                    obj.retro = obj.actionRetroLeft(obj.currentActionCounter);
                end
                if obj.currentAction == 2
                    obj.x = obj.x + obj.reversed * obj.actionPosRight(obj.currentActionCounter);
                    obj.retro = obj.actionRetroRight(obj.currentActionCounter);
                end
                if obj.currentAction == 3
                    obj.y = obj.y + obj.actionPosJump(obj.currentActionCounter);
                    obj.retro = obj.actionRetroJump(obj.currentActionCounter);
                end
                if obj.currentAction == 4
                    obj.retro = obj.actionAttack(obj.currentActionCounter);
                end
                obj.currentActionCounter = obj.currentActionCounter + 1;

            elseif obj.currentActionCounter > obj.currentActionLength
                obj.currentAction = 0;
                obj.currentActionCounter = 0;
                obj.retro = obj.defaultRetro;
            end
        end

        function duringJump(obj, scene)
            currentKey = scene.key_pressed;
            lastKey = scene.last_pressed;
            if (strcmp(lastKey, obj.leftKey) && strcmp(currentKey, obj.jumpKey)) || (strcmp(currentKey, obj.leftKey) && strcmp(lastKey, obj.jumpKey))
                obj.direction = -1 * obj.reversed;
                obj.x = obj.x - 50;
            elseif (strcmp(lastKey, obj.rightKey) && strcmp(currentKey, obj.jumpKey)) || (strcmp(currentKey, obj.rightKey) && strcmp(lastKey, obj.jumpKey))
                obj.direction = obj.reversed;
                obj.x = obj.x + 50;
            end
        end

        function boundaryCheck(obj)
            if obj.x < 1
                obj.x = 1;
            end
            if obj.x > obj.w
                obj.x = obj.w;
            end
            if obj.y < 1
                obj.y = 1;
            end
            if obj.y > obj.h
                obj.y = obj.h;
            end
        end


        function attackDetection(obj, character)
            dis = character.x - obj.x;
            attackRange = max(obj.range, character.range);
            if abs(dis) > attackRange
                return
            end
            if obj.currentAction ~= 4
                return
            end
            if character.currentAction == 3 && character.currentActionCounter >= 2 && character.currentActionCounter <= 3
                return
            end
            if dis * obj.direction <= -25
                return
            end
            character.hp = character.hp - obj.dmg;
        end

        function [foreground, foregroundZoom] = updateScene(obj, foreground, foregroundZoom)
            foreground(obj.y, obj.x) = obj.retro * obj.direction;
            foregroundZoom(obj.y, obj.x) = obj.zoom;
        end

    end

end