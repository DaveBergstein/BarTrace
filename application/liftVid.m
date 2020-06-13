classdef liftVid < handle
    %liftVid Read and analyze a weightlifting video frame by frame.
    %   vid = liftVid("file.mp4"); 
    %
    % This is the main class definition for running BarTrace.
    
    properties
        vObj = 0;               % video object
        frameSize = [0 0]       % frame size
        numFrames = 0;          % number of frames
        radius = 0;             % avg radius of the plate in pixels    
        pos = zeros([],3);      % center of plate and radius in each frame
        model = load("TrainedNNB.mat"); % trained neural net
    end
    
    methods
        function obj = liftVid(fileName)
            %liftVid Construct an instance and open the video file.
            %   obj = liftVid(fileName) 
            if nargin == 0
                [fileName, path] = uigetfile("*.mp4","Select video file");
                fileName = string(path) + fileName;
            elseif nargin > 1
                error('Expected 0 or 1 inputs');
            end
            obj.vObj = VideoReader(fileName);
            obj.frameSize = [obj.vObj.Height obj.vObj.Width];
        end
        
        function frame = processNextFrame(obj)
            %processNextFrame
            if isa(obj.vObj,"VideoReader") && hasFrame(obj.vObj)
                
                % read frame
                obj.numFrames = obj.numFrames + 1;
                cdata = readFrame(obj.vObj);
                
                % find plate
                trainedSize = obj.model.detector.TrainingImageSize;
                imSmall = imresize(cdata,trainedSize);
                [bboxes,scores] = detect(obj.model.detector,imSmall);
                if ~isempty(bboxes)
                    [~,idx] = max(scores);
                    box = bboxes(idx,1:4);
                    x = box(1) * obj.frameSize(2)/trainedSize(2);
                    y = box(2) * obj.frameSize(1)/trainedSize(1);
                    w = box(3) * obj.frameSize(2)/trainedSize(2);
                    h = box(4) * obj.frameSize(1)/trainedSize(1);
                    position = [(x+w/2) (y+h/2) ((w+h)/4)]; %[x y r]
                    obj.pos(obj.numFrames,1:3) = position; % store position
                    obj.radius = median(obj.pos(1:obj.numFrames,3)); % median of all past radii
                else
                    % plate wasn't found
                    position = [1 1 10];
                    obj.pos(obj.numFrames,1:3) = position; % store position
                end
                
                % annotate
                frame = insertShape(cdata,'circle',position,'LineWidth',5,'Color',"red");
                trace = zeros(obj.numFrames,4); %add lines and dots to bar trace
                for k = 2:obj.numFrames % concatonate a list of all past centers
                    trace(k-1,1:4) = [obj.pos(k-1,1) obj.pos(k-1,2) obj.pos(k,1) obj.pos(k,2)];
                end
                if ~isempty(trace)
                    frame = insertShape(frame,'Line',trace,'LineWidth',2,'Color',"blue");
                    frame = insertShape(frame,"Circle",[trace(1:size(trace,1),[3 4]) 2*ones(size(trace,1),1)],"LineWidth",1,"Color",{"Yellow"});
                end
            else
                disp("no more frames")
            end
        end
        
        function tracePlate(obj,playit,saveit,saveName)
            % tracePlate Finds the plate in each frame
            %   tracePlate(obj,playit,saveit)
            %   playit = true will play the video
            %   saveit = true will save the video
            if isa(obj.vObj,"VideoReader") && hasFrame(obj.vObj)
                if playit
                    figure;
                    f = gca;
                end
                if saveit
                    v = VideoWriter(saveName,"MPEG-4");
                    open(v);
                end
            else
                disp("no more frames to process - try reloading")
                playit = false;
                saveit = false;
            end
            while hasFrame(obj.vObj)
                frame = obj.processNextFrame;
                if playit
                    imshow(frame, 'Parent', f);
                    drawnow;
                end
                if saveit
                    writeVideo(v,frame);
                end
            end
            if saveit
                close(v)
            end
        end
    end % end of methods
end % end of classdef