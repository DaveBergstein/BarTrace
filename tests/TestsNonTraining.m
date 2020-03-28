%% Test Set


%% Test2
% Test that starting script runs
disp("Test2")

StartHere
close all

%% Test3
% Import video
disp("Test3")

vid = liftVid("\data\Data2020_02_18\2020_02_18_2_Trim.mp4");
vid.loadVideo;
assert(vid.vidLength == 189)
close all

%% Test4
% Find plate
disp("Test4")

vid = liftVid("\data\Data2020_02_18\2020_02_18_2_Trim.mp4");
plateRadius = 77;
vid.tracePlate("modelA", plateRadius)
% Check the position
assert(vid.centers(100,1) > 350)
assert(vid.centers(100,1) < 400)
assert(vid.centers(100,2) > 630)
assert(vid.centers(100,2) < 720)
close all

%% Test5
% Find plate
disp("Test5")

vid = liftVid("\data\Data2020_02_18\2020_02_18_2_Trim.mp4");
vid.tracePlate("modelB")
% Check the position
assert(vid.centers(100,1) > 350)
assert(vid.centers(100,1) < 400)
assert(vid.centers(100,2) > 630)
assert(vid.centers(100,2) < 720)
close all

%% Test6
% Find plate
disp("Test6")

vid = liftVid("\data\Data2020_02_18\2020_02_18_2_Trim.mp4");
vid.tracePlate("modelC")
% Check the position
assert(vid.centers(100,1) > 350)
assert(vid.centers(100,1) < 400)
assert(vid.centers(100,2) > 630)
assert(vid.centers(100,2) < 720)
close all

%% Test7
% Write results and video
disp("Test7")

vid = liftVid("\data\ForTesting\RandyShort.mp4");
vid.tracePlate("modelB")
vid.save("result1")
% Check that files were created
assert(exist("result1.mp4", "file") == 2)
close all

%% Test 8
% Try reading and processing frame-by-frame
vid = liftVid("\data\ForTesting\DaveShort.mp4");
vid.nextFrame = 0;
figure;
while vid.nextFrame >= 0
    disp("Processing" + vid.nextFrame);
    img = processFrameByFrame(vid);
    imshow(img);
end