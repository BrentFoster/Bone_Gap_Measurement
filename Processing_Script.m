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
boxplot(z,g, 'Notch','off','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})
ylabel('Scaphoid-Lunate Gap (mm)')
title('Bone Gap vs. Wrist Angle on Active MRI')

hold on
% scatter(g,z,'r*')
% histogram(x,angle_bins)

%% Split by scan type
close all



% Create box plots
z=[];
g=[];
temp= [];
iter = 0;
labels = {};

figure('Color', [1 1 1])

scan_types = {'Gridding 100 Spokes', 'Gridding 40 Spokes', 'TV L1 40 Spokes'};

for j = 1:length(unique(data.four_d_scan_type)) 
    h=subplot(1,3,j)
    z=[];
    g=[];
    temp= [];
    iter = 0;
    labels = {};
    
    for i = 1:length(unique(ndx))
        [i j]
        
        temp = [ndx; data.four_d_scan_type']';
        temp = data.four_d_gaps(all((temp == [i j])'));
        z = [z; temp]   ;
        
        g = [g; iter*ones(length(temp), 1)];
        iter = iter+ 1;
        labels{iter} = ['Scan ' num2str(j) ' position ' num2str(i)]
        
    end
    

%     boxplot(z,g, 'Labels', labels)%, 'Notch','on','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})
    boxplot(z,g, 'Labels', {'UD', 'UD - N', 'N', 'N-RD', 'RD'})%, 'Notch','on','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})
     
    % Adjust the boxplot to the left some
    pos = get(h, 'Position') ;
    posnew = pos; posnew(1) = posnew(1) + 0.04; set(h, 'Position', posnew);


    ylabel('Scaphoid-Lunate Gap (mm)')

    title('Bone Gap vs. Wrist Angle on Active MRI')
    title(scan_types{j})
    ylim([0.2 4.7])
    hold on

end



%% 

combined_data = [data.four_d_gaps data.four_d_angles data.four_d_scan_type data.four_d_angle_ndx']

% Sort based on the type of scan
[~,idx] = sort(combined_data(:,3)); % sort just the 4D scan type column
combined_data = combined_data(idx,:)   % sort the whole matrix using the sort indices

% Sub-sort based on the wrist angle index

[~,idx] = sort(combined_data(:,3))
combined_data = combined_data(idx,:)   

%% VIBE Gap Measurements

% Order is Neutral, Radial Deviation, Ulnar Deviation
z=[];
g=[];
for i = 1:length(data.VIBE_gaps)
    
   z = [z data.VIBE_gaps(i)];
   
   if (mod(i,3) == 0)
        g = [g 3];
   else
       g = [g  mod(i,3)];
   end
  
    
end

% Reorder to have RD, Neutral, UD
temp = g;
g(temp == 1) = 2;
g(temp == 2) = 1;
figure('Color', [1 1 1])
boxplot(z,g, 'Labels', {'Radial Deviation', 'Neutral', 'Ulnar Deviation'})%, 'Notch','on','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})

ylabel('Scaphoid-Lunate Gap (mm)')
ylim([0.2 4.7])
title('VIBE - Bone Gap vs. Wrist Angle')

