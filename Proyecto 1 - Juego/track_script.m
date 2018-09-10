while 1

img = imread('http://192.168.1.12:8080/shot.jpg');
[rows, columns, depth] = size(img);
for i = 1 : rows
   for j = 1 :  columns
       if  img(i,j,1) < 150 || img(i,j,2) > 100 || img(i,j,3) > 100
           img(i,j,:) = 0;
       end
   end    
end
diff_im = imsubtract(img(:,:,1), rgb2gray(img));
diff_im = medfilt2(diff_im,[3,3]);
diff_im = imbinarize(diff_im);
diff_im = bwareaopen(diff_im, 300);
[bw, lab_num] = bwlabel(diff_im, 4);
labels = zeros(1, lab_num);
for i = 1 : lab_num
    labels(i) = sum(bw(:) == i);
end
[~, max_ind] = max(max(labels));
bw_clean = bw;
bw_clean(bw ~= max_ind) = 0;

stats = regionprops(bw_clean, 'BoundingBox', 'Centroid');


figure(1); imshow(bw_clean);

hold on

for object = 1 : length(stats)
    bb = stats(object).BoundingBox;
    bc = stats(object).Centroid;
    
    rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2)
    plot(bc(1), bc(2), '-m+')
end

hold off


end