%% Test Set

%% Test1
disp("Test that starting script runs")
StartHere
close all

%% Test2
disp("Import video")
vid = liftVid("DaveShort.mp4");
assert(vid.frameSize(1) == 1280)
assert(vid.frameSize(2) == 720)
close all

%% Test3
disp("check Dave Short position")
vid = liftVid("DaveShort.mp4");
vid.tracePlate(false, false, "none")
assert(vid.pos(30,1) > 350)
assert(vid.pos(30,1) < 400)
assert(vid.pos(30,2) > 750)
assert(vid.pos(30,2) < 800)
close all

%% Test4
disp("check Randy Short position")
vid = liftVid("RandyShort.mp4");
vid.tracePlate(false, false, "none")
assert(vid.pos(25,1) > 325)
assert(vid.pos(25,1) < 375)
assert(vid.pos(25,2) > 650)
assert(vid.pos(25,2) < 700)
close all

%% Test5
disp("check that result is saved")
delete("result1.avi");
vid = liftVid("RandyShort.mp4");
vid.tracePlate(false, true, "result1.avi")
% Check that files were created
assert(exist("result1.avi", "file") == 2)
close all

%% Test7
disp("Check image processing algorithm")
centers = findByImgProcessing("RandyShort.mp4", 109);
assert(centers(25,1) > 325)
assert(centers(25,1) < 375)
assert(centers(25,2) > 650)
assert(centers(25,2) < 700)
close all

%% Test 7a
disp("test that fails to check testing")
x = 1;
y = 2;
assert(x == y)
close all

%% Test6
disp("Check analysis script")
%Analyze2ndPull
close all
