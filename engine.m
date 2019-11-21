% The Simple Game Engine is a class from object-oriented programming.
% If you are unfamiliar with object oriented programming, here is a quick
% crash course:
%
% Classes are a higher level of organizing programs beyond functions, they
% group together the functions (called methods) and variables (properties)
% of whatever it is you are trying to do. When you make a variable (called
% an object) from a class, it has all the properties from that class
% bundled together. This mimics how we naturally categorize things in real
% life. For example, cats are a class of animals, methods are the things a
% cat can do (e.g. pounce, meow, etc), properties describe a cat (e.g.
% color, age, location, etc), and objects  are individual cats (where each
% of the properties has a set value).
%
% The one extra bit of syntax you need to understand what's going on below
% is how to access properties of an object:
% Property "prop" of object "obj" is "obj.prop"

% The simpleGameEngine class inherets from the handle class because we
% want the game objects to be updated by their methods, specifically
% my_figure and my_image
classdef engine < handle
    properties
        sprites = {}; % color data of the sprites
        sprites_transparency = {}; % transparency data of the sprites
        sprite_width = 0;
        sprite_height = 0;
        canvas_width = 0;
        canvas_height = 0;
        my_figure; % figure identifier
        my_image;  % image data
        key_pressed = "";
        last_pressed = "";
    end
    
    methods
        function obj = engine(sprites_fname, sprite_height, sprite_width, canvas_height, canvas_width)
            % simpleGameEngine
            % Input: 
            %  1. File name of sprite sheet as a character array
            %  2. Height of the sprites in pixels
            %  3. Width of the sprites in pixels
            %  4. (Optional) Zoom factor to multiply image by in final figure (Default: 1)
            %  5. (Optional) Background color in RGB format as a 3 element vector (Default: [0,0,0] i.e. black)
            % Output: an SGE scene variable
            % Note: In RGB format, colors are specified as a mixture of red, green, and blue on a scale of 0 to 255. [0,0,0] is black, [255,255,255] is white, [255,0,0] is red, etc.
            % Example:
            %     	my_scene = simpleGameEngine('tictactoe.png',16,16,5,[0,150,0]);
            
            % load the input data into the object
            obj.sprite_width = sprite_width;
            obj.sprite_height = sprite_height;
            obj.canvas_width = canvas_width;
            obj.canvas_height = canvas_height;

            % read the sprites image data and transparency
            [sprites_image, ~, transparency] = imread(sprites_fname);
            sprites_image = sprites_image + 30;
            
            % determine how many sprites there are based on the sprite size
            % and image size
            sprites_size = size(sprites_image);
            sprite_row_max = (sprites_size(1)+1)/(sprite_height+1);
            sprite_col_max = (sprites_size(2)+1)/(sprite_width+1);
            
            % Make a transparency layer if there is none (this happens when
            % there are no transparent pixels in the file).
            if isempty(transparency)
                transparency = 255*ones(sprites_size,'uint8');
            else
                % If there is a transparency layer, use repmat() to
                % replicate is to all three color channels
                transparency = repmat(transparency,1,1,3);
            end
            
            % loop over the image and load the individual sprite data into
            % the object
            for r=1:sprite_row_max
                for c=1:sprite_col_max
                    r_min = sprite_height*(r-1)+r;
                    r_max = sprite_height*r+r-1;
                    c_min = sprite_width*(c-1)+c;
                    c_max = sprite_width*c+c-1;
                    obj.sprites{end+1} = sprites_image(r_min:r_max,c_min:c_max,:);
                    obj.sprites_transparency{end+1} = transparency(r_min:r_max,c_min:c_max,:);
                end
            end
        end
        
        function drawScene(obj, background_sprites, foreground_sprites, foreground_zoom)
            % draw_scene 
            % Input: 
            %  1. an SGE scene, which gains focus
            %  2. A matrix of sprite IDs, the arrangement of the sprites in the figure will be the same as in this matrix
            %  3. (Optional) A second matrix of sprite IDs of the same size as the first. These sprites will be layered on top of the first set.
            % Output: None
            % Example: The following will create a figure with 3 rows and 3 columns of sprites
            %     	drawScene(my_scene, [4,5,6;7,8,9;10,11,12], [1,1,1;1,2,1;1,1,1]);
            
            background_sprites = flipud(background_sprites);
            foreground_sprites = flipud(foreground_sprites);
            foreground_zoom = flipud(foreground_zoom);

            scene_size = size(background_sprites);

            num_rows = scene_size(1);
            num_cols = scene_size(2);
            
            % Error checking: make sure the bg and fg are the same size
            if ~isequal(size(background_sprites(:,:,1)), size(foreground_sprites))
                error('Background and foreground matrices of scene must be the same size.')
            end

            if ~isequal(size(foreground_sprites), size(foreground_zoom))
                error('Foreground and its room matrices must be the same size')
            end
            
            if num_rows > obj.canvas_height
                num_rows = obj.canvas_height;
            end 
            if num_cols > obj.canvas_width
                num_cols = obj.canvas_width;
            end

            % initialize the scene_data array to the correct size and type
            scene_data = uint8(background_sprites); % zeros(obj.canvas_height, obj.canvas_width, 3, 'uint8');
            
            % loop over the rows and colums of the tiles in the scene to
            % draw the sprites in the correct locations
            for tile_row = 1:num_rows
                for tile_col = 1:num_cols
                    % Save the id of the current sprite(s) to make things
                    % easier to read later  
                    reversed = 0;                  
                    fg_sprite_id = foreground_sprites(tile_row,tile_col);

                    if fg_sprite_id == 0
                        continue
                    end

                    if fg_sprite_id < 0
                        fg_sprite_id = 0-fg_sprite_id;
                        reversed = 1;
                    end
                    
                    % layer on the second sprite
                    transparency = obj.sprites_transparency{fg_sprite_id};
                    tile_data = obj.sprites{fg_sprite_id} .* (transparency/255);
                    zoom_factor = foreground_zoom(tile_row, tile_col);
                    tile_data = imresize(tile_data, zoom_factor, 'nearest');
                    transparency = imresize(transparency, zoom_factor, 'nearest');
                    if reversed == 1
                        tile_data = fliplr(tile_data);
                        transparency = fliplr(transparency);
                    end
                    tile_width = obj.sprite_width * zoom_factor;
                    tile_height = obj.sprite_height * zoom_factor;
                    rmin = tile_row - tile_height + 1; % obj.sprite_height*(tile_row-1);
                    rmax = tile_row; % obj.sprite_height*(tile_row-1);
                    cmin = tile_col - floor(tile_width/2) + 1; % obj.sprite_width*(tile_col-1);
                    cmax = tile_col + floor(tile_width/2);
                    
                    if rmin < 1
                        rmin = 1;
                        tile_data = tile_data(end - (rmax - rmin): end, :, :);
                        transparency = transparency(end - (rmax - rmin): end, :, :);
                    end
                    if cmin < 1
                        cmin = 1;
                        tile_data = tile_data(:, end - (cmax - cmin): end, :);
                        transparency = transparency(:, end - (cmax - cmin): end, :);
                    end
                    if cmax > num_cols
                        excess = cmax - num_cols;
                        cmax = num_cols;
                        tile_data = tile_data(:, 1: end - excess, :);
                        transparency = transparency(:, 1: end - excess, :);
                    end
                    scene_data(rmin:rmax, cmin:cmax, :) = tile_data + scene_data(rmin:rmax, cmin:cmax, :) .* (1 - transparency);
                end
            end
            
            big_scene_data = scene_data(1:num_rows, 1:num_cols, :); %imresize(scene_data,obj.zoom,'nearest');
            
            if isempty(obj.my_figure) || ~isvalid(obj.my_figure)
                % inititalize figure
                close('all');
                obj.my_figure = figure();
                
                set(obj.my_figure, 'KeyPressFcn', @keyPressed);
                set(obj.my_figure, 'KeyReleaseFcn', @keyReleased);
                
                % actually display the image to the figure
                obj.my_image = imshow(big_scene_data,'InitialMagnification', 100);
                
            elseif isempty(obj.my_image)  || ~isprop(obj.my_image, 'CData') || ~isequal(size(big_scene_data), size(obj.my_image.CData))
                % Re-display the image if its size changed
                figure(obj.my_figure);
                obj.my_image = imshow(big_scene_data,'InitialMagnification', 100);
            else
                % otherwise just update the image data
                set(obj.my_image, 'CData', big_scene_data);
                drawnow;
            end

            function keyPressed(hObject, ~, ~)
                key = get(hObject,'CurrentKey');
                if ~strcmp(obj.key_pressed, key) && obj.key_pressed ~= ""
                    obj.last_pressed = obj.key_pressed;
                end
                obj.key_pressed = key;
            end

            function keyReleased(hObject, ~, ~)
                key = get(hObject, 'CurrentKey');
                if strcmp(obj.key_pressed, key) && obj.last_pressed ~= ""
                    obj.key_pressed = obj.last_pressed;
                    obj.last_pressed = "";
                elseif strcmp(obj.last_pressed, key)
                    obj.last_pressed = "";
                else
                    obj.key_pressed = "";
                end
            end
        end

        function [] = closeWindow(obj)
            close(obj.my_figure);
        end
    end
end