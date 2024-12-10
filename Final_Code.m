clc
clear all;
close all;

% Initialize result matrix for 100 samples
num_samples = 100;
result_matrix = zeros(1, num_samples);
min_bad_spot_threshold = 700;  % Define a threshold for minimum bad spot pixels to consider as "bad"

% Loop through each sample image
for i = 1:num_samples
    
    file_name = fullfile('Final Data Set', sprintf('Sample%d.jpg', i));
    image = imread(file_name);
    gray_image = rgb2gray(image);

    blurred_image = imgaussfilt(gray_image, 2);
    threshold_value = 80;  % Adjust based on image characteristics
    binary_image = imbinarize(blurred_image, threshold_value / 255);


    binary_image = imcomplement(binary_image);


    num_white_pixels = sum(binary_image(:) == 1);

    % Classify wafer based on the number of white pixels (bad spots)
    if num_white_pixels >= min_bad_spot_threshold
        disp(['Sample ' num2str(i) ': Detected sufficient bad spots. Marked as bad wafer.']);
        result_matrix(i) = 0;  % Bad wafer
    else
        disp(['Sample ' num2str(i) ': Insufficient bad spots. Marked as good wafer.']);
        result_matrix(i) = 1;  % Good wafer
    end
    
    % Histogram display logic
    % Calculate histograms for both grayscale and binary images
    num_bins = 256;  % Number of bins for the histogram
    hist_original = imhist(gray_image, num_bins);
    
    % Convert binary image to uint8 for histogram calculation
    binary_image_uint8 = uint8(binary_image) * 255;  % Scale logical image to uint8
    hist_boundary = imhist(binary_image_uint8, num_bins);

    % Normalize the histograms to make them comparable
    hist_original = hist_original / sum(hist_original);
    hist_boundary = hist_boundary / sum(hist_boundary);

    % Compute the histogram difference
    hist_diff = abs(hist_original - hist_boundary);

    %----------------- PLOTTING OF HISTOGRAMS -------------------
    %{
    % Plot the histograms and their difference
    figure;

    % Plot original image histogram
    subplot(3, 1, 1);
    bar(hist_original);
    title('Histogram of Original Image');
    xlabel('Pixel Intensity');
    ylabel('Normalized Frequency');

    % Plot binary (boundary) image histogram
    subplot(3, 1, 2);
    bar(hist_boundary);
    title('Histogram of Boundary Image');
    xlabel('Pixel Intensity');
    ylabel('Normalized Frequency');

    % Plot the difference between histograms
    subplot(3, 1, 3);
    bar(hist_diff);
    title('Difference Between Histograms');
    xlabel('Pixel Intensity');
    ylabel('Difference');
    
    % Pause to allow viewing and then close the figure immediately
    pause(10);  % Adjust the time as needed for viewing
    close(gcf);
    %}
end

% Calculate the percentage of good and bad wafers
num_good = sum(result_matrix == 1);
num_bad = sum(result_matrix == 0);
total_samples = numel(result_matrix);

percent_good = (num_good / total_samples) * 100;
percent_bad = (num_bad / total_samples) * 100;

% Display the result matrix
disp('Result Matrix (1 = Good, 0 = Bad):');
disp(result_matrix);

% Plot a pie chart with percentage display
figure;
percentages = [percent_good, percent_bad];
labels = {sprintf('Good Wafers: %.1f%%', percent_good), sprintf('Bad Wafers: %.1f%%', percent_bad)};
pie(percentages, labels);
title('Percentage of Good and Bad Wafers in Batch');

% Save the pie chart as an image file
saveas(gcf, 'wafer_quality_pie_chart.jpg');
disp('Pie chart saved as "wafer_quality_pie_chart.jpg".');
