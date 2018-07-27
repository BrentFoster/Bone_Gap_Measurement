clc
clear
close all

nbin = 5-1;
% angle_bins = quantile(x,nbin);
% angle_bins = [-inf; angle_bins(:); inf];

load('data.mat')

%% Find the angle bin index for each gap measurement
% 
% data.four_d_angles = data.four_d_angles  - 180;

ndx = [];
for i = 1:length(data.four_d_gaps)    
    for j = 1:nbin+1
       if(data.four_d_angles(i) > data.angle_bins(j)  && data.four_d_angles(i) < data.angle_bins(j+1))
           ndx(i) = j;
       end
    end    
end

[data.four_d_angles ndx']
[data.four_d_gaps ndx']

% Create box plots
z=[];
g=[];
for i = unique(ndx)
    z = [z; data.four_d_angles(ndx == i)]   
    g = [g; (i-1)*ones(length(data.four_d_gaps(ndx == i)), 1)];
end
g=g+1;


figure('Color', [1 1 1])
boxplot(z,g, 'Notch','off','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})
ylabel('Wrist Angle (degrees)')
title('Wrist Angle vs. Position on Active MRI')



% Create box plots
z=[];
g=[];
for i = unique(ndx)
    z = [z; data.four_d_gaps(ndx == i)]   
    g = [g; (i-1)*ones(length(data.four_d_gaps(ndx == i)), 1)];
end
g=g+1;



figure('Color', [1 1 1])
boxplot(z,g, 'Notch','on','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})
ylabel('Scaphoid-Lunate Gap (mm)')
title('Bone Gap vs. Wrist Angle on Active MRI')

hold on
% scatter(g,z,'r*')
% histogram(x,angle_bins)

%% Split by scan type
data.four_d_scan_type


% Create box plots
z=[];
g=[];
temp= [];
for i = 1:length(unique(ndx))
    for j = 1:length(unique(data.four_d_scan_type)) 
        [i j]
        
        temp = [ndx; data.four_d_scan_type']';
        temp = data.four_d_gaps(all((temp == [i j])'));
        z = [z; temp]   ;
        
        g = [g; (i+j-1)*ones(length(temp), 1)];
        
    end
end



figure('Color', [1 1 1])
boxplot(z,g)%, 'Notch','on','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})
ylabel('Scaphoid-Lunate Gap (mm)')
title('Bone Gap vs. Wrist Angle on Active MRI')

hold on

%% 

combined_data = [data.four_d_gaps data.four_d_angles data.four_d_scan_type data.four_d_angle_ndx']

% Sort based on the type of scan
[~,idx] = sort(combined_data(:,3)); % sort just the 4D scan type column
combined_data = combined_data(idx,:)   % sort the whole matrix using the sort indices

% Sub-sort based on the wrist angle index

[~,idx] = sort(combined_data(:,3))
combined_data = combined_data(idx,:)   


