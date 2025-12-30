function ampul_kalem_olcum(img)

gray = rgb2gray(img);

bw = imbinarize(gray,'adaptive','ForegroundPolarity','dark','Sensitivity',0.45);
bw = imfill(bw,'holes');
bw = bwareaopen(bw,1000);

stats = regionprops(bw,'Area','BoundingBox','MajorAxisLength','Centroid');

[~,idx] = sort([stats.Area]);
stats = stats(idx);

kalem = stats(1);
ampul = stats(end);

kalem_gercek_mm = 24; % referans
olcek = kalem_gercek_mm / kalem.BoundingBox(3);

kalem_w = kalem.BoundingBox(3)*olcek;
kalem_h = kalem.BoundingBox(4)*olcek;

ampul_h = ampul.BoundingBox(4)*olcek;
ampul_d = ampul.MajorAxisLength*olcek;

figure, imshow(img), hold on
rectangle('Position',kalem.BoundingBox,'EdgeColor','g','LineWidth',2)
rectangle('Position',ampul.BoundingBox,'EdgeColor','r','LineWidth',2)

text(kalem.Centroid(1),kalem.Centroid(2), ...
    sprintf('Kalem traşı\n%.1f x %.1f mm',kalem_w,kalem_h), ...
    'Color','g','FontSize',10,'FontWeight','bold')

text(ampul.Centroid(1),ampul.Centroid(2), ...
    sprintf('Ampul\nH=%.1f mm\nD=%.1f mm',ampul_h,ampul_d), ...
    'Color','r','FontSize',10,'FontWeight','bold')

hold off
end