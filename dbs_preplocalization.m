function dbs_preplocalization(options)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare_for_Localization                                                %
%                                                                         %
%                                                                         %
% Inputs:                                                                 %
% Post-op MRI: T1.nii (found in Freesurfer folder                         %                    
%                                                                         %
% Michael Randazzo 06/29/2015                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% UPDATED RIGHT NOW

% Subject_ID = options.patientname;
% Subject_Path = options.uipatdirs;
% OLD: Subject_Path = '/Users/richardsonlab/Dropbox/Electrode_Imaging/Fluoro_Imaging/Subjects/';
% NEW: Subject_Path = options.uipatdirs

% Check for fluoro converted to tiff?

directory = char(options.uifsdir);
cd(directory)
% Check for Electrode_Locations Folder
if ~exist([directory '\Electrode_Locations'])
    mkdir([directory,'\Electrode_Locations']);
end
%%%%%%%%%%%% Cortex %%%%%%%%%%%%%%

[cortex.vert_lh,cortex.tri_lh]= read_surf([directory,filesep,'surf/lh.pial']); % Reading left side pial surface
[cortex.vert_rh,cortex.tri_rh]= read_surf([directory,filesep,'surf/rh.pial']); % Reading right side pial surface

% Generating entire cortex
cortex.vert = [cortex.vert_lh; cortex.vert_rh]; % Combining both hemispheres
cortex.tri = [cortex.tri_lh; (cortex.tri_rh + length(cortex.vert_lh))]; % Combining faces (Have to add to number of faces)

cortex.tri=cortex.tri+1; % freesurfer starts at 0 for indexing

% Reading in MRI parameters
f=MRIread([directory,filesep,'mri/T1.mgz']);

% Translating into the appropriate space
for k=1:size(cortex.vert,1)
    a=f.vox2ras/f.tkrvox2ras*[cortex.vert(k,:) 1]';
    cortex.vert(k,:)=a(1:3)';
end

save([directory,filesep,'cortex_indiv.mat','cortex']);

% Skull
% find .obj filename
% files = dir(directory);

[skull.vert,skull.tri] = dbs_displayobj([options.patientname '_Bone.obj']);
save('skull.mat','skull')

% Create cortical hull
grayfilename = [char(options.uifsdir) '/mri/t1_class.nii'];
outputdir='hull';
disp('running dbs_gethull.......')
[~,~] = dbs_gethull(grayfilename,outputdir,3,21,.3);
disp('** Process Done')
end






