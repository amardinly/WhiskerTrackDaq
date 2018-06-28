function [ ExperimentName ] = autoExptname1(SavePath)
%automatically generates expermient name based on current date and what
%experiment files exist for that date

formatOut = 'yymmdd';
date=num2str(datestr(now,formatOut));

%check what experiments exist for today's date

    for i=1:26
        this_letter = char('A'+i-1); %convert i to a letter
        thisExptname = strcat(date,'_',this_letter);
        thisFilename = strcat(SavePath,date,'_',this_letter,'.mat');
        if exist(thisFilename, 'file') ~= 2 % if experiment with that name doesn't exists (in current Matlab path)
            break 
        end
    end
ExperimentName = thisExptname;


end

