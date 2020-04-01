classdef liftVid_working < handle
    %liftVid Read and analyze a weightlifting video.
    %   vid = liftVid("file.mp4"); 
    %
    % This is the main class definition for running BarTrace. 
    
    properties
        fileName = "";      % video file to load
        vidObj = 0;         % video object
        vid = 0;            % video data (todo: remove, redundant)
        vidWidth = 0;       % frame width
        vidHeight = 0;      % frame height
        vidLength = 0;      % number of frames
        plateRadius = 0;    % radius of the weightlifting plate in pixels    
        centers = 0;        % center of plate in each frame
        nextFrame = 0;      % next frame number to process
        model = 0;          % neural net
    end
    
    methods
        function obj = liftVid(fileName)
            %liftVid Construct an instance of this class.
            %   obj = liftVid(fileName) where fileName is the raw video
            %   file name
            if nargin == 0
                [fileName, path] = uigetfile("*.mp4","Select video file");
                obj.fileName = string(path) + fileName;
            elseif nargin == 1
                obj.fileName = fileName;
            else
                error('Expected 0 or 1 inputs');
            end
        end
        
        function frame = processFrameByFrame(obj)
            %processFrameByFrame Load and process the video frame-by-frame
            %instead of processing all at once (like most this classdef
            %assumes)
            if ~isa(obj.vidObj,"VideoReader")
                % open video
                obj.vidObj = VideoReader(obj.fileName);
                obj.vidHeight = obj.vidObj.Height;
                obj.vidWidth = obj.vidObj.Width;
                obj.vid = struct('cdata',zeros(obj.vidHeight,obj.vidWidth,3,'uint8'));
                obj.nextFrame = 1;
                obj.centers = zeros([],2);
                obj.model = load("trainedWithTrainingB.mat");
            end
            if hasFrame(obj.vidObj)
                % get frame
                k = obj.nextFrame;
                obj.vid(k).cdata = readFrame(obj.vidObj);
                % find plate
                trainedSize = obj.model.detector.TrainingImageSize;
                origSize = [obj.vidHeight obj.vidWidth];
                imgSmall = imresize(obj.vid(k).cdata,trainedSize);
                [bboxes,scores] = detect(obj.model.detector,imgSmall);
                if ~isempty(bboxes)
                    [~,idx] = max(scores);
                    box = bboxes(idx,1:4);
                    x = box(1) * origSize(2)/trainedSize(2);
                    y = box(2) * origSize(1)/trainedSize(1);
                    w = box(3) * origSize(2)/trainedSize(2);
                    h = box(4) * origSize(1)/trainedSize(1);
                    c1 = x+w/2;
                    c2 = y+h/2;
                    r = (w+h)/4;
                else
                    c1 = 0;
                    c2 = 0;
                    r = 0;
                end
                obj.centers(k,1:2) = [c1 c2];
                % annotate
                frame = insertShape(obj.vid(k).cdata,'circle',[c1 c2 r],'LineWidth',5,'Color',{"red"});
                %add lines and dots to bar trace
                trace = []; % todo: don't start line from scratch each time
                for k2 = 2:k % concatonate a list of all past centers
                    trace = vertcat(trace,[obj.centers(k2-1,1) obj.centers(k2-1,2) obj.centers(k2,1) obj.centers(k2,2)]);
                end
                if ~isempty(trace)
                    frame = insertShape(frame,'Line',trace,'LineWidth',2,'Color',{"blue"});
                    frame = insertShape(frame,"Circle",[trace(1:size(trace,1),[3 4]) 2*ones(size(trace,1),1)],"LineWidth",1,"Color",{"Yellow"});
                end
                obj.vid(k).cdata = frame;
                % advance counter
                obj.vidLength = k;
                obj.nextFrame = k + 1;
            else
                % if there are no more frames, close the video object
                obj.vidObj = 0;
                obj.nextFrame = -1;
                frame = obj.vid(end).cdata;
            end            
        end
        
        function loadVideo(obj)
            %loadVideo Load video data from a file.
            %   loadVideo(obj)
            if isa(obj.vidObj,"VideoReader")
                % already open, so close
                obj.vidObj = 0;
            end
            obj.vidObj = VideoReader(obj.fileName);
            obj.vidHeight = obj.vidObj.Height;
            obj.vidWidth = obj.vidObj.Width;
            obj.vid = struct('cdata',zeros(obj.vidHeight,obj.vidWidth,3,'uint8'));
            k = 1;
            while hasFrame(obj.vidObj)
                obj.vid(k).cdata = readFrame(obj.vidObj);
                k = k+1;
            end
            obj.vidLength = length(obj.vid);
            obj.centers = zeros(obj.vidLength,2);
            obj.vidObj = 0;
        end
        
        function tracePlate(obj, modelName, plateRadius)
            %tracePlace Traces the plate in the video.
            %   tracePlate(obj, ModelName) where ModelName is:
            %   "modelA":   Based on image processing
            %   "modelB":   CNN based on resnet50 + YOLO
            %   "modelC":   CNN based on resnet18 + YOLO
            obj.loadVideo;
            switch modelName
                case "modelB"   % refactor model prep into another method)
                    d = load("trainedWithTrainingB.mat");
                    detectByDeepLearning(obj, d);
                case "modelC"
                    d = load("trainedWithTrainingC.mat");
                    detectByDeepLearning(obj, d);
                otherwise
                    obj = findByImgProcessingA(obj, plateRadius);
            end
        end
        
        function annotate(obj)
            % annotate Add detected circle to video frame-by-frame
            %   annotate(obj)
            disp("annotating video")
            for k = 1:obj.vidLength
                img = obj.vid(k).cdata;
                %add circle
                c1 = obj.centers(k,1);
                c2 = obj.centers(k,2);
                r = obj.plateRadius;
                frame = insertShape(img,'circle',[c1 c2 r],'LineWidth',5,'Color',{"red"});
                %add lines and dots to bar trace
                trace = []; % todo: don't start line from scratch each time
                for k2 = 2:k % concatonate a list of all past centers
                    trace = vertcat(trace,[obj.centers(k2-1,1) obj.centers(k2-1,2) obj.centers(k2,1) obj.centers(k2,2)]);
                end
                if ~isempty(trace)
                    frame = insertShape(frame,'Line',trace,'LineWidth',2,'Color',{"blue"});
                    frame = insertShape(frame,"Circle",[trace(1:size(trace,1),[3 4]) 2*ones(size(trace,1),1)],"LineWidth",1,"Color",{"Yellow"});
                end
                obj.vid(k).cdata = frame;
            end
        end
        
        function play(obj)
            %showVid Play the video with centers shown.
            %   loadVideo(obj)
            implay(obj.vid)
        end
       
        function save(obj, saveName)
            % Save video with bounding circle superimposed on each frame
            v = VideoWriter(saveName,"MPEG-4");
            open(v);
            disp('started writing video file to disk')
            for k = 1:obj.vidLength
                frame = obj.vid(k).cdata;
                writeVideo(v,frame);
            end
            close(v)
            disp('finished writing video file to disk')
        end
        
    end % end of methods
end % end of classdef

function detectByDeepLearning(obj, d)
% detectByDeepLearning Use a trained model to find the plate in each frame.
%   detectByDeepLearning(obj, d) where obj is a liftVid object and d is a
%   pretrained detector object
    trainedSize = d.detector.TrainingImageSize;
    origSize = [obj.vidHeight obj.vidWidth];
    allRadii = zeros(obj.vidLength,1);
    disp('starting')
    for k = 1:obj.vidLength
        imgOrig = obj.vid(k).cdata;
        imgSmall = imresize(imgOrig,trainedSize);
        [bboxes,scores] = detect(d.detector,imgSmall);
        if ~isempty(bboxes)
            [~,idx] = max(scores);
            box = bboxes(idx,1:4);
            x = box(1) * origSize(2)/trainedSize(2);
            y = box(2) * origSize(1)/trainedSize(1);
            w = box(3) * origSize(2)/trainedSize(2);
            h = box(4) * origSize(1)/trainedSize(1);
            obj.centers(k,1:2) = [(x+w/2) (y+h/2)];
            allRadii(k) = (w+h)/4;
        else
            disp('empty!')
        end
    end
    obj.plateRadius = mean(allRadii);
end