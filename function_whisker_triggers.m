function outputSignal = function_whisker_triggers();




CameraTrigger=makepulseoutputs(1,75,.5,1,300,20000,.4);

f=zeros(size(CameraTrigger));
outputSignal(:,1)=f; %verified
outputSignal(:,2)=f; %verified
outputSignal(:,3)=f;
outputSignal(:,4)=f;%verified
outputSignal(:,5)=f; %verified
outputSignal(:,6)=f;
outputSignal(:,7)=CameraTrigger;%verified
