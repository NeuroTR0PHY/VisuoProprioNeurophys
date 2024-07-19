
event_names = {'LEFT_NOVIS_SIT' 'LEFT_VIS_SIT' 'RIGHT_VIS_SIT' 'RIGHT_VIS_STAND'};
for trig = 1:length(event_names)
   l=length(EEG.chanlocs);
    for x = 1:l
        z = EEG.chanlocs(x).labels;
        switch z
            case 'Cz'
                Cz=x;
            case 'CPz'
                CPz=x;
            case 'CP3'
                CP3=x;
            case 'CP4'
                CP4=x;
        end
    end
    %%
    allEEG = EEG;
    electrode_labels = {'Cz','CPz','CP3','CP4'};
    %% plots time-freq for trials from all subjects
    electrodes = [Cz, CPz, CP3,CP4];
    for xx = 2 % electrodes
    electrode = electrodes(xx);
    figure;  title([electrode_labels(xx) ':' event_names{trig}])



 tempEEG= pop_epoch( allEEG,{event_names{trig}}, [-2 2], 'epochinfo', 'yes'); % change 'first' to whatever events you want to epoch around

[ersp, itc, powbase, times, frequencies] = pop_newtimef( tempEEG,1,...
                    electrode, [-2000  1999], [3 0.8] , 'plotphase', 'off', ...
                    'padratio',1,'winsize', 460,'baseline',[-2000 -1000], 'erspmax',3);
    end 
end 