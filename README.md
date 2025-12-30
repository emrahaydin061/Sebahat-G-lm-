% =========================================================================
% Proje: Nesne Ölçüm ve Boyutlandırma (Görüntü İşleme)
% Hazırlayan: SEBAHAT GÜLMÜŞ
% Referans Nesne: Standart LED Ampul (Çap: 6.0 cm)
% =========================================================================

clc; clear; close all;

%% 1. AYARLAR VE RESİM YÜKLEME
% Resim dosyasının adını buraya yazın (Örn: 'image.png')
dosyaAdi = 'image.png'; 

% Referans alınan ampulün gerçek çapi (cm cinsinden)
AMPUL_CAPI_CM = 6.0; 

% Resmi Oku
try
    img = imread(dosyaAdi);
catch
    error('Dosya bulunamadı! Lütfen resim adını kontrol edin.');
end

% Resmi ekrana sığacak şekilde biraz küçült (işlem hızını artırır)
img = imresize(img, 0.5); 
[rows, cols, ~] = size(img);

%% 2. GÖRÜNTÜ İŞLEME (NESNE TESPİTİ)
% Gri tonlamaya çevir
gray = rgb2gray(img);

% Gürültü azaltma (Gaussian Blur benzeri)
gray = imgaussfilt(gray, 2);

% Kenar Tespiti (Canny Metodu)
bw = edge(gray, 'canny', [0.05 0.2]);

% Kenarları birleştirip içlerini doldurma (Morfolojik işlemler)
se = strel('disk', 4);
bw = imdilate(bw, se);
bw = imfill(bw, 'holes');
bw = imerode(bw, se);

% Çok küçük parçaları (gürültüleri) temizle
bw = bwareaopen(bw, 1000);

%% 3. NESNELERİN ANALİZİ
% Bağlantılı bileşenleri bul (Regionprops)
stats = regionprops(bw, 'BoundingBox', 'Centroid', 'Extrema', 'Area');

% Nesneleri soldan sağa doğru sırala (Soldaki ilk nesne ampul olacak)
centroids = cat(1, stats.Centroid);
[~, sortIndex] = sort(centroids(:, 1));
stats = stats(sortIndex);

%% 4. ÖLÇÜM VE ÇİZİM
figure('Name', 'Nesne Ölçüm - SEBAHAT GÜLMÜŞ', 'NumberTitle', 'off');
imshow(img); hold on;

pixelPerCM = 0; % Oran değişkeni

for i = 1:length(stats)
    box = stats(i).BoundingBox;
    x = box(1); y = box(2); w = box(3); h = box(4);
    
    % Kutu çiz (Yeşil)
    rectangle('Position', [x, y, w, h], 'EdgeColor', 'g', 'LineWidth', 2);
    
    % --- REFERANS HESAPLAMA (İLK NESNE: AMPUL) ---
    if i == 1
        % Ampulün genişliğini piksel olarak al
        ampulGenislikPiksel = w;
        
        % 1 cm kaç piksel ediyor?
        pixelPerCM = ampulGenislikPiksel / AMPUL_CAPI_CM;
        
        % Ampul üzerine "REFERANS" yaz
        text(x, y-10, 'REFERANS (AMPUL)', 'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold');
        continue; % Ampulün üzerine ölçü yazma, döngüye devam et
    end
    
    % --- DİĞER NESNELERİ ÖLÇME ---
    genislikCM = w / pixelPerCM;
    yukseklikCM = h / pixelPerCM;
    
    % Ölçüleri nesnenin üzerine yaz
    label = sprintf('W: %.1f cm\nH: %.1f cm', genislikCM, yukseklikCM);
    text(x, y-25, label, 'Color', 'yellow', 'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', 'black');
    
    % Merkez noktayı işaretle
    plot(stats(i).Centroid(1), stats(i).Centroid(2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
end

%% 5. İSİM EKLEME
% Görüntünün en üstüne "SEBAHAT GÜLMÜŞ" yaz
text(20, 40, 'SEBAHAT GÜLMÜŞ', 'Color', 'cyan', 'FontSize', 24, 'FontWeight', 'bold', 'BackgroundColor', 'black');

hold off;
