# BarTrace

Application to track the path and speed of a barbell when weightlifting.

Started by Dave Bergstein (dbergstein@gmail.com)

View Examples/StartHere.mlx on File Exchange:  [![View BarTrace on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/75105-bartrace)

I'm learning to weightlift and find it helpful to see the path and speed of the barbell of my lifts. I also like playing with deep learning. Videos were taken at Grit City in the Bronx where I train (IG @concretejunglegritsc). Randy Triunfel (IG @thebarbellmasochist) is a competitive weightlifter and my coach. 

I first find the weight plate in the training videos using image processing with imfindcirle. My image processing often fails to find the plate and is slow. Nonetheless, the image processing was able to label most the training data correctly. I then used this labeled data to train a CNN with the final layers replaced by a YOLO network. The resulting neural network is more accurate and much faster than the image processing I used to label the data. Important caveat: the videos were all taken at the same gym (pre-pandemic) with either Randy or me, so there is very little training variety.

Pull Requests welcomed. Feel free to fork and use. I didn't include all the video data here given its size. 

[![DaveBergstein](https://circleci.com/gh/DaveBergstein/BarTrace.svg?style=svg)](https://app.circleci.com/pipelines/github/DaveBergstein/BarTrace)

### Project Organization
- application: production code including production model
- data: raw data, see readme files for credit & permission
- models: image processing and trained models
- training: code for training models
- exploring: area to explore
- tests: tests (currently excludes any training-related tests)
