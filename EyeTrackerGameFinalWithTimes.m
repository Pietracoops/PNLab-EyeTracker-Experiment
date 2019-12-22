%TESTING WITH UPDATES - WITH TRACKER AND MCGILL COMP

% Eye Tracker Game

%V6 - Eyetracker Integration
%Last updated 2017-02-19
%1.20

%Changes need to be made
%-Change Practice Codes
%-Copy changes in HandleCalib

%GO TO INITIALISATION FUNCTION TO ENTER PREFERENCES AND FOLDER PATHS

%Controls:
%CTRL + C -> hard stop
%Right Arrow key -> Proceed
%Left Arrow Key -> Repeat Interval of Pictures
%Q -> Quit (can only be used during picture showing)
%backspace -> Same
%tab -> Different


function EyeTrackerGameFinalWithTimes
clc 
clear all
close all

global G; 
    Initialisation();
% a play again loop
while 1
    
    %get_options(); % 
    Infoprompt();
    Intro();
    Instructions();
    EyeTrackerStartup();
    start_game();
    DisplayResults();
    ExcelWrite();
    % game is over when figure closes
    waitfor(G.fig)    
    
    % ask to play again 
    if ~play_again()
        return
    end
end

 function Initialisation()
%These are the Settings - Alter these as needed
global ScreenSize
global TimeBeforeStart
global FolderDomain
global MarkerDuration
global MarkerSize
global ImageDuration
global ExcelFilename
global ExcelFolder
global WaitTime
global TimeBeforeGameStart
global trackerId
global XEye
global YEye
global SameKey
global DifferentKey
global Time

%preferably dont change this unless you know what you're doing
XEye = zeros(88,3000);
YEye = zeros(88,3000);
Time = zeros(88,3000);
addpath(genpath('C:\Users\Attention 4\Desktop\McGill'));
ScreenSize = [1,1,1024,819.33];

trackerId = 'TT120-206-93500650';

%Time in between instructions if not skipped
WaitTime = 5;
%Time Before the game begins
TimeBeforeGameStart = 100;

SameKey = 'backspace';
DifferentKey = 'tab';

%Countdown time before image
TimeBeforeStart = 5;
%Folder to retrieve Pictures
FolderDomain = 'C:\Users\Attention 4\Desktop\McGill\McgillStuff\Pics\';

%Test
MarkerDuration = 1.5;
MarkerSize = 50;
%Make sure tracker points are also increased or risk exceeding matrix
%paramters for Image Duration. If you want to, I suggest scrolling up and
%changing the matrix of XEye YEye to 88,4000, or something larger than
%3000. If you want to Log these extra points make sure to do so in the
%excel document functions (ExcelEyeTrackerStorage).
ImageDuration = 10;

%Excel
ExcelFilename=('C:\Users\Attention 4\Desktop\McGill\ExcelDocs\_Template.xlsm');%Template to Open
ExcelFolder = 'C:\Users\Attention 4\Desktop\McGill\ExcelDocs\';%Where to save Excel docs

return


function EyeTrackerStartup()
     global trackerId
       
       addpath('functions');
       addpath('../tetio');  
        
    % *************************************************************************
    %
    % Initialization and connection to the Tobii Eye-tracker
    %
    % *************************************************************************
      
    disp('Initializing tetio...');
    tetio_init();
     
    % Set to tracker ID to the product ID of the tracker you want to connect to.
    %trackerId = 'TT120-206-93500650';
    
    
    %   FUNCTION "SEARCH FOR TRACKERS" IF NOTSET
if (strcmp(trackerId, 'NOTSET'))
	warning('tetio_matlab:EyeTracking', 'Variable trackerId has not been set.'); 
	disp('Browsing for trackers...');

	trackerinfo = tetio_getTrackers();
	for i = 1:size(trackerinfo,2)
		disp(trackerinfo(i).ProductId);
	end

	tetio_cleanUp();
	error('Error: the variable trackerId has not been set. Edit the EyeTrackingSample.m script and replace "NOTSET" with your tracker id (should be in the list above) before running this script again.');
end

    fprintf('Connecting to tracker "%s"...\n', trackerId);
    tetio_connectTracker(trackerId)
	
    currentFrameRate = tetio_getFrameRate;
    fprintf('Frame rate: %d Hz.\n', currentFrameRate);
    
    EyetrackerCalibration()
     
    close all;
    return
function EyetrackerCalibration()
    
    SetCalibParams; 
    disp('Starting TrackStatus');
    % Display the track status window showing the participant's eyes (to position the participant).
    MassTrackStatus; % Track status window will stay open until user key press.
    disp('TrackStatus stopped');

    disp('Starting Calibration workflow');
    set(gcf, 'Pointer', 'custom', 'PointerShapeCData', NaN(16,16));%making mouse invisible
    HandleCalibWorkflow(Calib);% Perform calibration
    disp('Calibration workflow stopped');
    set(gcf,'pointer','arrow');  %making mouse visible again
    
    return
function Intro()
global G
global ScreenSize

G.fig = figure('menuBar', 'none', 'name', 'Eye Tracker Game','WindowKeyPressFcn',@(h_obj,evt)Block(evt.Key));


%Background color White
set(gcf,'color','w');

logoPN = text(0.5,.6,'Perceptual Neuroscience Laboratory For Autism and Development', 'Fontsize', 20,'Color',[1,1,1],'HorizontalAlignment', 'Center');
logoExperiment = text(0.5,.47,'Eye Tracking Game', 'Fontsize',15, 'Color',[1,1,1],'HorizontalAlignment','Center');

axis off;
set(gcf, 'Position', ScreenSize);

FadeTime = cumsum([1 3 1]);

pause(2);

%Intro Fade
IntroStartTime = tic;
while 1
    CurrentTime = toc(IntroStartTime);
    
    if CurrentTime < FadeTime(1)
        set(logoPN, 'Color', 1 - [1,1,1].*max(min(CurrentTime/FadeTime(1),1),0));
        set(logoExperiment,'Color', 1 - [1,1,1].*max(min(CurrentTime/FadeTime(1),1),0));
        pause(.03);
    elseif CurrentTime < FadeTime(2)
        set(logoPN, 'Color',[0 0 0]);
        set(logoExperiment, 'Color',[0 0 0]);
        pause(1);
    else
        set(logoPN, 'Color',[1 1 1].*max(min((CurrentTime-FadeTime(2))/(FadeTime(3) - FadeTime(2)), 1),0));
        set(logoExperiment, 'Color',[1 1 1].*max(min((CurrentTime-FadeTime(2))/(FadeTime(3) - FadeTime(2)), 1),0));
        pause(.03)
    end
    
    if CurrentTime > FadeTime
       break; 
    end
end

delete(logoPN)
delete(logoExperiment)
pause(1);

return
function Instructions()
global G
global WaitTime
global TimeBeforeGameStart
%Time in between instructions - Change this value to either speed up or
%slowdown instructions

InsWrt = text(0.5,.6,'Instructions', 'Fontsize', 30,'Color',[0,0,0],'HorizontalAlignment', 'Center');
Wrt = text(0.5,.45,'You will be given two images to examine', 'Fontsize', 20,'Color',[0,0,0],'HorizontalAlignment', 'Center');

Proceed(WaitTime)

delete(Wrt)
Wrt = text(0.5,.45,'Identify if the images are the SAME or DIFFERENT as QUICKLY as possible', 'Fontsize', 20,'Color',[0,0,0],'HorizontalAlignment', 'Center');
Proceed(WaitTime)
delete(Wrt)

Wrt2 = text(0.5,.45,'After 10 seconds, the image will disappear', 'Fontsize', 20,'Color',[0,0,0],'HorizontalAlignment', 'Center');
Proceed(WaitTime)
delete(Wrt2)

delete(InsWrt)
delete(Wrt2)

Wrt3 = text(0.5,.6,'Are You Ready To Start!?', 'Fontsize', 20,'Color',[0,0,0],'HorizontalAlignment', 'Center');

Proceed(TimeBeforeGameStart)

close(G.fig);
delete(Wrt3);
return

function start_game()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GLOBAL VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%G           : Figure
%Results     : Array of responses from the user indicating "Same" or "Different" (String Array)
%ResultTimes : Array of response times from the user (Seconds)
%ScreenSze   : ScreenSize holder (Pixels)
%TimeBeforeStart : Countdown before game begins (Seconds) (RETIRED in this function)
%CallPictureGroupCounter : 
%FolderDomain : String containing the Picture domain (String)

global G;
global Results;
global ResultTimes;
global ScreenSize;
global TimeBeforeStart
global CallPictureGroupCounter
global FolderDomain

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INITIALIZATION OF VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CallPictureGroupCounter = 0;
ResultTimes = [1,2,3,4,5,6,7,8,9,10];
Results = {'Results in here'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Creating the Figure with attached function
G.fig = figure('menuBar', 'none', 'name', 'Eye Tracker Experiment','WindowKeyPressFcn',@(h_obj,evt)Block(evt.Key));
axis off;
%Setting Screen Size of Figure
set(gcf, 'Position', ScreenSize);

%Setting the Image scale - this will set a small jitter before test begins
W = strcat(FolderDomain,'D_109114_FF_84.jpg');
DisplayImage(W);
RemoveImage(W);


pause(1);

%Countdown Before Game Start -RETIRED - Moved
% Wrt4 = text(650,300,'Game will begin in:', 'Fontsize', 30,'Color',[0,0,0],'HorizontalAlignment', 'Center');
% %.5,.6
% FadeIn(Wrt4);
% PromptTime(TimeBeforeStart);
% delete(Wrt4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INITIALIZATION OF PICTURE VARIABLES AND CODES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Practice Front
grpCode1 = 'P-Fr';
X = strcat(FolderDomain,'S_101_FF_66.jpg');
X2 = strcat(FolderDomain,'S_102_FF_66.jpg');
X3 = strcat(FolderDomain,'S_103_FF_66.jpg');
X4 = strcat(FolderDomain,'D_101106_FF_48.jpg');
X5 = strcat(FolderDomain,'D_102107_FF_48.jpg');
X6 = strcat(FolderDomain,'D_103108_FF_84.jpg');
X7 = strcat(FolderDomain,'D_104109_FF_84.jpg');
X8 = strcat(FolderDomain,'S_104_FF_66.jpg');


%FrontFront Condition 1M
grpCode2 = 'FF-M';
X9 = strcat(FolderDomain,'S_105_FF_66.jpg');
X10 = strcat(FolderDomain,'D_105110_FF_84.jpg');
X11 = strcat(FolderDomain,'D_106111_FF_48.jpg');
X12 = strcat(FolderDomain,'S_106_FF_66.jpg');
X13 = strcat(FolderDomain,'S_107_FF_66.jpg');
X14 = strcat(FolderDomain,'D_107112_FF_48.jpg');
X15 = strcat(FolderDomain,'S_108_FF_66.jpg');
X16 = strcat(FolderDomain,'D_108113_FF_84.jpg');

%FrontFront Condition 2F
grpCode3 = 'FF-F';
X17 = strcat(FolderDomain,'S_201_FF_66.jpg');
X18 = strcat(FolderDomain,'D_201206_FF_48.jpg');
X19 = strcat(FolderDomain,'S_202_FF_66.jpg');
X20 = strcat(FolderDomain,'S_203_FF_66.jpg');
X21 = strcat(FolderDomain,'D_202207_FF_84.jpg');
X22 = strcat(FolderDomain,'S_204_FF_66.jpg');
X23 = strcat(FolderDomain,'D_203208_FF_48.jpg');
X24 = strcat(FolderDomain,'D_204209_FF_84.jpg');

%Practice FrontSide-SideFront 1
grpCode4 = 'P_FS_SF';
X25 = strcat(FolderDomain,'S_101_FS_1212.jpg');
X26 = strcat(FolderDomain,'D_101106_FS_1410.jpg');
X27 = strcat(FolderDomain,'S_102_FS_1212.jpg');
X28 = strcat(FolderDomain,'S_103_FS_1212.jpg');
X29 = strcat(FolderDomain,'S_104_FS_1212.jpg');
X30 = strcat(FolderDomain,'D_102107_FS_1014.jpg');
X31 = strcat(FolderDomain,'D_103108_FS_1014.jpg');
X32 = strcat(FolderDomain,'D_104109_FS_1410.jpg');

%FrontSide-SideFront 1F
grpCode5 = 'FS-1F';
X33 = strcat(FolderDomain,'D_201206_FS_1410.jpg');
X34 = strcat(FolderDomain,'S_201_FS_1212.jpg');
X35 = strcat(FolderDomain,'S_202_FS_1212.jpg');
X36 = strcat(FolderDomain,'S_203_FS_1212.jpg');
X37 = strcat(FolderDomain,'D_202207_FS_1410.jpg');
X38 = strcat(FolderDomain,'D_203208_FS_1410.jpg');
X39 = strcat(FolderDomain,'D_204209_FS_1410.jpg');
X40 = strcat(FolderDomain,'S_204_FS_1212.jpg');


%FrontSide-SideFront 2M
grpCode6 = 'FS-2M';
X41 = strcat(FolderDomain,'D_105110_FS_1410.jpg');
X42 = strcat(FolderDomain,'S_105_FS_1212.jpg');
X43 = strcat(FolderDomain,'S_106_FS_1212.jpg');
X44 = strcat(FolderDomain,'D_106111_FS_1410.jpg');
X45 = strcat(FolderDomain,'S_107_FS_1212.jpg');
X46 = strcat(FolderDomain,'S_108_FS_1212.jpg');
X47 = strcat(FolderDomain,'D_107112_FS_1410.jpg');
X48 = strcat(FolderDomain,'D_108113_FS_1410.jpg');


%SideFront-FrontSide 3M
grpCode7 = 'SF-3M';
X49 = strcat(FolderDomain,'D_109114_SF_1410.jpg');
X50 = strcat(FolderDomain,'D_110115_SF_1410.jpg');
X51 = strcat(FolderDomain,'S_109_SF_1212.jpg');
X52 = strcat(FolderDomain,'D_111116_SF_1410.jpg');
X53 = strcat(FolderDomain,'S_110_SF_1212.jpg');
X54 = strcat(FolderDomain,'S_111_SF_1212.jpg');
X55 = strcat(FolderDomain,'S_112_SF_1212.jpg');
X56 = strcat(FolderDomain,'D_112117_SF_1410.jpg');

%SideFront-FrontSide 4F
grpCode8 = 'SF-4F';
X57 = strcat(FolderDomain,'S_205_SF_1212.jpg');
X58 = strcat(FolderDomain,'S_206_SF_1212.jpg');
X59 = strcat(FolderDomain,'S_207_SF_1212.jpg');
X60 = strcat(FolderDomain,'D_208213_SF_1410.jpg');
X61 = strcat(FolderDomain,'D_209214_SF_1410.jpg');
X62 = strcat(FolderDomain,'D_210215_SF_1410.jpg');
X63 = strcat(FolderDomain,'S_208_SF_1212.jpg');
X64 = strcat(FolderDomain,'D_211216_SF_1410.jpg');

%Practice Inverted
grpCode9 = 'PI';
X65 = strcat(FolderDomain,'S_101_UDFF_66.jpg');
X66 = strcat(FolderDomain,'D_101106_UDFF_48.jpg');
X67 = strcat(FolderDomain,'S_102_UDFF_66.jpg');
X68 = strcat(FolderDomain,'D_102107_UDFF_48.jpg');
X69 = strcat(FolderDomain,'D_103108_UDFF_84.jpg');
X70 = strcat(FolderDomain,'S_103_UDFF_66.jpg');
X71 = strcat(FolderDomain,'D_104109_UDFF_84.jpg');
X72 = strcat(FolderDomain,'S_104_UDFF_66.jpg');

%Inverted 1M
grpCode10 = 'I-M';
X73 = strcat(FolderDomain,'D_105110_UDFF_84.jpg');
X74 = strcat(FolderDomain,'S_105_UDFF_66.jpg');
X75 = strcat(FolderDomain,'D_106111_UDFF_84.jpg');
X76 = strcat(FolderDomain,'D_107112_UDFF_48.jpg');
X77 = strcat(FolderDomain,'S_106_UDFF_66.jpg');
X78 = strcat(FolderDomain,'S_107_UDFF_66.jpg');
X79 = strcat(FolderDomain,'S_108_UDFF_66.jpg');
X80 = strcat(FolderDomain,'D_108113_UDFF_48.jpg');

%Inverted 1F
grpCode11 = 'I-F';
X81 = strcat(FolderDomain,'D_201206_UDFF_48.jpg');
X82 = strcat(FolderDomain,'D_202207_UDFF_84.jpg');
X83 = strcat(FolderDomain,'S_201_UDFF_66.jpg');
X84 = strcat(FolderDomain,'D_203208_UDFF_48.jpg');
X85 = strcat(FolderDomain,'S_202_UDFF_66.jpg');
X86 = strcat(FolderDomain,'S_203_UDFF_66.jpg');
X87 = strcat(FolderDomain,'S_204_UDFF_66.jpg');
X88 = strcat(FolderDomain,'D_204209_UDFF_84.jpg');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Tests Runs

%Checkpoint input from User
Userinput = inputdlg({'Select Checkpoint - (1,2,3,4) or enter "0" for complete run through.'}, 'CheckPoint Selection', [1 50;]);
CheckPoint = str2double(Userinput{1:1});

%CHECKPOINT
if (CheckPoint <= 1)||(CheckPoint == 0)

    %Practice Front
    CallPictureGroup(X,X2,X3,X4,X5,X6,X7,X8,1,2,3,4,5,6,7,8,grpCode1,1)

    %50% chance
    if rand(1) <= 0.5
    %FrontFront Condition 1M
    CallPictureGroup(X9,X10,X11,X12,X13,X14,X15,X16,9,10,11,12,13,14,15,16,grpCode2,2)
    %FrontFront Condition 2F
    CallPictureGroup(X17,X18,X19,X20,X21,X22,X23,X24,17,18,19,20,21,22,23,24,grpCode3,3)
    else
    %FrontFront Condition 2F
    CallPictureGroup(X17,X18,X19,X20,X21,X22,X23,X24,17,18,19,20,21,22,23,24,grpCode3,3)
    %FrontFront Condition 1M
    CallPictureGroup(X9,X10,X11,X12,X13,X14,X15,X16,9,10,11,12,13,14,15,16,grpCode2,2)
    end

end

%CHECKPOINT
if (CheckPoint <= 2)||(CheckPoint == 0)
    %Practice FrontSide-SideFront 1
    CallPictureGroup(X25,X26,X27,X28,X29,X30,X31,X32,25,26,27,28,29,30,31,32,grpCode4,4)

    %50% chance
    if rand(1) <= 0.5
    %FrontSide-SideFront 1F
    CallPictureGroup(X33,X34,X35,X36,X37,X38,X39,X40,33,34,35,36,37,38,39,40,grpCode5,5)
    %FrontSide-SideFront 2M
    CallPictureGroup(X41,X42,X43,X44,X45,X46,X47,X48,41,42,43,44,45,46,47,48,grpCode6,6)
    else
    %FrontSide-SideFront 2M
    CallPictureGroup(X41,X42,X43,X44,X45,X46,X47,X48,41,42,43,44,45,46,47,48,grpCode6,6)
    %FrontSide-SideFront 1F
    CallPictureGroup(X33,X34,X35,X36,X37,X38,X39,X40,33,34,35,36,37,38,39,40,grpCode5,5)
    end
end

%CHECKPOINT
if (CheckPoint <= 3)||(CheckPoint == 0)

    %50% chance
    if rand(1) <= 0.5
    %SideFront-FrontSide 3M
    CallPictureGroup(X49,X50,X51,X52,X53,X54,X55,X56,49,50,51,52,53,54,55,56,grpCode7,7)
    %SideFront-FrontSide 4F
    CallPictureGroup(X57,X58,X59,X60,X61,X62,X63,X64,57,58,59,60,61,62,63,64,grpCode8,8)
    else
    %SideFront-FrontSide 4F
    CallPictureGroup(X57,X58,X59,X60,X61,X62,X63,X64,57,58,59,60,61,62,63,64,grpCode8,8)
    %SideFront-FrontSide 3M
    CallPictureGroup(X49,X50,X51,X52,X53,X54,X55,X56,49,50,51,52,53,54,55,56,grpCode7,7)
    end
end

%CHECKPOINT
if (CheckPoint <= 4)||(CheckPoint == 0)

    %Practice Inverted
    CallPictureGroup(X65,X66,X67,X68,X69,X70,X71,X72,65,66,67,68,69,70,71,72,grpCode9,9)

    %50% chance
    if rand(1) <= 0.5
    %Inverted 1M
    CallPictureGroup(X73,X74,X75,X76,X77,X78,X79,X80,73,74,75,76,77,78,79,80,grpCode10,10)
    %Inverted 1F
    CallPictureGroup(X81,X82,X83,X84,X85,X86,X87,X88,81,82,83,84,85,86,87,88,grpCode11,11)
    else
    %Inverted 1F
    CallPictureGroup(X81,X82,X83,X84,X85,X86,X87,X88,81,82,83,84,85,86,87,88,grpCode11,11)
    %Inverted 1M
    CallPictureGroup(X73,X74,X75,X76,X77,X78,X79,X80,73,74,75,76,77,78,79,80,grpCode10,10)
    end
end

return

%Main Testing Functions
function Test(image,TestNum)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GLOBAL VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Count
global OctetTestCounter
global StartTime
global CurrentTime
global G
global Results
global ResultTimes
global QuitTripWire
global MarkerDuration
global MarkerSize
global ImageDuration
global pauseTimeInSeconds
global XEye
global YEye
global Time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INITIALIZATION OF VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%resetting the local arrays to store the data points
leftEyeAll = [];
rightEyeAll = [];
timeStampAll = [];
Timetmp = [];

%Local Initialisation
Results{TestNum:TestNum} = 'Void';
ResultTimes(TestNum) = 0;
pauseTimeInSeconds = .01;
QuitTripWire = 0;
Count = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%EXCEL DATA EXTRACTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NumberInTestOctet = rem(TestNum,8);
%this is going to help us determing which column the data will fall in for
%the excel document.
if NumberInTestOctet == 1
 OctetTestCounter = 1;
end



%Eye tracker Startup
tetio_startTracking;

        %making mouse invisible
        set(gcf, 'Pointer', 'custom', 'PointerShapeCData', NaN(16,16))
        %blocking user input while dot is on screen
        set(G.fig,'WindowKeyPressFcn',@(h_obj,evt)Block(evt.Key));
        %show dot
        plot(250,250,'k.','MarkerSize',MarkerSize)
        axis off;
        pause(MarkerDuration);
 
        %start timer after the pause
        StartTime = tic;
        DisplayImage(image);
        %call record function to apply input
        set(G.fig,'WindowKeyPressFcn',@(h_obj,evt)record(evt.Key, TestNum));
  
    
        loopcounter = 0;
while toc(StartTime) < ImageDuration
 
    pause(pauseTimeInSeconds);
    
    [lefteye, righteye, timestamp, trigSignal] = tetio_readGazeData;
    
    if isempty(lefteye)
        continue;
    end
    numGazeData = size(lefteye, 2);
    leftEyeAll = vertcat(leftEyeAll, lefteye(:, 1:numGazeData));
    rightEyeAll = vertcat(rightEyeAll, righteye(:, 1:numGazeData));
    timeStampAll = vertcat(timeStampAll, timestamp(:,1));
    
    
    %Finding out when test points begin (because points are collected while
    %looking at the center dot which are not part of time test)
    %[m,n] = size(Time(TestNum,:));
    if (loopcounter == 0)
        [o,~] = size(leftEyeAll);
        display(o);
        s = o;
        for i = 1:1:o
           Timetmp = vertcat(Timetmp,-1); 
        end
        %Time = vertcat(Time,o);
        %Time = vertcat(Time,toc(StartTime));
    else    
        [o,~] = size(leftEyeAll);
        if (o-s >= 1)
            for i = 1:1:(o-s)
            Timetmp = vertcat(Timetmp,toc(StartTime));
            end
            s=o;
        end
    end
        %Saving previous Size
    
    

    if Count == 1
        
       if (size(leftEyeAll,1) < 3000)
           %if array is larger than 3000 we are going to break out of loop         
           for k = size(leftEyeAll,1):1:3000
                for j = 1:1:13
                    leftEyeAll(k,j) = 0;
                    rightEyeAll(k,j) = 0;
                end
           end
           break
       else
       break
       end
    end
    
    %quit option
    if QuitTripWire == 1
           return 
    end
    loopcounter = loopcounter + 1;
end

%Tracking stop
tetio_stopTracking; 
%if Timetmp array is less than 3000 we're going to fill in the rest with
%-1.
        
        
        while(true)
           Timetmp = vertcat(Timetmp,-1); 
           [m,~] = size(Timetmp);
           if (m >= 3000)
               break;
           end
        end
%if the array is less than 3000, we're going to fill in the rest with 0.
%This can actually be optimised by initialising leftEyeAll and rightEyeAll
%as arrays filled with 0.
if (size(leftEyeAll,1) < 3000)      
           for k = size(leftEyeAll,1):1:3000
                for j = 1:1:13
                    leftEyeAll(k,j) = 0;
                    rightEyeAll(k,j) = 0;
                end
           end
end

RemoveImage(image);

%manipulate data - Basically similar to the display data function from
%tobii
    rightGazePoint2d.x = rightEyeAll(:,7);
    rightGazePoint2d.y = rightEyeAll(:,8);
    leftGazePoint2d.x = leftEyeAll(:,7);
    leftGazePoint2d.y = leftEyeAll(:,8);
    gaze.x = mean([rightGazePoint2d.x, leftGazePoint2d.x],2);
    gaze.y = mean([rightGazePoint2d.y, leftGazePoint2d.y],2);

    %Storing the Gaze variables 
    XEye(TestNum,:) = gaze.x.';
    YEye(TestNum,:) = gaze.y.';
    Time(TestNum,:) = Timetmp';
    
    %if time went beyond alloted time, make time equal to the max image
    %duration for nice clean number. Without this u might get a number a
    %little off. For example, if u give 10 seconds, the number u may
    %receive is 10.0154. This fixes that.
if (strcmp(Results{TestNum:TestNum},'Void') == 1)
    CurrentTime = ImageDuration;
    ResultTimes(TestNum) = CurrentTime;
end

%increment to next octet number
OctetTestCounter = OctetTestCounter + 1;

%Block keys again just incase
set(G.fig,'WindowKeyPressFcn',@(h_obj,evt)Block(evt.Key));

PracticeDisplay(TestNum)

display(Results)
display(ResultTimes(TestNum))
QuitCheck()
return
function CallPictureGroup(X,X2,X3,X4,X5,X6,X7,X8,a,b,c,d,e,f,g,h,grpCode,Switch)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GLOBAL VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global G
global ScreenSize
global CallPictureGroupCounter
global TimeBeforeStart
global FolderDomain
global Restart
global Practice
global PracticeScore

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INITIALIZATION OF VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Practice = 0;
PracticeScore = 0;
RestartSuccess = 0;
Restart = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Determining if it is a Practice Round
if(a==1)||(a==25)||(a==65)
Practice = 1;
end

%CallPictureGroupCounter is a counter setup to make sure that the initial
%countdown only appears once, on the first run.
while Restart == 1

    %Checking if it restarted
    if RestartSuccess ~= 0
       display('Restart Successful!') 
    else
        display('Continued to next trial')
    end
    
    if CallPictureGroupCounter ~= 0
     
    if (a~=1)
    EyetrackerCalibration()
    end
        
    G.fig = figure('menuBar', 'none', 'name', 'Eye Tracker Experiment','WindowKeyPressFcn',@(h_obj,evt)Block(evt.Key));
    axis off;
    set(gcf, 'Position', ScreenSize);
    
    %Setting the scale - this will set a small jitter before test begins
    W = strcat(FolderDomain,'D_109114_FF_84.jpg');
    DisplayImage(W);
    RemoveImage(W);
    %axis([0 1280 0 720]);
    end
    

    
    pause(1)
    Wrt4 = text(650,300,'Next run will begin in:', 'Fontsize', 30,'Color',[0,0,0],'HorizontalAlignment', 'Center');
    Wrt5 = text(650,100,grpCode, 'Fontsize', 10,'Color',[0,0,0],'HorizontalAlignment', 'Center');
    %FadeIn(Wrt5);
    FadeIn(Wrt4);
    PromptTime(TimeBeforeStart);
    %%Need to fix this allignment
    
    Test(X,a);
    Test(X2,b);
    Test(X3,c);
    Test(X4,d);
    Test(X5,e);
    Test(X6,f);
    Test(X7,g);
    Test(X8,h);
    ScoreDisplay();
    WaitPrompt()

    CallPictureGroupCounter = CallPictureGroupCounter + 1;

    RestartSuccess = RestartSuccess + 1;
    if Restart == 0
       break 
    end
end


ExcelWriteByParts(Switch)
return

function ScoreDisplay()
global Practice
global PracticeScore

if (Practice == 1)
%ResultScore = PracticeScore/8;
StringResultScore = num2str(PracticeScore);
ResultString = ['Your Score Was:',' ',StringResultScore,'/8'];
Wrt3 = text(650,350,ResultString, 'Fontsize', 20,'Color',[0,0,0],'HorizontalAlignment', 'Center');
pause(3);
delete(Wrt3);
end
return%KeypressFunctions
function PracticeDisplay(TestNum)
    global Practice
    global PracticeScore
    global Results
if (Practice == 1)
AnswerArray1 = {'Same','Same','Same','Different','Different','Different','Different','Same',};
AnswerArray2 = {'Same','Different','Same','Same','Same','Different','Different','Different'};
AnswerArray3 = {'Different','Different','Same','Different','Same','Same','Same','Different',};

    if (TestNum <= 8)
        AnswerArrayNumber = TestNum;
        CompareResult = AnswerArray1{AnswerArrayNumber:AnswerArrayNumber};
    elseif (TestNum >= 65)
        AnswerArrayNumber = TestNum - 64;
        CompareResult = AnswerArray3{AnswerArrayNumber:AnswerArrayNumber};
    else
        AnswerArrayNumber = TestNum - 24;
        CompareResult = AnswerArray2{AnswerArrayNumber:AnswerArrayNumber};
    end
    display(CompareResult)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (strcmp(Results{TestNum:TestNum},CompareResult) == 1)
    Wrt3 = text(650,350,'Correct!', 'Fontsize', 20,'Color',[0,0,0],'HorizontalAlignment', 'Center');
    pause(3);
    PracticeScore = PracticeScore + 1; %incrementing score counter;
    delete(Wrt3);
    else
    Wrt3 = text(650,350,'Incorrect!', 'Fontsize', 20,'Color',[0,0,0],'HorizontalAlignment', 'Center');
    pause(3);
    delete(Wrt3);
    end
end  
        
return
function record(X,TestNum)
global Count
global CurrentTime
global StartTime
global Results
global QuitTripWire
global ResultTimes
global SameKey
global DifferentKey

while Count == 0
    if Count == 0
        %finding the keystroke
        if strcmp(SameKey,X) ~= 0
            %if keystroke found, log the time
        CurrentTime = toc(StartTime);
        display(CurrentTime);
        display('Same');
        %store response
        Results{TestNum:TestNum} = 'Same';
        %store times
        ResultTimes(TestNum) = CurrentTime;
        
        %Trigger Flag to continue to next image
        Count =1;
        %RemoveImage(image);
        elseif strcmp(DifferentKey,X) ~= 0
        CurrentTime = toc(StartTime);
        display(CurrentTime);
        display('Different');
        Results{TestNum:TestNum} = 'Different';
        ResultTimes(TestNum) = CurrentTime;
                     
        Count =1;
        
        %Quit Game option
        elseif strcmp('q',X) == 1
        close all
        QuitTripWire = 1;
        return
        else
        break;
        end
    else
        break;    
    end
end
return
function Block(X)
    if strcmp('insert',X) ~= 0
        display('Not Valid Yet')
    elseif strcmp('return',X) ~= 0
        display('Not Valid Yet')
    elseif strcmp('*',X) ~= 0
        display('Not Valid Yet')
    elseif strcmp('/',X) ~= 0
        display('Not Valid Yet')
    end
return
function ProceedPress(Key)
    global ContinueCounter
    global Restart
    while ContinueCounter ~= 1
         
          if strcmp('rightarrow',Key) ~= 0
             ContinueCounter = 1;  
             Restart = 0;
          elseif strcmp('leftarrow',Key) ~= 0
              ContinueCounter = 1;
          else
              break;
          end
    end
return

%Excel Functions
function ExcelWriteByParts(Switch)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GLOBAL VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Results
global ResultTimes
global ExcelFilename
global ExcelFolder

global Name
global Age
global gender
global Notes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = msgbox('Saving Progress... Please Wait');
NewFileTripWire = 0; %If new file, we need to "SaveAs"
Name = char(Name);%Converting to character array

Filename = strcat(ExcelFolder,Name,'.xlsm');

e=actxserver('excel.application');
eW=e.Workbooks;
delete(h);%'Saving Progress msgbox delete
try
display(Filename);
w = msgbox('Looking for file');
eF=eW.Open(Filename); % open OutputTest.xls
pause(1);
delete(w);
catch
w = msgbox('Unable to Find File - Opening Template');
eF=eW.Open(ExcelFilename); % open OutputTest.xls
NewFileTripWire = 1; %TripWire Triggered
pause(1);
delete(w);
end
eS = e.ActiveWorkbook.Sheets;

switch Switch
    case 1
eS1= eS.get('Item',1); %Sheet 1
eS1.Activate 

%Prompt Info Initialisation
namecell = get(eS1, 'Range', 'C4');
namecell.Value = Name;
agecell = get(eS1, 'Range', 'C5');
agecell.Value = Age;
gendercell = get(eS1, 'Range', 'C6');
gendercell.Value = gender;
notescell = get(eS1, 'Range', 'C7');
notescell.Value = Notes;

rangeresult = get(eS1, 'Range','D14:K14'); 
rangeresult.Value = Results;
Timecell = get(eS1, 'Range', 'D15:K15');
Timecell.Value = ResultTimes;
ExcelEyeTrackerStorage(eS1,1,2,3,4,5,6,7,8)

    case 2
eS2= eS.get('Item',2); %Sheet 2
eS2.Activate 

rangeresult = get(eS2, 'Range','D14:K14'); 
rangeresult.Value = Results(9:16);
Timecell = get(eS2, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(9:16);
ExcelEyeTrackerStorage(eS2,9,10,11,12,13,14,15,16)

    case 3
eS3= eS.get('Item',3); %Sheet 3
eS3.Activate 

rangeresult = get(eS3, 'Range','D14:K14'); 
rangeresult.Value = Results(17:24);
Timecell = get(eS3, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(17:24);
ExcelEyeTrackerStorage(eS3,17,18,19,20,21,22,23,24)

    case 4
eS4= eS.get('Item',4); %Sheet 4
eS4.Activate 

rangeresult = get(eS4, 'Range','D14:K14'); 
rangeresult.Value = Results(25:32);
Timecell = get(eS4, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(25:32);
ExcelEyeTrackerStorage(eS4,25,26,27,28,29,30,31,32)

    case 5
eS5= eS.get('Item',5); %Sheet 5
eS5.Activate 

rangeresult = get(eS5, 'Range','D14:K14'); 
rangeresult.Value = Results(33:40);
Timecell = get(eS5, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(33:40);
ExcelEyeTrackerStorage(eS5,33,34,35,36,37,38,39,40)

    case 6
eS6= eS.get('Item',6); %Sheet 6
eS6.Activate 

rangeresult = get(eS6, 'Range','D14:K14'); 
rangeresult.Value = Results(41:48);
Timecell = get(eS6, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(41:48);
ExcelEyeTrackerStorage(eS6,41,42,43,44,45,46,47,48)

    case 7
eS7= eS.get('Item',7); %Sheet 7
eS7.Activate 

rangeresult = get(eS7, 'Range','D14:K14'); 
rangeresult.Value = Results(49:56);
Timecell = get(eS7, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(49:56);
ExcelEyeTrackerStorage(eS7,49,50,51,52,53,54,55,56)

    case 8
eS8= eS.get('Item',8); %Sheet 8
eS8.Activate 

rangeresult = get(eS8, 'Range','D14:K14'); 
rangeresult.Value = Results(57:64);
Timecell = get(eS8, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(57:64);
ExcelEyeTrackerStorage(eS8,57,58,59,60,61,62,63,64)

    case 9
eS9= eS.get('Item',9); %Sheet 9
eS9.Activate 

rangeresult = get(eS9, 'Range','D14:K14'); 
rangeresult.Value = Results(65:72);
Timecell = get(eS9, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(65:72);
ExcelEyeTrackerStorage(eS9,65,66,67,68,69,70,71,72)

    case 10
eS10= eS.get('Item',10); %Sheet 10
eS10.Activate 

rangeresult = get(eS10, 'Range','D14:K14'); 
rangeresult.Value = Results(73:80);
Timecell = get(eS10, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(73:80);
ExcelEyeTrackerStorage(eS10,73,74,75,76,77,78,79,80)

    case 11
eS11= eS.get('Item',11); %Sheet 11
eS11.Activate 

rangeresult = get(eS11, 'Range','D14:K14'); 
rangeresult.Value = Results(81:88);
Timecell = get(eS11, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(81:88);
ExcelEyeTrackerStorage(eS11,81,82,83,84,85,86,87,88)

end

if (NewFileTripWire == 0)
eF.Save
else
    
w = msgbox('Saving New Folder');
eF.SaveAs(Filename);
%eF.Save;
pause(1);
delete(w);
end
eF.Close; % close the file
e.Quit; % close Excel entirely
delete(e);

h = msgbox('Saving Progress... Please Wait');
pause(1);
delete(h);
return
function ExcelWrite()
global Results
global ResultTimes
global ExcelFilename
global ExcelFolder

global Name
global Age
global gender
global Notes

%This functioon writes in the excel document all at once
Filename = strcat(ExcelFolder,Name,'.xlsm');

e=actxserver('excel.application');
eW=e.Workbooks;
eF=eW.Open(ExcelFilename); % open OutputTest.xls

eS = e.ActiveWorkbook.Sheets;
eS1= eS.get('Item',1); %Sheet 1
eS1.Activate 

%Prompt Info Initialisation
namecell = get(eS1, 'Range', 'C4');
namecell.Value = Name;
agecell = get(eS1, 'Range', 'C5');
agecell.Value = Age;
gendercell = get(eS1, 'Range', 'C6');
gendercell.Value = gender;
notescell = get(eS1, 'Range', 'C7');
notescell.Value = Notes;

rangeresult = get(eS1, 'Range','D14:K14'); 
rangeresult.Value = Results;
Timecell = get(eS1, 'Range', 'D15:K15');
Timecell.Value = ResultTimes;
ExcelEyeTrackerStorage(eS1,1,2,3,4,5,6,7,8)

eS2= eS.get('Item',2); %Sheet 2
eS2.Activate 

rangeresult = get(eS2, 'Range','D14:K14'); 
rangeresult.Value = Results(9:16);
Timecell = get(eS2, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(9:16);
ExcelEyeTrackerStorage(eS2,9,10,11,12,13,14,15,16)

eS3= eS.get('Item',3); %Sheet 3
eS3.Activate 

rangeresult = get(eS3, 'Range','D14:K14'); 
rangeresult.Value = Results(17:24);
Timecell = get(eS3, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(17:24);
ExcelEyeTrackerStorage(eS3,17,18,19,20,21,22,23,24)


eS4= eS.get('Item',4); %Sheet 4
eS4.Activate 

rangeresult = get(eS4, 'Range','D14:K14'); 
rangeresult.Value = Results(25:32);
Timecell = get(eS4, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(25:32);
ExcelEyeTrackerStorage(eS4,25,26,27,28,29,30,31,32)

eS5= eS.get('Item',5); %Sheet 5
eS5.Activate 

rangeresult = get(eS5, 'Range','D14:K14'); 
rangeresult.Value = Results(33:40);
Timecell = get(eS5, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(33:40);
ExcelEyeTrackerStorage(eS5,33,34,35,36,37,38,39,40)

eS6= eS.get('Item',6); %Sheet 6
eS6.Activate 

rangeresult = get(eS6, 'Range','D14:K14'); 
rangeresult.Value = Results(41:48);
Timecell = get(eS6, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(41:48);
ExcelEyeTrackerStorage(eS6,41,42,43,44,45,46,47,48)

eS7= eS.get('Item',7); %Sheet 7
eS7.Activate 

rangeresult = get(eS7, 'Range','D14:K14'); 
rangeresult.Value = Results(49:56);
Timecell = get(eS7, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(49:56);
ExcelEyeTrackerStorage(eS7,49,50,51,52,53,54,55,56)

eS8= eS.get('Item',8); %Sheet 8
eS8.Activate 

rangeresult = get(eS8, 'Range','D14:K14'); 
rangeresult.Value = Results(57:64);
Timecell = get(eS8, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(57:64);
ExcelEyeTrackerStorage(eS8,57,58,59,60,61,62,63,64)

eS9= eS.get('Item',9); %Sheet 9
eS9.Activate 

rangeresult = get(eS9, 'Range','D14:K14'); 
rangeresult.Value = Results(65:72);
Timecell = get(eS9, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(65:72);
ExcelEyeTrackerStorage(eS9,65,66,67,68,69,70,71,72)

eS10= eS.get('Item',10); %Sheet 10
eS10.Activate 

rangeresult = get(eS10, 'Range','D14:K14'); 
rangeresult.Value = Results(73:80);
Timecell = get(eS10, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(73:80);
ExcelEyeTrackerStorage(eS10,73,74,75,76,77,78,79,80)


eS11= eS.get('Item',11); %Sheet 11
eS11.Activate 

rangeresult = get(eS11, 'Range','D14:K14'); 
rangeresult.Value = Results(81:88);
Timecell = get(eS11, 'Range', 'D15:K15');
Timecell.Value = ResultTimes(81:88);
ExcelEyeTrackerStorage(eS11,81,82,83,84,85,86,87,88)


eF.SaveAs(Filename);
eF.Close; % close the file
e.Quit; % close Excel entirely
delete(e);
return
function ExcelEyeTrackerStorage(PageNumber,a,b,c,d,e,f,g,h)
global XEye
global YEye
global Time
    
XEyeDataResults1 = get(PageNumber, 'Range', 'P18:P3018');
YEyeDataResults1 = get(PageNumber, 'Range', 'Q18:Q3018');
TimeDataResults1 = get(PageNumber, 'Range', 'R18:R3018');
XEyeDataResults1.NumberFormat='0.0000';
YEyeDataResults1.NumberFormat='0.0000';
XEyeDataResults1.value = XEye(a,1:3000).';
YEyeDataResults1.value = YEye(a,1:3000).';
TimeDataResults1.value = Time(a,1:3000).';

XEyeDataResults2 = get(PageNumber, 'Range', 'S18:S3018');
YEyeDataResults2 = get(PageNumber, 'Range', 'T18:T3018');
TimeDataResults2 = get(PageNumber, 'Range', 'U18:U3018');
XEyeDataResults2.NumberFormat='0.0000';
YEyeDataResults2.NumberFormat='0.0000';
XEyeDataResults2.value = XEye(b,1:3000).';
YEyeDataResults2.value = YEye(b,1:3000).';
TimeDataResults2.value = Time(b,1:3000).';

XEyeDataResults3 = get(PageNumber, 'Range', 'V18:V3018');
YEyeDataResults3 = get(PageNumber, 'Range', 'W18:W3018');
TimeDataResults3 = get(PageNumber, 'Range', 'X18:X3018');
XEyeDataResults3.NumberFormat='0.0000';
YEyeDataResults3.NumberFormat='0.0000';
XEyeDataResults3.value = XEye(c,1:3000).';
YEyeDataResults3.value = YEye(c,1:3000).';
TimeDataResults3.value = Time(c,1:3000).';
    
XEyeDataResults4 = get(PageNumber, 'Range', 'Y18:Y3018');
YEyeDataResults4 = get(PageNumber, 'Range', 'Z18:Z3018');
TimeDataResults4 = get(PageNumber, 'Range', 'AA18:AA3018');
XEyeDataResults4.NumberFormat='0.0000';
YEyeDataResults4.NumberFormat='0.0000';
XEyeDataResults4.value = XEye(d,1:3000).';
YEyeDataResults4.value = YEye(d,1:3000).';
TimeDataResults4.value = Time(d,1:3000).';

XEyeDataResults5 = get(PageNumber, 'Range', 'AB18:AB3018');
YEyeDataResults5 = get(PageNumber, 'Range', 'AC18:AC3018');
TimeDataResults5 = get(PageNumber, 'Range', 'AD18:AD3018');
XEyeDataResults5.NumberFormat='0.0000';
YEyeDataResults5.NumberFormat='0.0000';
XEyeDataResults5.value = XEye(e,1:3000).';
YEyeDataResults5.value = YEye(e,1:3000).';
TimeDataResults5.value = Time(e,1:3000).';

XEyeDataResults6 = get(PageNumber, 'Range', 'AE18:AE3018');
YEyeDataResults6 = get(PageNumber, 'Range', 'AF18:AF3018');
TimeDataResults6 = get(PageNumber, 'Range', 'AG18:AG3018');
XEyeDataResults6.NumberFormat='0.0000';
YEyeDataResults6.NumberFormat='0.0000';
XEyeDataResults6.value = XEye(f,1:3000).';
YEyeDataResults6.value = YEye(f,1:3000).';
TimeDataResults6.value = Time(f,1:3000).';

XEyeDataResults7 = get(PageNumber, 'Range', 'AH18:AH3018');
YEyeDataResults7 = get(PageNumber, 'Range', 'AI18:AI3018');
TimeDataResults7 = get(PageNumber, 'Range', 'AJ18:AJ3018');
XEyeDataResults7.NumberFormat='0.0000';
YEyeDataResults7.NumberFormat='0.0000';
XEyeDataResults7.value = XEye(g,1:3000).';
YEyeDataResults7.value = YEye(g,1:3000).';
TimeDataResults7.value = Time(g,1:3000).';

XEyeDataResults8 = get(PageNumber, 'Range', 'AK18:AK3018');
YEyeDataResults8 = get(PageNumber, 'Range', 'AL18:AL3018');
TimeDataResults8 = get(PageNumber, 'Range', 'AM18:AM3018');
XEyeDataResults8.NumberFormat='0.0000';
YEyeDataResults8.NumberFormat='0.0000';
XEyeDataResults8.value = XEye(h,1:3000).';
YEyeDataResults8.value = YEye(h,1:3000).';
TimeDataResults8.value = Time(h,1:3000).';
return

%miscelaneous functions

function PromptTime(TimeBeforeStart)
for v = TimeBeforeStart:-1.0:1.0
   Countdown = text(650,400,sprintf('%d',v), 'Fontsize', 40,'Color',[0,0,0],'HorizontalAlignment', 'Center');
    %0.5,.4
   pause(1)
    delete(Countdown);
end
return
function DisplayResults()
global ScreenSize;
set(gcf,'color','w');
axis off;
set(gcf, 'menuBar', 'none','name','Eye Tracker Game Complete');
set(gcf, 'Position', ScreenSize);

axis([0 1 0 1]);
Wrt5 = text(.5,.35,'Way to go! - Game Complete!', 'Fontsize', 30,'Color',[1,1,1],'HorizontalAlignment', 'Center');
%Wrt6 = text(.3,.6,'Results:', 'Fontsize', 30,'Color',[1,1,1],'HorizontalAlignment', 'Center');
%Wrt7 = text(.5,.6,'Picture 1', 'Fontsize', 30,'Color',[1,1,1],'HorizontalAlignment', 'Center');
%Wrt8 = text(.7,.6,'Picture 2', 'Fontsize', 30,'Color',[1,1,1],'HorizontalAlignment', 'Center');
%Wrt9 = text(.5,.8,Results{1:1}, 'Fontsize', 30,'Color',[1,1,1],'HorizontalAlignment', 'Center');
%Wrt10 = text(.8,.8,Results{2:2}, 'Fontsize', 30,'Color',[1,1,1],'HorizontalAlignment', 'Center');
Wrt11 = text(.5,.6,'When Replay Prompt Appears - You Can Proceed', 'Fontsize', 27,'Color',[1,1,1],'HorizontalAlignment', 'Center');


FadeIn(Wrt5)
%FadeIn(Wrt6)
pause(.2)

FadeIn(Wrt11)
%FadeIn(Wrt8)
%pause(0.2)

%FadeIn(Wrt9)
%pause(.5)
%FadeIn(Wrt10)
return
function Infoprompt()
global Name
global Age
global gender
global Notes

RepeatFlag = 0;

while (RepeatFlag == 0)

Userinput = inputdlg({'Name of Participant', 'Age', 'Gender', 'Notes'}, 'Excel Document Export', [1 50; 1 7; 1 7; 4 25]);

    Name = Userinput(1:1);
    Age = Userinput(2:2);
    gender = Userinput(3:3);
    Notes = Userinput(4:4);
    
     if (isempty(Userinput{1:1}) == 0)
         RepeatFlag = 1;
     else
         waitfor(msgbox('Please fill in the Name criteria so that the results may be recorded'));
     end
end
return
function QuestionPrompt(X)
%use this if you want an on-screen button to click - Currently no
%implemented. You will need to fool around with the button positioning


%axis on;
axis([0 1 0 1]);
%Y-Axis on pictures are normally inversed - this command sets them normal
set(gca,'YDir','Normal')

Wrt4 = text(.5,.6,'Were the images the SAME or DIFFERENT', 'Fontsize', 30,'Color',[1,1,1],'HorizontalAlignment', 'Center');
%.5, .35
FadeIn(Wrt4);

btn1 = uicontrol( 'Style', 'Pushbutton','Position', [600 420 300 100],'String','SAME','Callback',@(src,evnt)buttonCallback('SAME',X) ); 
btn2 = uicontrol( 'Style', 'Pushbutton','Position', [1100 420 300 100],'String','DIFFERENT','Callback',@(src,evnt)buttonCallback('DIFFERENT', X)  ); 

uiwait(gcf); 
delete(btn1);
delete(btn2);
pause(.1);
FadeOut(Wrt4)

return    
function buttonCallback(newString, X)
%declare these variables in start in order to register response from on
%screen buttons
global ResultsExp1
global ResultsExp2

if X ==1
   ResultsExp1 = newString;
else
    ResultsExp2 = newString;
end

uiresume(gcbf);
return
function DisplayImage(Y)
%Defining Image Variable
set(gcf,'color','w');
axis off;
X = imread(Y);
%Resizing
X2 = imresize(X,[720,1280]);
%Displaying image
%image(0,0,X2);
imshow(X2);
set(gcf, 'Position', [1,1,1024,819.33]);


%Holding on to the image in order to overlay data points
hold on;
%plotting Overlay
%plot(250,250,'r.','MarkerSize',20)
%Set Fullscreen

%Original window size
%OriginalScreen = get(gcf, 'Position');

%Turning on or off Axis
axis off;

return
function RemoveImage(Y)
hold off;
X = imread(Y);
delete(image(X));
axis off;
return
function stat=play_again()
yn = questdlg('Test Again?');
stat = strcmp('Yes',yn);
return
function get_options()
waitfor(msgbox('Prompt for options here'));
return
function DisplayImageSpecs(X)
[y1,x1,z1] = size(imread(X));
display([y1,x1,z1]);
return
function FadeOut(X)
FadeTime = cumsum([0 2 1]);
IntroStartTime = tic;
while 1
    CurrentTime = toc(IntroStartTime);
       
    if CurrentTime < FadeTime(2)
        set(X, 'Color',[1 1 1]);
    else
        set(X, 'Color',[1 1 1].*max(min((CurrentTime-FadeTime(2))/(FadeTime(3) - FadeTime(2)), 1),0));
        pause(.03)

    end
    
    if CurrentTime > FadeTime
       break; 
    end

end
delete(X)
return
function FadeIn(X)
FadeTime = cumsum([1 2 0]);
IntroStartTime = tic;
while 1
    CurrentTime = toc(IntroStartTime);
    
    if CurrentTime < FadeTime(1)
        set(X, 'Color', 1 - [1,1,1].*max(min(CurrentTime/FadeTime(1),1),0));
        pause(.03);
    else
        set(X, 'Color',[0 0 0]);
    end
    
    if CurrentTime > FadeTime
       break; 
    end

end

return
function Fade(X)
FadeTime = cumsum([1 3 1]);
IntroStartTime = tic;
while 1
    CurrentTime = toc(IntroStartTime);
    
    if CurrentTime < FadeTime(1)
        set(X, 'Color', 1 - [1,1,1].*max(min(CurrentTime/FadeTime(1),1),0));
        pause(.03);
    elseif CurrentTime < FadeTime(2)
        set(X, 'Color',[0 0 0]);
    else
        set(X, 'Color',[1 1 1].*max(min((CurrentTime-FadeTime(2))/(FadeTime(3) - FadeTime(2)), 1),0));
        pause(.03)
    end
    
    if CurrentTime > FadeTime
       break; 
    end

end
return
function QuitCheck()
global QuitTripWire
if QuitTripWire == 1
return
end
return
function WaitPrompt()

axis([0 1 0 1]);
set(gcf,'pointer','arrow')
Wrt3 = text(0.5,1-.6,'Complete, Way To Go! Are you ready for the next round?', 'Fontsize', 20,'Color',[0,0,0],'HorizontalAlignment', 'Center');
%btn = uicontrol('Style', 'pushbutton', 'String', 'Continue','Fontsize',20,'Position', [375 309 300 100],'Callback', 'uiresume(gcbf)');  

%uiwait(gcf); 
%delete(btn);
Proceed(100)
delete(Wrt3);
close all

return
function Proceed(WaitTime)
    global G
  global ContinueCounter
  global Restart
  TimeCounter = 0;
  ContinueCounter = 0;
  Restart = 1;
  %this function is used to skip instructions. Calls ProceedPress to
  %takedown the keypress of user to trip flag and skip pause loop.
  set(G.fig,'WindowKeyPressFcn',@(h_obj,evt)ProceedPress(evt.Key));
  
  while ContinueCounter ~= 1
    if TimeCounter < WaitTime
        pause(1)
         TimeCounter= TimeCounter + 1;
    else
       break
    end
  end  
    
return



