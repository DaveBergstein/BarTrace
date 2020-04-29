function centers = findByImgProcessing(fname, radius)
% findByImgProcessingA Find plate in each frame using image processing.
%   obj = findByImageProcessingA(obj) prompt user to define plate radius
%   obj = findByImageProcessingA(obj), plateRadius) 
%
%   This function uses imfindcir to find the plate in each frame. The 
%   algorithm isn't 100% accurate and is slow. But it works well for
%   labeling training sets for deep learning.

%% Show it?
playit = false;
if playit
    figure;
    f = gca;
end

%% Open video reader
vid = liftVid(fname);

%% Was radius passed in?
rmin = 0;
rmax = 0;
if nargin == 2
   vid.radius = radius;
   rmin = int32(0.85*vid.radius);   %perspective will modify radius slightly
   rmax = int32(1.15*vid.radius);
end

%% Process frame by frame
while isa(vid.vObj,"VideoReader") && hasFrame(vid.vObj)
    
    % read frame
    vid.numFrames = vid.numFrames + 1;
    img = readFrame(vid.vObj);
    k = vid.numFrames;
    
    % get radius if not already defined
    if vid.radius == 0
        imshow(img) % Show the frame
        rect = getrect; % Ask user for the bounding box
        vid.radius = (rect(3)+rect(4))/4; % estimate radius
        rmin = int32(0.85*vid.radius);   %perspective will modify radius slightly
        rmax = int32(1.15*vid.radius);
    end
    
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
        vid.pos(k,1:2) = [0  0];  % plate not found
        if k ~= 1                     % take the last one found (unless it's the first frame)
            vid.pos(k,1:2) = vid.pos(k-1,1:2);
        end
    else
        vid.pos(k,1:2) = center(1,:); % take the first (strongest) match
    end
    vid.pos(k,3) = vid.radius;
    
    %show it
    if playit
        frame = insertShape(img,'circle',vid.pos(k,1:3),'LineWidth',5,'Color',"red");
        imshow(frame, 'Parent', f);
        drawnow;
    end
    
end
centers = vid.pos;
end