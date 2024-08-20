%% 
close all; clear all; clc

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
sub_ID = input('enter the subject ID: ','s');
task = input('enter the task name (TRACE, MDT, SSEP): ','s');
eegfiles = dir('*.vhdr');


% load each .vhdr file for different conditions; upon loading, remove entire baseline (DC drift),
% perfomr 1 Hz HPF, and downsample; then save new set file

for i = 1:8 % set to # of conditions/files
%EEG = pop_loadbv(['/Volumes/MRIDRIVE/AHA_EEG/' sub_ID '/TRACE'],[eegfiles(i).name]);
EEG = pop_loadbv(['/Volumes/somrehab-ts/Groups/BorichLab/NB_VPI_EEG/' sub_ID '.sub/' task],[eegfiles(i).name]);

[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );

% remove epoch baslei
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [],[]);

% HPF
EEG = eeg_checkset( EEG );
cutoff_freq = 0.5;
EEG = pop_eegfiltnew(EEG, [],cutoff_freq+0.5,16500,true,[],0);

% downsample 
EEG = eeg_checkset( EEG );
EEG = pop_resample( EEG, 500);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); % % 
EEG = eeg_checkset( EEG );

% save
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',[eegfiles(i).name(1:end-4) '_base_rm_filtered'],'gui','off'); 

end 

%% load initial preprocessed set files

files_set = dir('*.set'); % get list of files that have initial preprocessing for four conditions
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
for i = 1:length(files_set)
EEG = pop_loadset('filename', files_set(i).name, 'filepath', ['/Volumes/somrehab-ts/Groups/BorichLab/NB_VPI_EEG/' sub_ID '.sub/' task]);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
end

%% merge set files into one
EEG = eeg_checkset( EEG );
EEG = pop_mergeset( ALLEEG, [1 2 3 4 5 6 7 8], 0); % set to 1 2 3 4 or 1 2 3 4 5 6 7 8 if doing all conditions
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); % set to 4 or 8

%% add channels locations, and save merged set file
EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'lookup','/Users/nathan/Documents/MATLAB/eeglab2024.0/plugins/dipfit/standard_BEM/elec/standard_1005.elc');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',[sub_ID '_merged_filtered_downsampled_all_ch'],'gui','off'); %set to 4 or 8

%% fix events
%%MUST ENTER TASK NAME "MDT" OR "TRACE" OR "SSEP"
%task = "SSEP";

EEG = eeg_checkset( EEG );

all_trials = [EEG.event.duration]; 

good_rows = [];
boundary_rows = [];
extra_event_rows = [];

for i = 1:length(all_trials)
    find_rows = strcmp(EEG.event(i).type,'S248');
    if find_rows == 1
        EEG.event(i-1).type = 'REMOVE';
    end
end


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
if task == "SSEP"
for i = boundary_index(1):boundary_index(2) % first set
    find_rows= strcmp(EEG.event(i).type,'S255');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(3):boundary_index(4) % first set
    find_rows= strcmp(EEG.event(i).type,'S255');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 
for i = boundary_index(5):boundary_index(6) % first set
    find_rows= strcmp(EEG.event(i).type,'S255');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(7):length(all_trials) % first set
    find_rows= strcmp(EEG.event(i).type,'S255');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(1):boundary_index(2) % first set
    find_rows= strcmp(EEG.event(i).type,'S255');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_NOVIS_SIT';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(3):boundary_index(4) % first set
    find_rows= strcmp(EEG.event(i).type,'S255');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_VIS_SIT';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 
for i = boundary_index(5):boundary_index(6) % first set
    find_rows= strcmp(EEG.event(i).type,'S255');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_NOVIS_STAND';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(7):length(all_trials) % first set
    find_rows= strcmp(EEG.event(i).type,'S255');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_VIS_STAND';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 
end
%%%%% end SSEP only


%%%if Right Only
if task == "RIGHTONLY"
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
end
%%%%% end right only

%for 242 #MDT
if task == "MDT"
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
    EEG.event(i).type = 'LEFT_VIS_SIT';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(5):boundary_index(6) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_NOVIS_STAND';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
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
    EEG.event(i).type = 'RIGHT_VIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 
for i = boundary_index(13):boundary_index(14) % first set
    find_rows= strcmp(EEG.event(i).type,'S242');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
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
end
%end 242

%for 240 #trace
if task == "TRACE"
for i = boundary_index(1):boundary_index(2) % first set
    find_rows= strcmp(EEG.event(i).type,'S240');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_NOVIS_SIT';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(3):boundary_index(4) % first set
    find_rows= strcmp(EEG.event(i).type,'S240');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_VIS_SIT';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(5):boundary_index(6) % first set
    find_rows= strcmp(EEG.event(i).type,'S240');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_NOVIS_STAND';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(7):boundary_index(8) % first set
    find_rows= strcmp(EEG.event(i).type,'S240');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_VIS_STAND';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(9):boundary_index(10) % first set
    find_rows= strcmp(EEG.event(i).type,'S240');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(11):boundary_index(12) % first set
    find_rows= strcmp(EEG.event(i).type,'S240');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 
for i = boundary_index(13):boundary_index(14) % first set
    find_rows= strcmp(EEG.event(i).type,'S240');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(15):length(all_trials) % first set
    find_rows= strcmp(EEG.event(i).type,'S240');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 
end

%end 240

%for 254
if task == "254"
for i = boundary_index(1):boundary_index(2) % first setset
    find_rows= strcmp(EEG.event(i).type,'S254');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_NOVIS_SIT';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(3):boundary_index(4) % first set
    find_rows= strcmp(EEG.event(i).type,'S254');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_VIS_SIT';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(5):boundary_index(6) % first 
    find_rows= strcmp(EEG.event(i).type,'S254');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_NOVIS_STAND';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(7):boundary_index(8) % first set
    find_rows= strcmp(EEG.event(i).type,'S254');
    if find_rows == 1
    EEG.event(i).type = 'LEFT_VIS_STAND';
    EEG.event(i).bvtime = 'LEFT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(9):boundary_index(10) % first set
    find_rows= strcmp(EEG.event(i).type,'S254');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 

for i = boundary_index(11):boundary_index(12) % first set
    find_rows= strcmp(EEG.event(i).type,'S254');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_SIT';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'SIT';
    end 
end 
for i = boundary_index(13):boundary_index(14) % first set
    find_rows= strcmp(EEG.event(i).type,'S254');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_NOVIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'NOVIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 

for i = boundary_index(15):length(all_trials) % first set
    find_rows= strcmp(EEG.event(i).type,'S254');
    if find_rows == 1
    EEG.event(i).type = 'RIGHT_VIS_STAND';
    EEG.event(i).bvtime = 'RIGHT'
    EEG.event(i).visible = 'VIS';
    EEG.event(i).bvmknum = 'STAND';
    end 
end 
end
%end 254

%for 243
if task == "243"
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
end
%end 243


%for 245
if task == "245"
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
bad_event_names = 'S248';
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
bad_event_names = 'S244';
rows_bad = find(strcmp(all_event_rows,bad_event_names)==1);

EEG.event(rows_bad) = [];
all_event_rows(rows_bad) = [];

bad_event_names = 'S242';
rows_bad = find(strcmp(all_event_rows,bad_event_names)==1);

EEG.event(rows_bad) = [];
all_event_rows(rows_bad) = [];

bad_event_names = 'S255';
rows_bad = find(strcmp(all_event_rows,bad_event_names)==1);

EEG.event(rows_bad) = [];
all_event_rows(rows_bad) = [];

bad_event_names = 'S254';
rows_bad = find(strcmp(all_event_rows,bad_event_names)==1);

EEG.event(rows_bad) = [];
all_event_rows(rows_bad) = [];

% save set file with fixed events
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',[sub_ID '_SEPs_merged_filtered_downsampled_all_ch_fixed_events'],'gui','off'); 

%% remove noneeg channels
EEG = eeg_checkset(EEG);
eeglab redraw;

if length(EEG.chanlocs)>63
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG, 'nochannel',{'VEOG','HEOG'});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 
end 

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',[sub_ID '_SEPs_merged_filtered_downsampled_eeg_ch_only'],'gui','off'); 
 
%% clean raw data
EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
EEG = eeg_checkset(EEG);
eeglab redraw;
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname','Merged datasets_rawclean','gui','off'); 

%% Interpolate
% Determine the total number of datasets in ALLEEG
numDatasets = length(ALLEEG);

% Initialize index
index = -1;

% Find the last dataset with exactly 62 channels
for idx = 1:numDatasets
    if length(ALLEEG(idx).chanlocs) == 62
        index = idx;  % Update index to the current dataset with 62 channels
    end
end

% Check if a suitable index was found and if the current EEG dataset has fewer than 62 channels
if index ~= -1 && length(EEG.chanlocs) < 62
    % Perform the interpolation only if there are fewer than 62 channels
    EEG = pop_interp(EEG, ALLEEG(index).chanlocs, 'spherical');

    % Validate the EEG dataset
    EEG = eeg_checkset(EEG);
    
    % Redraw the EEGLAB GUI
    eeglab redraw;

    % Add the updated dataset to ALLEEG
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, numDatasets + 1, 'gui', 'off');
else
    % Optional: Handle the case where no dataset with exactly 62 channels was found
    disp('No dataset with exactly 62 channels found.');
end


%% average reference using GUI:
EEG = fullRankAveRef(EEG);

%% run zapline plus
 EEG = pop_zapline_plus(EEG, 'noisefreqs','line','coarseFreqDetectPowerDiff',7,'chunkLength',0,'adaptiveNremove',1,'fixedNremove',1);
 EEG = eeg_checkset(EEG);
 eeglab redraw;
 [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',[sub_ID '_proc_avg_ref_zapline'],'gui','off'); 

%% Save before AMICA
  %before running amica
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',[sub_ID '_preamica'],'gui','off'); 

%% run amica, GUI
%after runnig amica
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',[sub_ID '_postamica'],'gui','off'); 

%% label 
EEG = pop_iclabel(EEG, 'default');
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

%% flag
EEG = pop_icflag(EEG, [NaN NaN;0.2 1;0.2 1;0.2 1;0.2 1;0.2 1;0.2 1]);
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

%% before removing components
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',[sub_ID '_precomponentremove'],'gui','off'); 

%% Remove components
EEG = pop_subcomp( EEG, [], 0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 

%after removing components
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',[sub_ID '_postcomponentremove'],'gui','off'); 

%% extract epochs, but do not remove epoch baseline
EEG = pop_epoch( EEG, {  }, [-4  9], 'newname', 'epoched', 'epochinfo', 'yes');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',[sub_ID '_epoched'],'gui','off'); 

%% clean by eye
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',[sub_ID '_epoched_cleaned'],'gui','off'); 

%% Pre FOOOF: loads fully preprocessed & cleaned data and creates average mat files for all subjects/electrodes/conditions
% subjects (only subject directories with .sub extension) 
% electrodes (manually specified below)
% conditions (automatically taken from EEG.event.type)

% Set up parallel processing
if isempty(gcp('nocreate'))
    parpool('local');
end

% Parameters
overwriteExisting = true;
renameExisting = true;
subjectDirs = dir('*.sub');

% Preallocate a cell array to store results
results = cell(length(subjectDirs), 1);

parfor subIdx = 1:length(subjectDirs)
    try
        subjectDir = subjectDirs(subIdx).name;
        traceDir = fullfile(subjectDir, 'TRACE');
        epochedCleanDir = fullfile(traceDir, 'epoched_clean');
        
        % Check if epoched_clean directory exists
        if exist(epochedCleanDir, 'dir')
            % Get the .set file in the epoched_clean directory
            setFiles = dir(fullfile(epochedCleanDir, '*.set'));
            
            if ~isempty(setFiles)
                setFile = setFiles(1).name;
                filePath = epochedCleanDir;
                fileName = setFile;
                
                % Use pop_loadset to load the .set file
                EEG = pop_loadset('filename', fileName, 'filepath', filePath);
                
                % Pre FOOOF: pwelch for given subject, per epoch in all conditions and channels
                % Performs pwelch on entire pre and post onset windows
                % Parameters
                fs = EEG.srate; % Sampling frequency from EEG object
                nooverlap = 0;
                nfft = max(256, 2^nextpow2(4 * fs));  % Use the larger window size for FFT points
                channels = {'CP3', 'CP4', 'P3', 'P4', 'PO3', 'PO4', 'C3', 'C4'};
                conditions = unique({EEG.event.type}); % Extract unique conditions
                
                pwelchDir = fullfile(traceDir, 'pwelchresults');
                
                % Check if pwelchresults directory already exists
                if exist(pwelchDir, 'dir')
                    if renameExisting
                        % Rename existing pwelchresults directory by adding a number at the end
                        existingDirs = dir(fullfile(traceDir, 'pwelchresults*'));
                        newDirName = sprintf('pwelchresults_%d', length(existingDirs));
                        movefile(pwelchDir, fullfile(traceDir, newDirName));
                    else
                        continue; % Skip this subject if pwelchresults directory already exists
                    end
                end
                
                mkdir(pwelchDir);
                
                % Frequency range of interest (2 to 50 Hz)
                freqRange = [2 50];
                
                % Process all conditions, channels, and epochs
                processSubject(EEG, conditions, channels, fs, nooverlap, nfft, freqRange, pwelchDir, overwriteExisting);
                
                % Store results for this subject
                results{subIdx} = struct('subject', subjectDir, 'status', 'Completed');
            else
                results{subIdx} = struct('subject', subjectDir, 'status', 'No .set file found');
            end
        else
            results{subIdx} = struct('subject', subjectDir, 'status', 'No epoched_clean directory');
        end
    catch ME
        % If an error occurs, store the error information
        results{subIdx} = struct('subject', subjectDir, 'status', 'Error', 'message', ME.message);
    end
end

% Delete the parallel pool when done
delete(gcp('nocreate'));

% Process and display results
for i = 1:length(results)
    if ~isempty(results{i})
        fprintf('Subject: %s, Status: %s\n', results{i}.subject, results{i}.status);
        if isfield(results{i}, 'message')
            fprintf('Error message: %s\n', results{i}.message);
        end
    end
end

% Helper function to save data
function parsave(fname, psd, freqs)
    save(fname, 'psd', 'freqs');
end

% Function to process a single subject
function processSubject(EEG, conditions, channels, fs, nooverlap, nfft, freqRange, pwelchDir, overwriteExisting)
    for condIdx = 1:length(conditions)
        cond = conditions{condIdx};
        condDir = fullfile(pwelchDir, cond);
        
        for ch = 1:length(channels)
            chName = channels{ch};
            chDir = fullfile(condDir, chName);
            
            preonsetDir = fullfile(chDir, 'preonset');
            postonsetDir = fullfile(chDir, 'postonset');
            if ~exist(preonsetDir, 'dir'); mkdir(preonsetDir); end
            if ~exist(postonsetDir, 'dir'); mkdir(postonsetDir); end
            
            epochIndices = find(strcmp({EEG.event.type}, cond));
            
            for epochIdx = epochIndices
                epochPreonsetDir = fullfile(preonsetDir, sprintf('epoch_%d', epochIdx));
                epochPostonsetDir = fullfile(postonsetDir, sprintf('epoch_%d', epochIdx));
                if ~exist(epochPreonsetDir, 'dir'); mkdir(epochPreonsetDir); end
                if ~exist(epochPostonsetDir, 'dir'); mkdir(epochPostonsetDir); end
                
                % Pre-onset window
                preStartSample = max(1, fs * 1);
                preEndSample = fs * 3;
                
                preFilename = fullfile(epochPreonsetDir, 'spec_pre.mat');
                if overwriteExisting || ~exist(preFilename, 'file')
                    preSegmentData = EEG.data(ch, preStartSample:preEndSample, epochIdx);
                    window_length = 2 * fs;
                    [psd, freqs] = pwelch(preSegmentData, window_length, nooverlap, nfft, fs);
                    
                    % Extract PSD within the frequency range of interest
                    freqIndices = freqs >= freqRange(1) & freqs <= freqRange(2);
                    psd = psd(freqIndices);
                    freqs = freqs(freqIndices);
                    
                    % Save psd and freqs directly
                    parsave(preFilename, psd, freqs);
                end
                
                % Post-onset window
                postStartSample = fs * 5;
                postEndSample = fs * 13;
                
                postFilename = fullfile(epochPostonsetDir, 'spec_post.mat');
                if overwriteExisting || ~exist(postFilename, 'file')
                    postSegmentData = EEG.data(ch, postStartSample:postEndSample, epochIdx);
                    window_length = 2 * fs;
                    [psd, freqs] = pwelch(postSegmentData, window_length, nooverlap, nfft, fs);
                    
                    % Extract PSD within the frequency range of interest
                    freqIndices = freqs >= freqRange(1) & freqs <= freqRange(2);
                    psd = psd(freqIndices);
                    freqs = freqs(freqIndices);
                    
                    % Save psd and freqs directly
                    parsave(postFilename, psd, freqs);
                end
            end
        end
    end
    
    % Average the results
    averageResults(pwelchDir, conditions, channels);
end

% Function to average results
function averageResults(baseDir, conditions, channels)
    for condIdx = 1:length(conditions)
        cond = conditions{condIdx};
        condDir = fullfile(baseDir, cond);
        
        for ch = 1:length(channels)
            chName = channels{ch};
            chDir = fullfile(condDir, chName);
            
            preonsetDir = fullfile(chDir, 'preonset');
            postonsetDir = fullfile(chDir, 'postonset');
            
            for onsetDir = {preonsetDir, postonsetDir}
                onsetDir = onsetDir{1};
                epochDirs = dir(fullfile(onsetDir, 'epoch_*'));
                
                allEpochPsd = [];
                for i = 1:length(epochDirs)
                    epochDir = fullfile(onsetDir, epochDirs(i).name);
                    files = dir(fullfile(epochDir, '*.mat'));
                    
                    % Load PSD data from each epoch file and concatenate
                    epochPsd = [];
                    for j = 1:length(files)
                        file = load(fullfile(epochDir, files(j).name));
                        epochPsd = [epochPsd; file.psd'];
                    end
                    allEpochPsd = [allEpochPsd; epochPsd];
                end
                
                % Calculate average PSD
                avgPsd = mean(allEpochPsd, 1);
                
                % Save averaged PSD results
                avgFilename = fullfile(onsetDir, 'avg_spec.mat');
                parsave(avgFilename, avgPsd, file.freqs);
            end
        end
    end
end

%% Pre FOOOF: pwelch for given subject, per epoch in all conditions and channels
% Performs pwelch on each 1 second increment, including X seconds pre onset
% Parameters
overwriteExisting = false;
fs = EEG.srate; % Sampling frequency from EEG object
window = fs; % 1-second window, as data is downsampled to 500 Hz
nooverlap = 0; % No overlap for 1-second increments analysis
nfft = max(256, 2^nextpow2(window)); % Example FFT points
channels = {'CP3', 'CP4'};
conditions = unique({EEG.event.type}); % Extract unique conditions

baseDir = fullfile(pwd, 'pwelchresults');
if ~exist(baseDir, 'dir'); mkdir(baseDir); end

% Loop through conditions, channels, and epochs
for cond = conditions
    condDir = fullfile(baseDir, cond{1}); % Directory for this condition

    for ch = 1:length(channels)
        chName = channels{ch};
        chDir = fullfile(condDir, chName); % Directory for this channel

        % Setup preonset and postonset directories
        preonsetDir = fullfile(chDir, 'preonset');
        postonsetDir = fullfile(chDir, 'postonset');
        if ~exist(preonsetDir, 'dir'); mkdir(preonsetDir); end
        if ~exist(postonsetDir, 'dir'); mkdir(postonsetDir); end

        epochIndices = find(strcmp({EEG.event.type}, cond{1}));

        for epochIdx = epochIndices
            % Create directories for each epoch within preonset and postonset
            epochPreonsetDir = fullfile(preonsetDir, sprintf('epoch_%d', epochIdx));
            epochPostonsetDir = fullfile(postonsetDir, sprintf('epoch_%d', epochIdx));
            if ~exist(epochPreonsetDir, 'dir'); mkdir(epochPreonsetDir); end
            if ~exist(epochPostonsetDir, 'dir'); mkdir(epochPostonsetDir); end

            % Assuming task onset is at 0 seconds
            for sec = -4:9 % Adjust based on your specific pre and post duration
                if sec < 0
                    startSample = (4 + sec) * fs + 1; % Calculate start sample for preonset
                    endSample = startSample + fs - 1;
                    segmentDir = epochPreonsetDir;
                    segmentLabel = sec; % Label for identifying the segment
                else
                    startSample = sec * fs + 1; % Calculate start sample for postonset
                    endSample = startSample + fs - 1;
                    segmentDir = epochPostonsetDir;
                    segmentLabel = sec + 1; % Adjusting label for postonset to start from 1
                end

                % Define filename for saving PSD for this segment
                filename = fullfile(segmentDir, sprintf('spec_%s_%s_epoch%d_s%d.mat', chName, cond{1}, epochIdx, segmentLabel));
                
                if overwriteExisting == false
                    % Check if file exists before computing
                    if ~exist(filename, 'file')
                        % Extract data segment for this second
                        segmentData = EEG.data(ch, startSample:endSample, epochIdx);
    
                        % Apply pwelch on the segment
                        [psd, freqs] = pwelch(segmentData, window, nooverlap, nfft, fs);
    
                        % Save psd and freqs for this segment
                        save(filename, 'psd', 'freqs');
                    else
                        fprintf('Skipping existing file: %s\n', filename);
                    end
                else
                  % Extract data segment for this second
                    segmentData = EEG.data(ch, startSample:endSample, epochIdx);

                    % Apply pwelch on the segment
                    [psd, freqs] = pwelch(segmentData, window, nooverlap, nfft, fs);

                    % Save psd and freqs for this segment
                    save(filename, 'psd', 'freqs');
                end
            end
        end
    end
end

%% limo debugging
disp(['Model type: ', class({'ERSP ~ 1 + group + (1|subject)'})]);  % Check if it's 'cell'
disp('Contents of the model cell:');
disp({'ERSP ~ 1 + group + (1|subject)'});

% Check STUDY.design data structure
disp('Checking STUDY design content:');
disp(STUDY.design(1));

disp('Check unique subjects:');
disp(unique({ALLEEG.subject}));  % Adjust as necessary depending on how subject data is stored


%% Limo
model_formula = 'ERSP ~ 1 + bvmknum*visible*bvtime*group + (1|subject)';
STUDY = pop_limo(STUDY, 'design', 1, 'method', 'Mixed effects', 'measure', 'ersp', 'model', {'ERSP ~ 1  + (1|subject)'});

%% limo results
limo_plot_results()
limo_plot_contrast()

%% next
%%%%%%%%%%%%%%%%%%%
% for your epoched data, channel 60
[spectra,freqs] = spectopo(EEG.data(60,:,:), 0, EEG.srate);

% delta=1-4, theta=4-8, alpha=8-13, beta=13-30, gamma=30-80
deltaIdx = find(freqs>1 & freqs<4);
thetaIdx = find(freqs>4 & freqs<8);
alphaIdx = find(freqs>8 & freqs<13);
betaIdx  = find(freqs>13 & freqs<30);
lowbetaIdx = find(freqs>13 & freqs<16);
midbetaIdx = find(freqs>17 & freqs<20);
highbetaIdx = find(freqs>21 & freqs<30);
gammaIdx = find(freqs>30 & freqs<80);

% compute absolute power
deltaPower = mean(10.^(spectra(deltaIdx)/10));
thetaPower = mean(10.^(spectra(thetaIdx)/10));
alphaPower = mean(10.^(spectra(alphaIdx)/10));
betaPower  = mean(10.^(spectra(betaIdx)/10));
lowbetaPower = mean(10.^(spectra(lowbetaIdx)/10));
midbetaPower = mean(10.^(spectra(midbetaIdx)/10));
highbetaPower = mean(10.^(spectra(highbetaIdx)/10));
gammaPower = mean(10.^(spectra(gammaIdx)/10));
%%%%%%%%%%%%%%%%%

%% SAVING ERSP and SPECTRA OUTPUT as CSV LOOP
% Specify the base directory containing the subject folders
baseDir = '/Volumes/BorichLab/NB_VPI_EEG';

% Specify the channels of interest
channels = {'C4' 'CP4'};

% Specify whether to skip subjects with existing ERSP folder or rename it
skipExistingERSP = false;

% Get a list of subject folders ending with .sub
subjectFolders = dir(fullfile(baseDir, '*.sub'));

% Loop through each subject folder
for i = 1:length(subjectFolders)
    % Get the current subject folder
    subjectFolder = subjectFolders(i).name;
    
    % Extract the subject ID from the folder name
    subID = subjectFolder(1:end-4);
    
    % Construct the TRACE folder path
    traceFolder = fullfile(baseDir, subjectFolder, 'TRACE');
    
    % Construct the epoched_clean folder path
    epochedCleanFolder = fullfile(traceFolder, 'epoched_clean');
    
    % Check if the epoched_clean folder exists
    if ~exist(epochedCleanFolder, 'dir')
        fprintf('epoched_clean folder not found for subject %s. Skipping.\n', subID);
        continue;
    end
    
    % Construct the ERSP folder path
    erspFolder = fullfile(traceFolder, 'ERSP');
    
    % Construct the SPECTRA folder path
    spectraFolder = fullfile(traceFolder, 'SPECTRA');
    
    % Check if the ERSP folder already exists
    if exist(erspFolder, 'dir')
        if skipExistingERSP
            fprintf('Skipping subject %s. ERSP folder already exists.\n', subID);
            continue;
        else
            % Rename the existing ERSP folder with a number at the end
            existingERSPFolders = dir(fullfile(traceFolder, 'ERSP*'));
            newERSPFolderName = sprintf('ERSP_%d', length(existingERSPFolders));
            newERSPFolder = fullfile(traceFolder, newERSPFolderName);
            movefile(erspFolder, newERSPFolder);
            fprintf('Renamed existing ERSP folder to %s for subject %s.\n', newERSPFolderName, subID);
        end
    end
    
    % Create a new ERSP folder
    mkdir(erspFolder);
    
    % Check if the SPECTRA folder already exists
    if exist(spectraFolder, 'dir')
        % Rename the existing SPECTRA folder with a number at the end
        existingSpectraFolders = dir(fullfile(traceFolder, 'SPECTRA*'));
        newSpectraFolderName = sprintf('SPECTRA_%d', length(existingSpectraFolders));
        newSpectraFolder = fullfile(traceFolder, newSpectraFolderName);
        movefile(spectraFolder, newSpectraFolder);
        fprintf('Renamed existing SPECTRA folder to %s for subject %s.\n', newSpectraFolderName, subID);
    end
    
    % Create a new SPECTRA folder
    mkdir(spectraFolder);
    
    % Load the .set file from the epoched_clean folder
    setFile = dir(fullfile(epochedCleanFolder, '*.set'));
    if isempty(setFile)
        fprintf('No .set file found in the epoched_clean folder for subject %s. Skipping.\n', subID);
        continue;
    end
    EEG = pop_loadset(setFile.name, epochedCleanFolder);
    
    % Perform event selection and create condition-specific datasets
    EEG_R_VS_STAND = pop_selectevent(EEG, 'type', {'RIGHT_VIS_STAND'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
    EEG_L_VS_STAND = pop_selectevent(EEG, 'type', {'LEFT_VIS_STAND'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
    EEG_R_VS_SIT = pop_selectevent(EEG, 'type', {'RIGHT_VIS_SIT'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
    EEG_L_VS_SIT = pop_selectevent(EEG, 'type', {'LEFT_VIS_SIT'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
    EEG_R_NV_STAND = pop_selectevent(EEG, 'type', {'RIGHT_NOVIS_STAND'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
    EEG_L_NV_STAND = pop_selectevent(EEG, 'type', {'LEFT_NOVIS_STAND'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
    EEG_R_NV_SIT = pop_selectevent(EEG, 'type', {'RIGHT_NOVIS_SIT'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
    EEG_L_NV_SIT = pop_selectevent(EEG, 'type', {'LEFT_NOVIS_SIT'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
    
    % Save the times array
    times = EEG.times;
    csvwrite(fullfile(erspFolder, 'times.csv'), times(:));
    
    % Initialize a cell array to store the spectra data
    spectraData = {};
    
    % Define frequency bands
    bands = {'delta', 'theta', 'alpha', 'beta', 'lowbeta', 'midbeta', 'highbeta', 'gamma'};
    
    % Loop through each channel
    for j = 1:length(channels)
        channel = channels{j};
        channelIdx = strcmp({EEG.chanlocs.labels}, channel);
        
        % Calculate ERSP for each condition and save the results
        conditions = {'R_VS_STAND', 'L_VS_STAND', 'R_VS_SIT', 'L_VS_SIT', 'R_NV_STAND', 'L_NV_STAND', 'R_NV_SIT', 'L_NV_SIT'};
        for k = 1:length(conditions)
            condition = conditions{k};
            EEG_condition = eval(sprintf('EEG_%s', condition));
            
            [ersp, itc, powbase, times, frequencies] = pop_newtimef(EEG_condition, 1, EEG_condition.chanlocs(channelIdx).urchan, [-4000 9000], [3 0.8], 'topovec', EEG_condition.chanlocs(channelIdx).urchan, 'elocs', EEG_condition.chanlocs, 'chaninfo', EEG_condition.chaninfo, 'caption', channel, 'baseline', [0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000, 'plotersp', 'off', 'plotitc', 'off', 'plotphasesign', 'off');
            
            filename = sprintf('%s_%s_%s.csv', subID, condition, channel);
            csvwrite(fullfile(erspFolder, filename), ersp);
            
            % Calculate absolute power for different frequency bands
           [numChannels, numTimePoints, numEpochs] = size(EEG_condition.data);
            disp(['Number of channels: ' num2str(numChannels)]);
            disp(['Number of time points: ' num2str(numTimePoints)]);
            disp(['Number of epochs: ' num2str(numEpochs)]);
            
            
            % Specify the time range in seconds
            timeRange = [0 8]; % Analyze data from 0 to 1000 milliseconds (assuming 1000 Hz sampling rate)
            
            % Convert time range to sample points
            startSample = round(timeRange(1) * EEG_condition.srate) + 1;
            endSample = round(timeRange(2) * EEG_condition.srate);
            
            % Extract the desired time range from the data
            data = EEG_condition.data(channelIdx, startSample:endSample, :);
            
            % Reshape the data to match the expected format (channels, frames, epochs)
            data = reshape(data, 1, endSample - startSample + 1, numEpochs);
            
            % Call spectopo with the reshaped data
            [spectra, freqs] = spectopo(data, 0, EEG_condition.srate, 'verbose', 'off');
                        %[spectra, freqs] = spectopo(EEG_condition.data(channelIdx,:,:), 0, EEG_condition.srate, 'verbose', 'off');
            
            deltaIdx = find(freqs>1 & freqs<4);
            thetaIdx = find(freqs>4 & freqs<8);
            alphaIdx = find(freqs>8 & freqs<13);
            betaIdx = find(freqs>13 & freqs<30);
            lowbetaIdx = find(freqs>13 & freqs<16);
            midbetaIdx = find(freqs>17 & freqs<20);
            highbetaIdx = find(freqs>21 & freqs<30);
            gammaIdx = find(freqs>30 & freqs<80);
            
            deltaPower = mean(10.^(spectra(deltaIdx)/10));
            thetaPower = mean(10.^(spectra(thetaIdx)/10));
            alphaPower = mean(10.^(spectra(alphaIdx)/10));
            betaPower = mean(10.^(spectra(betaIdx)/10));
            lowbetaPower = mean(10.^(spectra(lowbetaIdx)/10));
            midbetaPower = mean(10.^(spectra(midbetaIdx)/10));
            highbetaPower = mean(10.^(spectra(highbetaIdx)/10));
            gammaPower = mean(10.^(spectra(gammaIdx)/10));
            
            % Store the power values in the spectraData cell array
            powerValues = [deltaPower, thetaPower, alphaPower, betaPower, lowbetaPower, midbetaPower, highbetaPower, gammaPower];
            
            % Extract Limb, Feedback, and Posture from the condition name
            conditionParts = strsplit(condition, '_');
            Limb = conditionParts{1};
            Feedback = conditionParts{2};
            Posture = conditionParts{3};
            
            % Create rows for each band and power value
            for b = 1:length(bands)
                spectraData = [spectraData; {channel, Limb, Feedback, Posture, bands{b}, powerValues(b)}];
            end
        end
    end
    
    % Create a table from the spectraData cell array
    spectraTable = cell2table(spectraData, 'VariableNames', {'Channel', 'Limb', 'Feedback', 'Posture', 'Band', 'Power'});
    
    % Save the spectraTable as a CSV file
    writetable(spectraTable, fullfile(spectraFolder, sprintf('%s_spectra.csv', subID)));
    
    fprintf('Completed ERSP and spectra calculation for subject %s.\n', subID);
end

    csvwrite('freqs.csv', frequencies(:));
    csvwrite('times.csv', times(:));


%% SAVING ERSP OUTPUT AS .CSV'S

EEG_R_VS_STAND = pop_selectevent( EEG, 'type',{'RIGHT_VIS_STAND'},'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG_L_VS_STAND = pop_selectevent( EEG, 'type',{'LEFT_VIS_STAND'},'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG_R_VS_SIT = pop_selectevent( EEG, 'type',{'RIGHT_VIS_SIT'},'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG_L_VS_SIT = pop_selectevent( EEG, 'type',{'LEFT_VIS_SIT'},'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG_R_NV_STAND = pop_selectevent( EEG, 'type',{'RIGHT_NOVIS_STAND'},'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG_L_NV_STAND = pop_selectevent( EEG, 'type',{'LEFT_NOVIS_STAND'},'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG_R_NV_SIT = pop_selectevent( EEG, 'type',{'RIGHT_NOVIS_SIT'},'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG_L_NV_SIT = pop_selectevent( EEG, 'type',{'LEFT_NOVIS_SIT'},'deleteevents','off','deleteepochs','on','invertepochs','off');

csvwrite("times.csv", times(:))
channels = {'CP3' 'CP4' 'P3' 'P4' 'PO3' 'PO4' 'C3' 'C4'};


sub_ID = "NYA02";
[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 60, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_CPZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 60, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_CPZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 60, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_CPZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 60, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_CPZ.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 60, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_CPZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 60, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_CPZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 60, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_CPZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 60, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_CPZ.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 23, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_CP1_2.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 24, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_CP1_2.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 23, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_CP1_2.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 24, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_CP1_2.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 23, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_CP1_2.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 24, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_CP1_2.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 23, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_CP1_2.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 24, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_CP1_2.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 18, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_CZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 18, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_CZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 18, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_CZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 18, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_CZ.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 18, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_CZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 18, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_CZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 18, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_CZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 18, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_CZ.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 19, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_PZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 19, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_PZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 19, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_PZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 19, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_PZ.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 19, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_PZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 19, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_PZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 19, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_PZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 19, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_PZ.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 41, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_CP3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 41, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_CP3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 41, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_CP3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 41, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_CP3.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 41, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_CP3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 41, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_CP3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 41, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_CP3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 41, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_CP3.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 42, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_CP4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 42, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_CP4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 42, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_CP4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 42, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_CP4.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 42, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_CP4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 42, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_CP4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 42, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_CP4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 42, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_CP4.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 7, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_P3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 7, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_P3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 7, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'plotersp', 'off','plotitc', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_P3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 7, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_P3.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 7, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_P3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 7, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_P3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 7, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_P3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 7, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_P3.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 8, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_P4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 8, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_P4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 8, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_P4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 8, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_P4.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 8, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_P4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 8, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_P4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 8, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_P4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 8, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_P4.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 9, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_O1.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 9, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_O1.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 9, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_O1.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 9, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_O1.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 9, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_O1.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 9, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_O1.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 9, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_O1.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 9, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_O1.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 10, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_O2.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 10, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_O2.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 10, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_O2.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 10, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_O2.csv";
csvwrite(filename,ersp);

clf

[ersp, itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 10, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_O2.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 10, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_O2.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 10, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_O2.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 10, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_O2.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 62, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_OZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 62, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_OZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 62, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_OZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 62, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_OZ.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 62, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_OZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 62, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_OZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 62, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_OZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 62, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_OZ.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 59, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_FPZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 59, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_FPZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 59, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_FPZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 59, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_FPZ.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 59, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_FPZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 59, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_FPZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 59, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_FPZ.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 59, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_FPZ.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 37, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_AF3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 37, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_AF3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 37, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_AF3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 37, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_AF3.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 37, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_AF3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 37, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_AF3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 37, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_AF3.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 37, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_AF3.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_STAND, 1, 38, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_STAND_AF4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_STAND, 1, 38, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_STAND_AF4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_VS_SIT, 1, 38, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_VS_SIT_AF4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_VS_SIT, 1, 38, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_VS_SIT_AF4.csv";
csvwrite(filename,ersp);

clf

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_STAND, 1, 38, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_STAND_AF4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_STAND, 1, 38, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_STAND_AF4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_R_NV_SIT, 1, 38, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_R_NV_SIT_AF4.csv";
csvwrite(filename,ersp);

[ersp itc powbase times frequencies] = pop_newtimef( EEG_L_NV_SIT, 1, 38, [-4000  9000], [3         0.8] , 'topovec', 60, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'CPz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 2000);
filename = sub_ID + "_EEG_L_NV_SIT_AF4.csv";
csvwrite(filename,ersp);

clf
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

