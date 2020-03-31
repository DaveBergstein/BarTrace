%% Test Set

%% Test1
disp("Test that starting script runs")
StartHere
close all

%% Test2
disp("Import video")
vid = liftVid("DaveShort.mp4");
vid.loadVideo;
assert(vid.vidLength == 62)
close all

%% Test3
disp("Find plate with model A")
vid = liftVid("RandyShort.mp4");
plateRadius = 200;
vid.tracePlate("modelA", plateRadius)
% Check the position
assert(vid.centers(25,1) > 325)
assert(vid.centers(25,1) < 375)
assert(vid.centers(25,2) > 650)
assert(vid.centers(25,2) < 700)
close all

%% Test4
disp("Find plate with model C")
vid = liftVid("RandyShort.mp4");
vid.tracePlate("modelC")
% Check the position
assert(vid.centers(25,1) > 325)
assert(vid.centers(25,1) < 375)
assert(vid.centers(25,2) > 650)
assert(vid.centers(25,2) < 700)
close all

%% Test5
disp("check that result is saved")
delete("result1.mp4");
vid = liftVid("RandyShort.mp4");
vid.tracePlate("modelC")
vid.annotate;
vid.save("result1")
% Check that files were created
assert(exist("result1.mp4", "file") == 2)
close all

%% Test6
disp("Try reading and processing frame-by-frame");
vid = liftVid("DaveShort.mp4");
vid.nextFrame = 0;
figure;
while vid.nextFrame >= 0
    disp("Processing" + vid.nextFrame);
    img = processFrameByFrame(vid);
    imshow(img);
end