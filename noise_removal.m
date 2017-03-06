close all
clear
clc
fontSize=15;

%reading image
grayImage = imread('cameraman.tif');
[rows columns numberOfColorBands] = size(grayImage);

%converting to grayscale
if numberOfColorBands > 1
grayImage = rgb2gray(grayImage);
end
subplot(2, 3, 1);
imshow(grayImage, [0 255]);
title('Original Image', 'FontSize', fontSize);

set(gcf, 'units','normalized','outerposition',[0 0 1 1]); % Maximize figure.

%noise generation
rowVector = (1 : rows)';
period = 10; % 20 rows
amplitude = 0.5; % Magnitude of the ripples.
offset = 1 - amplitude; 
cosVector = amplitude * (1 + cos(2 * pi * rowVector / period))/2 + offset;
ripplesImage = repmat(cosVector, [1, columns]);
subplot(2, 3, 2);
maxValue = max(max(ripplesImage));
imshow(ripplesImage, [0 maxValue]);
axis on;
title('noise', 'FontSize', fontSize);

%adding noise to image
grayImage = ripplesImage .* double(grayImage);

subplot(2, 3, 3);
imshow(grayImage, [0 255]);
axis on;
title('Original Image with Periodic noise', 'FontSize', fontSize);

% Computing 2D fft.
frequencyImage = fftshift(fft2(grayImage));

% Taking log magnitude
amplitudeImage = log(abs(frequencyImage));
minValue = min(min(amplitudeImage));
maxValue = max(max(amplitudeImage));
subplot(2, 3, 4);
imshow(amplitudeImage, []);
axis on;
amplitudeThreshold = 10.5;
brightSpikes = amplitudeImage > amplitudeThreshold; % Binary image.
figure
imshow(brightSpikes);
axis on;
brightSpikes(115:143, :) = 0;
figure
imshow(brightSpikes);
title('Bright spikes other than central spike', 'FontSize', fontSize);

%removing the lower half
[m n]=size(frequencyImage);
frequencyImage((m/2)+2:m,:)=0;

% Filtering the spectrum.
frequencyImage(brightSpikes) = 0;
a=frequencyImage;

%%reconstruction
row_counter=m;
for i=2:(m/2)
    a(row_counter,1)=conj(a(i,1));
row_counter = row_counter - 1;
end

row_counter = ( m/2 ) + 1;

for i=(m/2)+1:m
    column_counter=n;
    for j=2:(n/2)
        a(i,j)=conj(a(row_counter,column_counter));
        column_counter=column_counter - 1;
    end
    row_counter=row_counter - 1;
end

row_counter=m;
column_counter=n;
for i=2:(m/2)+1
    column_counter=n;
    for j=2:(n/2)+1
        a(row_counter,column_counter)=conj(a(i,j));
        column_counter=column_counter - 1;
    end
    row_counter=row_counter - 1;
end

figure;
imshow(mat2gray(log(1+abs(a))));


z=ifft2(a);
q=uint8(abs(z));
figure
imshow(q);
