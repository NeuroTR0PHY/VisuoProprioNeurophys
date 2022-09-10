%% 
close all; clear all; clc

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
sub_ID = input('enter the subject ID: ','s');
eegfiles = dir('*.vhdr');

% load each .vhdr file for different conditions; upon loading, remove entire baseline (DC drift),
% perfomr 1 Hz HPF, and downsample; then save new set file

for i = 1:8 % set to # of conditions/files
EEG = pop_loadbv(['/Users/nathan/Downloads/AHA_piloting/' sub_ID '/TRACE'],[eegfiles(i).name]);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );

% remove epoch basleine
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [],[]);

% HPF
EEG = eeg_checkset( EEG );
cutoff_freq = 0.5;
EEG = pop_eegfiltnew(EEG, [],cutoff_freq+0.5,16500,true,[],0);

% downsample 
EEG = eeg_checkset( EEG );
EEG = pop_resample( EEG, 500);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); % % 
EEG = eeg_checkset( EEG );

% save
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'savenew',[eegfiles(i).name(1:end-4) '_base_rm_filtered'],'gui','off'); 

end 

%% load initial preprocessed set files

files_set = dir('*.set'); % get list of files that have initial preprocessing for four conditions
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
for i = 1:length(files_set)
EEG = pop_loadset('filename',[files_set(i).name],'filepath',['/Users/nathan/Downloads/AHA_piloting/' sub_ID '/TRACE']);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
end




%% merge set files into one
EEG = eeg_checkset( EEG );
EEG = pop_mergeset( ALLEEG, [1 2 3 4 5 6 7 8], 0); % set to 1 2 3 4 or 1 2 3 4 5 6 7 8 if doing all conditions
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 8,'gui','off'); % set to 4 or 8


%% add channels locations, and save merged set file



EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'lookup','/Users/nathan/Documents/MATLAB/eeglab2021.0/plugins/dipfit4.3/standard_BEM/elec/standard_1005.elc');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 8,'savenew',[sub_ID '_merged_filtered_downsampled_all_ch'],'gui','off'); %set to 4 or 8



%% fix events

EEG = eeg_checkset( EEG );

all_trials = [EEG.event.duration]; 

good_rows = [];
boundary_rows = [];
extra_event_rows = [];



for i = 1:length(all_trials)
%find_rows= strcmp(EEG.event(i).type,'R 15') | strcmp(EEG.event(i).type,'R  7');
%find_rows = strcmp(EEG.event(i).type,'boundary') && strcmp(EEG.event(i).code,'DC Correction');
find_rows = strcmp(EEG.event(i).code, 'DC Correction');

%find_rows= strcmp(EEG.event(i).type,'S  3');

if find_rows == 1
    EEG.event(i).type = 'notboundary';
end 
 find_boundary_rows = strcmp(EEG.event(i).type,'boundary');
%         good_rows = [good_rows; find_rows];
boundary_rows = [boundary_rows; find_boundary_rows];
end 

boundary_index = find(boundary_rows==1);

%%%if SSEP
for i = boundary_index(1):boundary_index(2) % first set
    find_rows= strcmp(EEG.event(i).type,'R128');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(3):boundary_index(4) % first set
    find_rows= strcmp(EEG.event(i).type,'R128');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 
for i = boundary_index(5):boundary_index(6) % first set
    find_rows= strcmp(EEG.event(i).type,'R149');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(7):length(all_trials) % first set
    find_rows= strcmp(EEG.event(i).type,'R149');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 
%%%%% end SSEP only


%%%if Right Only
for i = boundary_index(1):boundary_index(2) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(3):boundary_index(4) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 
for i = boundary_index(5):boundary_index(6) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(7):length(all_trials) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 
%%%%% end right only

%for 242
for i = boundary_index(1):boundary_index(2) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_NOVIS_SIT';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(3):boundary_index(4) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_NOVIS_STAND';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(5):boundary_index(6) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_VIS_SIT';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(7):boundary_index(8) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_VIS_STAND';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(9):boundary_index(10) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(11):boundary_index(12) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 
for i = boundary_index(13):boundary_index(14) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(15):length(all_trials) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

%end 242



%for 243
for i = boundary_index(1):boundary_index(2) % first set
    find_rows= strcmp(EEG.event(i).type,'S243');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_NOVIS_SIT';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(3):boundary_index(4) % first set
    find_rows= strcmp(EEG.event(i).type,'S243');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_NOVIS_STAND';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(5):boundary_index(6) % first set
    find_rows= strcmp(EEG.event(i).type,'S243');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_VIS_SIT';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(7):boundary_index(8) % first set
    find_rows= strcmp(EEG.event(i).type,'S243');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_VIS_STAND';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(9):boundary_index(10) % first set
    find_rows= strcmp(EEG.event(i).type,'S243');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(11):boundary_index(12) % first set
    find_rows= strcmp(EEG.event(i).type,'S243');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 
for i = boundary_index(13):boundary_index(14) % first set
    find_rows= strcmp(EEG.event(i).type,'S243');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(15):length(all_trials) % first set
    find_rows= strcmp(EEG.event(i).type,'S243');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

%end 243


%for 245
for i = boundary_index(1):boundary_index(2) % first set
    find_rows= strcmp(EEG.event(i).type,'S245');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_NOVIS_SIT';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(3):boundary_index(4) % first set
    find_rows= strcmp(EEG.event(i).type,'S245');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_NOVIS_STAND';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(5):boundary_index(6) % first set
    find_rows= strcmp(EEG.event(i).type,'S245');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_VIS_SIT';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(7):boundary_index(8) % first set
    find_rows= strcmp(EEG.event(i).type,'S245');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_VIS_STAND';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(9):boundary_index(10) % first set
    find_rows= strcmp(EEG.event(i).type,'S245');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(11):boundary_index(12) % first set
    find_rows= strcmp(EEG.event(i).type,'S245');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 
for i = boundary_index(13):boundary_index(14) % first set
    find_rows= strcmp(EEG.event(i).type,'S245');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(15):length(all_trials) % first set
    find_rows= strcmp(EEG.event(i).type,'S245');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

%end 245

%% remove duplicate S11 event and boundary event
all_event_rows = {EEG.event.type}';
bad_event_names = 'S241';
rows_bad = find(strcmp(all_event_rows,bad_event_names)==1);


EEG.event(rows_bad) = [];
all_event_rows(rows_bad) = [];

rows_boundary = find(strcmp(all_event_rows,'boundary')==1);

EEG.event(rows_boundary) = [];
all_event_rows(rows_boundary) = [];

all_event_rows = {EEG.event.type}';
bad_event_names = 'S240';
rows_bad = find(strcmp(all_event_rows,bad_event_names)==1);


EEG.event(rows_bad) = [];
all_event_rows(rows_bad) = [];

rows_boundary = find(strcmp(all_event_rows,'notboundary')==1);

EEG.event(rows_boundary) = [];
all_event_rows(rows_boundary) = [];

all_event_rows = {EEG.event.type}';
bad_event_names = 'S244';
rows_bad = find(strcmp(all_event_rows,bad_event_names)==1);


EEG.event(rows_bad) = [];
all_event_rows(rows_bad) = [];

all_event_rows = {EEG.event.type}';
bad_event_names = 'S248';
rows_bad = find(strcmp(all_event_rows,bad_event_names)==1);


EEG.event(rows_bad) = [];
all_event_rows(rows_bad) = [];

all_event_rows = {EEG.event.type}';
bad_event_names = 'S245';
rows_bad = find(strcmp(all_event_rows,bad_event_names)==1);


EEG.event(rows_bad) = [];
all_event_rows(rows_bad) = [];

all_event_rows = {EEG.event.type}';
bad_event_names = 'S249';
rows_bad = find(strcmp(all_event_rows,bad_event_names)==1);


EEG.event(rows_bad) = [];
all_event_rows(rows_bad) = [];

all_event_rows = {EEG.event.type}';
bad_event_names = 'R 21';
rows_bad = find(strcmp(all_event_rows,bad_event_names)==1);


EEG.event(rows_bad) = [];
all_event_rows(rows_bad) = [];

all_event_rows = {EEG.event.type}';
bad_event_names = 'S243';
rows_bad = find(strcmp(all_event_rows,bad_event_names)==1);


EEG.event(rows_bad) = [];
all_event_rows(rows_bad) = [];


% save set file with fixed events
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'savenew',[sub_ID '_SEPs_merged_filtered_downsampled_all_ch_fixed_events'],'gui','off'); 


%% remove noneeg channels

if length(EEG.chanlocs)>63
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG, 'nochannel',{'VEOG','HEOG'});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off'); 
end 

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'savenew',[sub_ID '_SEPs_merged_filtered_downsampled_eeg_ch_only'],'gui','off'); 



%% clean raw data using GUI


%% interpolate using GUI


%% average reference using GUI:
    EEG = eeg_checkset( EEG );

    EEG.nbchan = EEG.nbchan+1;
    EEG.data(end+1,:) = zeros(1, EEG.pnts);
    EEG.chanlocs(1,EEG.nbchan).labels = 'Fz';
    EEG=pop_chanedit(EEG, 'lookup','/Users/jasminemirdamadi/Documents/MATLAB/eeglab2021.0/plugins/dipfit4.3/standard_BEM/elec/standard_1005.elc');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off'); 

    EEG = pop_reref(EEG, []);

EEG = eeg_checkset( EEG );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'savenew',[sub_ID '_proc_cleanrawdata_avg_ref_merged_SEPs_fixed_events'],'gui','off'); 

%% run cleanline
 EEG = pop_zapline_plus(EEG, 'noisefreqs','line','coarseFreqDetectPowerDiff',7,'chunkLength',0,'adaptiveNremove',1,'fixedNremove',1);
%[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'savenew','/Users/jasminemirdamadi/Desktop/PD_EEG/PD21amica/add_orig_ref/newwww/PD21_filtered_downsampled_rank_avg_ref_withFz_dropFzzapline.set','gui','off'); 
  %  [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'gui','off'); 
  [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 8,'savenew',[sub_ID '_proc_avg_ref_zapline'],'gui','off'); 
%% extract epochs, but do not remove epoch baseline
EEG = pop_epoch( EEG, {  'left sit'  'left stand'  'right sit'  'right stand'  }, [-0.2         0.4], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 15,'savenew',[sub_ID '_SEPs_epoched'],'gui','off'); 

EEG = eeg_checkset( EEG );

%% run amica, GUI

%% bad epochs, after amica
% auto rejectio from makoto
badTrialIdx = rejectTrialSTFT(EEG.icaact, 3, EEG.pnts, EEG.srate, [15 50]);
EEG = pop_select(EEG, 'notrial', badTrialIdx);

% figure out trials that have double pulses (sometimes 2-4 trials total)
% two_four = [];
% for i = 1:length(EEG.epoch);
%     two_four = [two_four; length(EEG.epoch(i).event)];
% end 
% 
% remove = find(two_four==4);
% EEG = pop_select(EEG,'notrial',remove);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 

%% remove epoch baseline
%close all;
EEG = pop_rmbase( EEG, [-200 0] ,[]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 

%% plot SEPs in channel space
close all;
EEG = eeg_checkset( EEG );
paretic_side = input('enter 1 for left paretic leg and 2 for right paretic leg: ');
 all_event_rows = {EEG.event.type}';
% bad_event_names = 'S 11';
% rows_bad = strcmp(all_event_rows,bad_event_names);
% all_event_rows(rows_bad) = [];
% clear all_event_rows
% all_event_rows = [EEG.epoch.eventtype]';
for electrode = 1:4
figure
event_names = {'left sit', 'left stand', 'right sit', 'right stand'};

   if electrode == 1
        ch_index = 23;
        title_text = 'Cz';
    elseif electrode == 2
        ch_index = 52;
        title_text = 'CPz';
   elseif electrode == 3
        ch_index = 63;
        title_text = 'FCz';
   else 
                ch_index = 64;
        title_text = 'Fz';
    
%         
%     if electrode == 1
%         ch_index = 21;
%         title_text = 'Cz';
%     elseif electrode == 2
%         ch_index = 50;
%         title_text = 'CPz';
%     elseif electrode == 3
%         ch_index = 61;
%         title_text = 'FCz';
%           else
%         ch_index = 62;
%         title_text = 'Fz';
     end 
     
for e = 1:4
if e == 1 | e == 3
linestyle = '-';
else
linestyle = '-.';
end

if e == 1 | e == 2
linecolor = 'm';
else
linecolor = 'b';
end 
    rows_event_type = strcmp(all_event_rows,event_names{e});
    rows_index = find(rows_event_type ==1);
 %   rows_index = rows_index(1:end-2,1);
    SEP = [];
SEP = EEG.data(ch_index,:,rows_index);
% FCz = EEG.data(63,:,rows_index);
% 
% CPz = EEG.data(52,:,rows_index);

SEP = squeeze(SEP);
% FCz = squeeze(FCz);
% CPz = squeeze(CPz);

%plot(EEG.times, smooth(nanmean(CPz,2))); hold on
plot(EEG.times, smooth(nanmean(SEP,2)),'LineStyle',linestyle,'Color',linecolor); hold on
%plot(EEG.times, nanmean(SEP,2)); hold on

end 
if paretic_side == 1
event_names = {'paretic sit','paretic stand','nonparetic sit','nonparetic stand'};
elseif paretic_side == 2
event_names = {'nonparetic sit','nonparetic stand','paretic sit','paretic stand'};
end 
legend(event_names);
legend box off
ax = gca;
ax.XLim = [-100 250];
%ax.YLim = [-2 2];
title(title_text)
end 

%% plot in component space
comp_num = input('enter the parietal component: ');
%for electrode = 1:4
figure
event_names = {'left sit', 'left stand', 'right sit', 'right stand'};

  title_text = 'parietal component';
     
for e = 1:4
if e == 1 | e == 3
linestyle = '-';
else
linestyle = '-.';
end

if e == 1 | e == 2
linecolor = 'm';
else
linecolor = 'b';
end 
    rows_event_type = strcmp(all_event_rows,event_names{e});
    rows_index = find(rows_event_type ==1);
    %rows_index = rows_index(1:end-4,1);
    SEP = [];
SEP = EEG.icaact(comp_num,:,rows_index);


SEP = squeeze(SEP);


%plot(EEG.times, smooth(nanmean(CPz,2))); hold on
plot(EEG.times, smooth(nanmean(SEP,2)),'LineStyle',linestyle,'Color',linecolor); hold on
%plot(EEG.times, nanmean(SEP,2)); hold on

end 
if paretic_side == 1
event_names = {'paretic sit','paretic stand','nonparetic sit','nonparetic stand'};
elseif paretic_side == 2
event_names = {'nonparetic sit','nonparetic stand','paretic sit','paretic stand'};
end 
legend(event_names);
legend box off
ax = gca;
ax.XLim = [-100 250];
%ax.YLim = [-2 2];
title(title_text)

