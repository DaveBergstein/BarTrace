function vid = findByImgProcessingA(vid, plateRadius)
% findByImgProcessingA Find plate in each frame using image processing.
%   obj = findByImageProcessingA(obj) prompt user to define plate radius
%   obj = findByImageProcessingA(obj), plateRadius) The processing is based
%   around imfindcir. Processing each frame this way is slow and not 100%
%   accurate, but it is useful as a starting point for labeling the videos.

%% Get Radius
if nargin == 1
    halfWay = int32(vid.vidLength/2); % Get a frame
    imshow(vid.vid(halfWay).cdata) % Show the frame
    rect = getrect; % Ask user for the bounding box
    vid.plateRadius = (rect(3)+rect(4))/4; % estimate radius
elseif nargin == 2
    vid.plateRadius = plateRadius;
else
    warning("too many inputs")
end
rmin = int32(0.85*vid.plateRadius);   %perspective will modify radius slightly
rmax = int32(1.15*vid.plateRadius);   %perspective will modify radius slightly

%% Detect Plate
for k = 1:vid.vidLength
    disp("processed frame " + k + " out of " + vid.vidLength) % get a sense of progress
    img = vid.vid(k).cdata;
    %saturate and threshhold (plates are dark, so wash out what's bright)
    img_threshold = 2*double(img)/256;
    img_threshold(img_threshold>1) = 1;
    %take the value channel (plates are dark, lack color)
    imgHSV = rgb2hsv(img_threshold);
    imgGray = imgHSV(:,:,3);
    %get the strongest center
    [center,~] = imfindcircles(imgGray,[rmin rmax], ...
        'Method',"TwoStage","ObjectPolarity","dark", ...
        "Sensitivity",0.95);
    if isempty(center)
        vid.centers(k,1:2) = [0  0];  % plate not found
        if k ~= 1                     % take the last one found (unless it's the first frame)
            vid.centers(k,1:2) = vid.centers(k-1,1:2);
        end
    else
        vid.centers(k,1:2) = center(1,:); % take the first (strongest) match
    end
end

end