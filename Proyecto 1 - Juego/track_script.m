close all; clear all; clc;
celdas = imread('celdas-2.0.png');
[celdas_rows, celdas_cols, ~] = size(celdas);
character = imread('character-2.0.png');
[char_rows, char_cols, ~] = size(character);

offset_x = char_cols-1;
offset_y = char_rows-1;
cel_char = celdas;

limit_pos_x = celdas_cols/char_cols-1;
limit_pos_y = celdas_rows/char_rows-1;

pos_x = 0;
pos_y = 0;
cambio = 0;
able = 0;

cam = ipcam('http://192.168.1.12:8080/video');
img = snapshot(cam);
[rows, cols, depth] = size(img);

center_x = cols/2;
center_y = rows/2;
offset_center_x = 120;
offset_center_y = 100;

while 1
    
    img = snapshot(cam);

    imRed = img(:,:,1) > 130; imGreen = img(:,:,2) < 50; imBlue = img(:,:,3) < 50;
    img_bin = and(and(imRed, imGreen), imBlue);
    img_bin = bwareaopen(img_bin, 500);
    
    [bw, lab_num] = bwlabel(img_bin, 4);
    labels = zeros(1, lab_num);
    for i = 1 : lab_num
        labels(i) = sum(bw(:) == i);
    end
    [~, max_ind] = max(max(labels));
    
    
    if max_ind
        bw_clean = bw;
        bw_clean(bw ~= max_ind) = 0;
        
        stats = regionprops(bw_clean, 'BoundingBox', 'Centroid');
        bb = stats(1).BoundingBox;
        bc = stats(1).Centroid;
        current_coordinate_x = bc(1,1);
        current_coordinate_y = bc(1,2);
        
        centroid = zeros(rows, cols);
        centroid = insertShape(centroid, 'FilledCircle',[current_coordinate_x,current_coordinate_y,40],'LineWidth',5,'Color', 'white');
        
        if (current_coordinate_x > center_x + offset_center_x) && able == 1 && pos_x < limit_pos_x
            pos_x = pos_x + 1;
            able = 0;
            disp('Derecha');
            cambio = 1;
        elseif (current_coordinate_x < center_x - offset_center_x) && able == 1 && pos_x > 0
            pos_x = pos_x - 1;
            able = 0;
            disp('Izquierda');
            cambio = 1;
        elseif (current_coordinate_y > center_y + offset_center_y) && able == 1 && pos_y < limit_pos_y
            pos_y = pos_y + 1;
            able = 0;
            disp('Abajo');
            cambio = 1;
        elseif (current_coordinate_y < center_y - offset_center_y) && able == 1 && pos_y > 0
            pos_y = pos_y - 1;
            able = 0;
            disp('Arriba');
            cambio = 1;
        elseif current_coordinate_x < center_x + offset_center_x && current_coordinate_x > center_x - offset_center_x && current_coordinate_y < center_y + offset_center_y && current_coordinate_y > center_y - offset_center_y
            able = 1;
            disp('Centro');
        end
        
        if cambio == 1
            cel_char = celdas;
            for i = 1 : char_rows
                for j = 1 : char_cols
                    cel_char(i+(offset_y*pos_y), j+(offset_x*pos_x), :) = character(i,j, :);
                end
            end
            cambio = 0;
        end
        
        if able == 1
            object_and_center = insertShape(centroid,'Rectangle',[(center_x - offset_center_x) (center_y - offset_center_y) (offset_center_x*2) (offset_center_y*2)],'LineWidth',5,'Color','green');
        else
            object_and_center = insertShape(centroid,'Rectangle',[(center_x - offset_center_x) (center_y - offset_center_y) (offset_center_x*2) (offset_center_y*2)],'LineWidth',5,'Color','red');
        end
                
        figure(1);
        subplot(1,2,1);
        imshow(cel_char);
        
        subplot(1,2,2);
        imshow(object_and_center);
    end
    
end