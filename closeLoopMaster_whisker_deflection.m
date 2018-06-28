function [ExpStruct OutputSignal] = closeLoopMaster(dataIn,ExpStruct,myUDP,HoloSocket,defaultOutputSignal,eomOffset,i);
%% Close Loop master function
persistent holoRequest LaserPower

tic
OutputSignal=defaultOutputSignal;

%send UDP trigger to Camera to save frames and open next file
fwrite(myUDP,num2str(i+1));
disp('UDP signal sent to camera');

%analyze sweeps{thisTrial}(1,:) for analog data, and we'll see about
%digital data.  remember to undo the delta from CC

%2) grab stimulus data
offset = mean(dataIn(1400:1700,1));
trialStimData = round((mean(dataIn(100:1000,1))-offset) * 78);

%magnet stim value 
ExpStruct.StimulusData(i) = trialStimData;


end
