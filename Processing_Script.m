clc
clear
close all

nbin = 5-1;
% angle_bins = quantile(x,nbin);
% angle_bins = [-inf; angle_bins(:); inf];

load('data_B.mat')
 
data_B.four_d_angle_ndx = data_B.four_d_angle_ndx';
data_B = rmfield(data_B, 'angles');
% data = data_B;

load('data_C.mat')
% data = data_C;

data_B.four_d_angle_ndx = data_B.four_d_angle_ndx';

combine_data = true;
if combine_data == true

    % Combine bone data_B and data_C together
    % data=[];
    f = fieldnames(data_C);
     for i = 2:length(f) % Start at i=2 to skip the angle_bins field
        data.(f{i}) = [data_B.(f{i}); data_C.(f{i})];   

        if i == 6
            data.(f{i}) = [data_B.(f{i}) data_C.(f{i})];   
        end
     end

    data.angle_bins = data_B.angle_bins;
    data.four_d_angle_ndx = data.four_d_angle_ndx';
data
end

%% Calculate Inter-Observer Correlation Coefficient
clc
% For all images
f = fieldnames(data_C);
r_values = [];
for i = [2,3,5]  
    R = corrcoef(data_B.(f{i}), data_C.(f{i}))
    r_values(i) = R(2);
end
f{[2,3,5]}
r_values

% By scan type (i.e. number of spokes and reconstruction type)
f = fieldnames(data_C);
r_values_scan_type = [];
p_values_scan_type = [];
RL_values_scan_type = [];
RU_values_scan_type = [];
for i = [2]  % Structure field number
    for j = [1,2,3] % Scan type
        
        ndx = find( data_B.four_d_scan_type == j);
        temp_B = data_B.(f{i});
        temp_C = data_C.(f{i});
        [R,P,RL,RU] = corrcoef(temp_B(ndx), temp_C(ndx),'Alpha',0.00001);
        r_values_scan_type(i-1,j) = R(2);
        p_values_scan_type(i-1,j) = P(2);
        RL_values_scan_type(i-1,j) = RL(2);
        RU_values_scan_type(i-1,j) = RU(2);
        
        
    end
end
% f{[2,3]}
r_values_scan_type
p_values_scan_type
RL_values_scan_type
RU_values_scan_type

%%

% Comparison to VIBE (i.e take the RD, Neutral, and UD positions)
% By scan type (i.e. number of spokes and reconstruction type)
f = fieldnames(data_C);
r_values_gaps = [];
r_values_angles = [];

VIBE_position_ndx = repmat([1,3,5],1,10); % VIBE wrist position (1,3,5 are used to be the same as the 4D angle ndx)

Volunteer_ndx = [];
for i = 1:10
    Volunteer_ndx = [Volunteer_ndx i*ones(1,6*3)]
end

for i = 2  % Structure field number
    for j = [1,2,3] % Scan type
        for k = [1,3,5] % Wrist position
        
%             scan_ndx = find(data.four_d_scan_type == j)'
%             find(data.four_d_angle_ndx == k)
            
            
            temp = [data.four_d_scan_type data.four_d_angle_ndx'];
            
            ndx = find( all(temp == [j, k],2));
            
             
            temp_4D_Data = data.(f{i})(ndx);
            temp_VIBE_Data = data.VIBE_gaps(VIBE_position_ndx == k);
            
            temp_SL_gap = [];
            % Take the mean SL gap for each volunteer
            for z = 1:10
                temp_volunteer_ndx = find(Volunteer_ndx(ndx) == z);
                temp_SL_gap(z) = mean(temp_4D_Data(temp_volunteer_ndx))              
            end
            
            % Remove the NaN
            copy_temp_SL_gap = [];
            copy_temp_VIBE_Data = [];
            for z = 1:10
                if ~isnan(temp_SL_gap(z))
                    copy_temp_SL_gap = [copy_temp_SL_gap temp_SL_gap(z)];
                    copy_temp_VIBE_Data = [copy_temp_VIBE_Data temp_VIBE_Data(z)];
                end
            end

            
            R = corrcoef(copy_temp_SL_gap, copy_temp_VIBE_Data);
   
            r_values_gaps(j,k) = R(2);

        end
    end
end

r_values_gaps

mean(r_values_gaps(:,[1,3,5]),2)


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

mean_SL = [];
std_SL = [];
for i = 1:max(g)
    mean_SL(i) = mean(z(g==i));
    std_SL(i) = std(z(g==i));
end
mean_SL
std_SL

% scatter(g,z,'r*')
% histogram(x,angle_bins)

%% Split by scan type
% close all



% Create box plots
z=[];
g=[];
temp= [];
iter = 0;
labels = {};

% data.four_d_scan_type = data.four_d_scan_type';

figure('Color', [1 1 1])

scan_types = {'Gridding 100 Spokes', 'Gridding 40 Spokes', 'TV L1 40 Spokes'};
mean_SL = [];
std_SL = [];




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
    
    
    for k = 1:5
        mean_SL(j,k) = mean(z(g==k-1));
        std_SL(j,k) = std(z(g==k-1));
    end

end

mean_SL
std_SL

%% Split by scan type vs VIBE
close all



% Create box plots
z=[];
g=[];
temp= [];
iter = 0;
labels = {};

% data.four_d_scan_type = data.four_d_scan_type';

figure('Color', [1 1 1])

scan_types = {'Gridding (100 Spokes)', 'Gridding (40 Spokes)', 'FD+DCT (40 Spokes)'};
mean_SL = [];
std_SL = [];

% Median SL Gap was 1.5 on VIBE
mean_VIBE_SL_Gap = 1.5;

mean_SL_all_positions = [];
std_SL_all_positions = [];

all_measurements = {};

for j = 1:length(unique(data.four_d_scan_type)) 
    h=subplot(2,2,j);
    z=[];
    g=[];
    temp= [];
    iter = 0;
    labels = {};
    
    for i = [1,3,5]%length(unique(ndx))
       
        temp = [ndx; data.four_d_scan_type']';
        temp = data.four_d_gaps(all((temp == [i j])'));
        z = [z; temp]   ;
        
        g = [g; iter*ones(length(temp), 1)];
        iter = iter+ 1;
        labels{iter} = ['Scan ' num2str(j) ' position ' num2str(i)];
        
    end
    

%     boxplot(z,g, 'Labels', labels)%, 'Notch','on','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})
    boxplot(z,g, 'Labels', {'Ulnar Deviation', 'Neutral', 'Radial Deviation'})%, 'Notch','on','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})
     
    % Adjust the boxplot to the left some
    pos = get(h, 'Position') ;
    posnew = pos; posnew(1) = posnew(1) + 0.04; set(h, 'Position', posnew);


    ylabel('Scaphoid-Lunate Gap (mm)')

    title('Bone Gap vs. Wrist Angle on Active MRI')
    title(scan_types{j})
    ylim([0.2 4.7])
    hold on
    % Mean VIBE is 1.64 mm
%     mean_VIBE_SL_Gap = 1.64;
    hold on
    line(0:4,mean_VIBE_SL_Gap * ones(1,5),'Color','red','LineStyle','--', 'LineWidth', 2)
    axis square
    
    for k = 1:3
        mean_SL(j,k) = mean(z(g==k-1));
        std_SL(j,k) = std(z(g==k-1));
    end
    mean_SL_all_positions = [mean_SL_all_positions mean(z)];
    std_SL_all_positions = [std_SL_all_positions std(z)];
    
    all_measurements{end+1} = z;

end

% mean_SL
% std_SL


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
h=subplot(2,2,4);
boxplot(z,g, 'Labels', {'Ulnar Deviation', 'Neutral', 'Radial Deviation'})%, 'Notch','on','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})

% Adjust the boxplot to the left some
pos = get(h, 'Position') ;
posnew = pos; posnew(1) = posnew(1) + 0.04; set(h, 'Position', posnew);

ylabel('Scaphoid-Lunate Gap (mm)')
ylim([0.2 4.7])
title('VIBE (High Resolution)')
hold on
line(0:4,mean_VIBE_SL_Gap * ones(1,5),'Color','red','LineStyle','--', 'LineWidth', 2)

mean_SL_all_positions = [mean_SL_all_positions mean(z)]
std_SL_all_positions = [std_SL_all_positions std(z)]
all_measurements{end+1} = z';

axis square
%%
% Compare the measurements with VIBE
p_value=[];
for i = 1:3
    [p,h,stats] = ranksum(all_measurements{i},all_measurements{4});
    p_value(i) = p;
end
p_value

%%
%% Split by scan type vs VIBE
close all



% Create box plots
z=[];
g=[];
temp= [];
iter = 0;
labels = {};

% data.four_d_scan_type = data.four_d_scan_type';

figure('Color', [1 1 1])

scan_types = {'Gridding (100 Spokes)', 'Real-Time MRI (Fast GRE)', 'FD+DCT (40 Spokes)'};
mean_SL = [];
std_SL = [];

% Median SL Gap was 1.5 on VIBE
mean_VIBE_SL_Gap = 1.5;

mean_SL_all_positions = [];
std_SL_all_positions = [];

all_measurements = {};

for j = 2
    h=subplot(1,2,j-1);
    z=[];
    g=[];
    temp= [];
    iter = 0;
    labels = {};
    
    for i = [1,3,5]%length(unique(ndx))
       
        temp = [ndx; data.four_d_scan_type']';
        temp = data.four_d_gaps(all((temp == [i j])'));
        z = [z; temp]   ;
        
        g = [g; iter*ones(length(temp), 1)];
        iter = iter+ 1;
        labels{iter} = ['Scan ' num2str(j) ' position ' num2str(i)];
        
    end
    

%     boxplot(z,g, 'Labels', labels)%, 'Notch','on','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})
    boxplot(z,g, 'Labels', {'Ulnar Deviation', 'Neutral', 'Radial Deviation'})%, 'Notch','on','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})
     
    % Adjust the boxplot to the left some
    pos = get(h, 'Position') ;
    posnew = pos; posnew(1) = posnew(1) + 0.04; set(h, 'Position', posnew);


    ylabel('Scaphoid-Lunate Gap (mm)')

    title('Bone Gap vs. Wrist Angle on Active MRI')
    title(scan_types{j})
    ylim([0.2 4.7])
    hold on
    % Mean VIBE is 1.64 mm
%     mean_VIBE_SL_Gap = 1.64;
    hold on
%     line(0:4,mean_VIBE_SL_Gap * ones(1,5),'Color','red','LineStyle','--', 'LineWidth', 2)
    axis square
    
    for k = 1:3
        mean_SL(j,k) = mean(z(g==k-1));
        std_SL(j,k) = std(z(g==k-1));
    end
    mean_SL_all_positions = [mean_SL_all_positions mean(z)];
    std_SL_all_positions = [std_SL_all_positions std(z)];
    
    all_measurements{end+1} = z;

end

% mean_SL
% std_SL


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
h=subplot(1,2,2);
boxplot(z,g, 'Labels', {'Ulnar Deviation', 'Neutral', 'Radial Deviation'})%, 'Notch','on','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})

% Adjust the boxplot to the left some
pos = get(h, 'Position') ;
posnew = pos; posnew(1) = posnew(1) + 0.04; set(h, 'Position', posnew);

ylabel('Scaphoid-Lunate Gap (mm)')
ylim([0.2 4.7])
title('High Resolution Static MRI (3D T_{1})')
hold on
% line(0:4,mean_VIBE_SL_Gap * ones(1,5),'Color','red','LineStyle','--', 'LineWidth', 2)

mean_SL_all_positions = [mean_SL_all_positions mean(z)]
std_SL_all_positions = [std_SL_all_positions std(z)]
all_measurements{end+1} = z';

axis square
%% TV L1 vs VIBE Mean SL Gap
close all






figure('Color', [1 1 1])

scan_types = {'Gridding 100 Spokes', 'Gridding 40 Spokes', 'SL Gap - FD+DCT 40 Spokes'};
mean_SL = [];
std_SL = [];




for j = 3

    z=[];
    g=[];
    temp= [];
    iter = 0;
    labels = {};
    
    for i = [1,3,5]%length(unique(ndx))
        temp = [ndx; data.four_d_scan_type']';
        temp = data.four_d_gaps(all((temp == [i j])'));
        z = [z; temp]   ;
        
        g = [g; iter*ones(length(temp), 1)];
        iter = iter+ 1;
%         labels{iter} = ['Scan ' num2str(j) ' position ' num2str(i)]
        
    end
    
    boxplot(z,g, 'Labels', {'Ulnar Deviation', 'Neutral','Radial Deviation'})%, 'Notch','on','labels', {'Ulnar Deviation', 'UD - Neutral', 'Neutral', 'N-RD', 'Radial Deviation'})
     

    ylabel('Scaphoid-Lunate Gap (mm)')

    title('Bone Gap vs. Wrist Angle on Active MRI')
    title(scan_types{j})
    ylim([0.2 4.7])
    hold on
    
    


end


% Mean VIBE is 1.64 mm
mean_VIBE_SL_Gap = 1.64;
hold on
line(0:4,mean_VIBE_SL_Gap * ones(1,5),'Color','red','LineStyle','--', 'LineWidth', 2)

axis square
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

