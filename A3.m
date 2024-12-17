%% Global Histogram Equalization for grayscale
function output_image = gray_histeq(input_image)

    [counts, ~] = imhist(input_image);
    cdf = cumsum(counts) / numel(input_image); % normalize
    % map intensity values using the CDF
    equalized = uint8(255 * cdf(double(input_image) + 1));

    output_image = reshape(equalized, size(input_image));
end

%% Local Histogram Equalization for grayscale
function output_image = local_gray_histeq(input_image, window_size)
    
    padded_image = padarray(input_image, [floor(window_size/2), floor(window_size/2)], 'symmetric');
    output_image = zeros(size(input_image), 'uint8');

    for i = 1:size(input_image, 1)
        for j = 1:size(input_image, 2)
            % extract
            local_region = padded_image(i:i+window_size-1, j:j+window_size-1);
            % histogram equalization
            [counts, ~] = imhist(local_region);
            cdf = cumsum(counts) / numel(local_region);
            % map intensity values
            equalized_region = uint8(255 * cdf(double(local_region) + 1));
            
            output_image(i, j) = equalized_region(floor(window_size/2) + 1, floor(window_size/2) + 1);
        end
    end
end

%% Global Histogram Equalization for RGB
function output_image = RGB_histeq(input_image)

    hsv_image = rgb2hsv(input_image);
    intensity_channel = hsv_image(:, :, 3);
    % equalize
    equalized_intensity = gray_histeq(uint8(intensity_channel * 255));
    % update HSV
    hsv_image(:, :, 3) = double(equalized_intensity) / 255;

    output_image = hsv2rgb(hsv_image);
end


%% Local Histogram Equalization for RGB
function output_image = local_RGB_histeq(input_image, window_size)
    % convert to HSV
    hsv_image = rgb2hsv(input_image);
    intensity_channel = hsv_image(:, :, 3); % V channel (luminance)
    % local histogram equalization on the V channel
    equalized_intensity = local_gray_histeq(uint8(intensity_channel * 255), window_size);
    % Update HSV
    hsv_image(:, :, 3) = double(equalized_intensity) / 255;

    output_image = hsv2rgb(hsv_image);
end

%%
gray_image = rgb2gray(imread('lena.png'));
color_image = imread('lena.png');

% grayscale
global_eq_gray = gray_histeq(gray_image);
window_size = 64;
local_eq_gray = local_gray_histeq(gray_image, window_size);

% rgb
global_eq_rgb = RGB_histeq(color_image);
local_eq_rgb = local_RGB_histeq(color_image, window_size);

% results
figure;
subplot(2, 4, 1), imshow(gray_image), title('Original Grayscale');
subplot(2, 4, 2), imshow(global_eq_gray), title('Global HistEq Grayscale');
subplot(2, 4, 3), imshow(local_eq_gray), title('Local HistEq Grayscale');

built_in_gray = histeq(gray_image);
subplot(2, 4, 4), imshow(built_in_gray), title('Built-in HistEq Grayscale');

subplot(2, 4, 5), imshow(color_image), title('Original RGB');
subplot(2, 4, 6), imshow(global_eq_rgb), title('Global HistEq RGB');
subplot(2, 4, 7), imshow(local_eq_rgb), title('Local HistEq RGB');

hsv_image = rgb2hsv(color_image);
equalized_v_channel = histeq(hsv_image(:, :, 3));
hsv_image(:, :, 3) = equalized_v_channel;
built_in_color = uint8(255 * hsv2rgb(hsv_image));
subplot(2, 4, 8), imshow(built_in_color), title('Built-in HistEq RGB');