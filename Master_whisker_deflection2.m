clear all; close all force; clc;

mouseID = input('please enter mouse ID','s');
trialNum = input('please enter trial num');
rmpath(genpath('C:\Users\MOM2\Documents\MATLAB\'));
rmpath(genpath('C:\Users\MOM2\Documents\GitHub\'));

addpath(genpath('C:\Users\MOM2\Documents\GitHub\msocket'));
addpath(genpath('C:\Users\MOM2\Documents\GitHub\WhiskerTrackDaq\'));

%using matlab data acquisition toolbox, set up daq and connection
s = daq.createSession('ni'); %ni is company name
addAnalogInputChannel(s,'Dev3',0,'Voltage');                    %LASER EOM
addAnalogOutputChannel(s,'Dev3',2,'Voltage');                    %LASER EOM
addTriggerConnection(s,'External','Dev3/PFI4','StartTrigger');  %trigger connection from Arduino 
addDigitalChannel(s,'Dev3','Port0/Line0:5','OutputOnly');  

s.Rate=20000;
s.ExternalTriggerTimeout=3000; %basically never time out

%setup readytogo trigger
readyTrigger = daq.createSession('ni');
addDigitalChannel(readyTrigger,'Dev3','Port1/Line3','OutputOnly');  

%% initialized vars
i = 1; %formerly sweep number
defaultOutputSignal=function_whisker_triggers();  %delete input
outputSignal = defaultOutputSignal;  %initial output to defaults
onlinePath = 'X:\holography\Data\Magnet\OnlineWhiskerTransfer\';
savePath = 'X:\holography\Data\Magnet\WhiskerDeflectionData\';

[ ExperimentName ] = autoExptname1(savePath);
ExperimentName = [ExperimentName '_' mouseID '_onlineWhisker'];
%% Init UDP connection

%initialize UDP camera trigger
try; echoudp('on',55000); catch; disp('error initializing UDP - if already running, ignore');  end;
try; fclose(udp('128.32.173.99',55000));end;

myUDP = udp('128.32.173.99',55000);
fopen(myUDP);

%% Run DAQ
% connect to arduino
ard=serial('COM7','BaudRate',9600);
fopen(ard);

readData=fscanf(ard) %reads "A"

flushinput(ard);fprintf(ard,'%s\n','fff','sync');

reading_stims={};

for k=1:trialNum
    reading_stims{k} = fgetl(ard);
end
disp(reading_stims)
onlineStruct.stims = reading_stims;
onlineStruct.trialNum = trialNum;
onlineStruct.mouseID = mouseID;
save([onlinePath '_online_deflection'], 'onlineStruct');

ExpStruct.InitialStimList = reading_stims;

%% and loop
fprintf(ard,'%s\n','1','sync');%readData=fscanf(ard)

while  i<=trialNum; %run forever
disp(['waiting for trigger to start trial ' num2str(i)]);    

queueOutputData(s,outputSignal);  %get ready to run a sweep

dataIn = s.startForeground;   %run a sweep
[ExpStruct outputSignal] = closeLoopMaster_whisker_deflection(dataIn,ExpStruct,myUDP,[],defaultOutputSignal,0,i);
the_stim = fgetl(ard);
disp(['Serial read ' the_stim]);
disp(['expected ' reading_stims{i}]);
%displayTriggers(outputSignal,i);
ExpStruct.SerialStimDat(i) = str2double(the_stim);

%send ready to go trigger back to arduino
sendReadyTrigger(readyTrigger,.05);

i = i + 1;  %incriment trial number

end
%send UDP trigger to Camera to save frames and open next file
%fwrite(myUDP,num2str(i+1));
%disp('UDP signal sent to camera');
save([savePath ExperimentName],'ExpStruct');
disp('saved!');
fclose(ard);
disp('quit!');