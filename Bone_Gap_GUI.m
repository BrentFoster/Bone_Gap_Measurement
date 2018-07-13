function varargout = Bone_Gap_GUI(varargin)
% BONE_GAP_GUI MATLAB code for Bone_Gap_GUI.fig
%      BONE_GAP_GUI, by itself, creates a new BONE_GAP_GUI or raises the existing
%      singleton*.
%
%      H = BONE_GAP_GUI returns the handle to a new BONE_GAP_GUI or the handle to
%      the existing singleton*.
%
%      BONE_GAP_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BONE_GAP_GUI.M with the given input arguments.
%
%      BONE_GAP_GUI('Property','Value',...) creates a new BONE_GAP_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Bone_Gap_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Bone_Gap_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Bone_Gap_GUI

% Last Modified by GUIDE v2.5 12-Jul-2018 17:55:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Bone_Gap_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Bone_Gap_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Bone_Gap_GUI is made visible.
function Bone_Gap_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Bone_Gap_GUI (see VARARGIN)

% Choose default command line output for Bone_Gap_GUI
handles.output = hObject;

% We are adding analyze read/write files in the following folder.
addpath('NIfTI_20140122')

% Initilize some variables
handles.colormap = 'gray';
handles.zoom_offset = 5;
handles.threshold = 0.5;
handles.curr_time_slice = 1;
handles.x = [];
handles.y = [];
handles.gap_measurement = 0;
handles.Output = {};
handles.upsample = 1;
handles.measure_num = 1;

% Select a folder of images to measure
directoryname = uigetdir('Select a folder of images to measure');
% directoryname = 'D:\Google Drive\Research\MRI Wrist Images\Active MRI\Analyze\Volunteer 3 Right\VIBE\'
% directoryname = 'D:\Google Drive\Research\MRI Wrist Images\Active MRI\Analyze\Volunteer 3 Right\Radial Ulnar FLASH 100\';
% directoryname = 'D:\Google Drive\Research\Projects\Shape Analysis PCA\Matlab Surface Registration\VIBE_Labels_Neutral\'
% Get the names of the files in the selected folder
listing = dir(directoryname);

str_array = {};

% Load all of the images 
f = waitbar(0,'Loading the images...');
iter = 1;
for i = 3:length(listing) 
    try
        handles.images(iter) = load_nii([directoryname '\' listing(i).name]);   
        
        if (length(size(handles.images(iter).img)) == 3)
            % Rotate the image (since load_nii always rotates it 90 degrees)
            temp_img = [];
            for z = 1:size(handles.images(iter).img,3)
                temp_img(:,:,z) = imrotate(handles.images(iter).img(:,:,z), -90);    
            end  
            handles.images(iter).img = temp_img;        
        end
        
        % Save the file name of the loaded image in a cell array
        str_array{iter} = listing(i).name; 
        
        iter = iter + 1;
    catch
        disp(["Failed to load image " listing(i).name])    
    end
    
   waitbar(i/length(listing),f, 'Loading the images...');
end
close(f)


% Put the names of the files to the filename list box
set(handles.Filename_Listbox,'String',str_array);


% Show the first image
handles.image_index = 1;

% Choose a slice to show (based on whether it is a 3D or 4D image)
if (length(size(handles.images(handles.image_index).img)) == 3)
    handles.curr_slice = round(size(handles.images(handles.image_index).img,3)/2);
else
    handles.curr_slice = 1;
end

Show_Image(handles);

% Initilize the threshold slider
set(handles.threshold_slider, 'Min', 0);
set(handles.threshold_slider, 'Max', 1);
set(handles.threshold_slider, 'Value', handles.threshold);
set(handles.threshold_label, 'String', num2str(handles.threshold))
%set(handles.threshold_label, 'SliderStep', [0.01 0.1]);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Bone_Gap_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
 

% --- Outputs from this function are returned to the command line.
function varargout = Bone_Gap_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Filename_Listbox.
function Filename_Listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Filename_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Filename_Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Filename_Listbox

% Show the selected image
handles.image_index = hObject.Value;

% Reset the currently selected slice (since this is a new image)
% Choose a slice to show (based on whether it is a 3D or 4D image)
if (length(size(handles.images(handles.image_index).img)) == 3)
    handles.curr_slice = round(size(handles.images(handles.image_index).img,3)/2);
else
    handles.curr_slice = 1;
end


% Display the currently selected slice and the newly selected image
Show_Image(handles)


% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Filename_Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filename_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in export_button.
function export_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Export the output array to a CSV file
filename = 'Output_Measures.xlsx'

writetable(struct2table(handles.Output),filename);
winopen 'Output_Measures.xlsx'


% cell2csv(fileName, handles.Output, separator)
% 

% --- Executes on slider movement.
function time_slider_Callback(hObject, eventdata, handles)
% hObject    handle to time_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider



% Update the current time select to whatever the slider value is
handles.curr_time_slice = round(get(hObject,'Value')); 

% Update the time select label
set(handles.time_label, 'String', num2str(handles.curr_time_slice))


% Display the currently selected slice and the newly selected image
Show_Image(handles)


% Update handles structure
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function time_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function threshold_label_CreateFcn(hObject, eventdata, handles)


% --- Executes on slider movement.
function slice_slider_Callback(hObject, eventdata, handles)
% hObject    handle to slice_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Update the current slice to whatever the slider value is
handles.curr_slice = round(get(hObject,'Value')); % Round to give an integer

% Display the currently selected slice
Show_Image(handles)

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slice_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slice_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function threshold_slider_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Update the current threshold to whatever the slider value is
handles.threshold = round(get(hObject,'Value'), 2); 

% Update the threshold label
set(handles.threshold_label, 'String', num2str(handles.threshold))

% Redo the measurement and plot
[handles.x,handles.y] = Get_Measurements(handles, handles.x, handles.y); 


% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function threshold_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



    which_button = eventdata.Key;

    switch which_button
        case 'space'
            % This is the measuring button and run the call back now
            [handles.x,handles.y, handles.gap_measurement] = Get_Measurements(handles, [], []);        
    end

    
    % Update handles structure
    guidata(hObject, handles);

function [x,y, gap_measurement] = Get_Measurements(handles,x,y)

    % If there is no x or y supplied ask the user to input some
    if (isempty(x) || isempty(y))
        % Get the measurement from the image
        [x,y] = Get_Input_Line(handles)
    end
    
    % Zoom in the top left image (i.e. axes 2) to be around the measurement
    Show_Zoom_Image(handles, x, y);
    
    % Plot the intensities in axes 3
    Plot_Intensities(handles, x, y);
    
    % Segment the gap based on some percentage of the maximum intensitity
    gap_measurement = Segment_Bone_Gap(handles, x, y)
    

    

function gap_measurement = Segment_Bone_Gap(handles, x, y)
 % Fit a line to the points selected
    fitvars = polyfit(x, y, 1);
    m = fitvars(1);
    b = fitvars(2);
        
    % Sample points on the line
    x_sample = round(x(1):x(2))
    y_sample = round(m*x_sample + b);
           
%     % Is the image a 3D or 4D image?
%     if (length(size(handles.images(handles.image_index).img)) == 3)
%         % Get the image    
%         temp_image = handles.images(handles.image_index).img(:,:,handles.curr_slice);      
%     else
%         % The image is a 4D image
%         % Get the image    
%         temp_image = handles.images(handles.image_index).img(:,handles.curr_time_slice,:,handles.curr_slice);       
%         temp_image = ipermute(temp_image, [1 3 2]);    
%     end
    
    temp_image = getimage(handles.axes1);

    % Get the intensities on the measurement line
    img_intensities = [];
    for i = 1:length(x_sample)
        img_intensities(i) = temp_image(y_sample(i), x_sample(i));
    end
    
    maximum_intensity = max(img_intensities);
    
    % Find the first value which is at least the threshold or greater
    ndx_start = [];
    ndx_end = [];
    
    for i = 1:length(img_intensities)
        if (img_intensities(i) >= handles.threshold * maximum_intensity)
            ndx_start = i; % Save the index of this value            
            break
        end
    end
    
    % Start at the end and go the other direction
    for i = 1:length(img_intensities)
        if (img_intensities(length(img_intensities) - i) >= handles.threshold * maximum_intensity)
            ndx_end = length(img_intensities) - i; % Save the index of this value            
            break
        end
    end
    
    % Plot the gap in a different color on axes 2
    axes(handles.axes2)
    hold on      
    plot(x_sample(ndx_start:ndx_end), y_sample(ndx_start:ndx_end), 'r*-')
    
    % Measure this in terms of millimeters (by using the image pixel size)
    % Piece wise
    gap_measurement = length(ndx_start:ndx_end) *  handles.images(handles.image_index).hdr.dime.pixdim(2);
    
    % Use a direct line
    sqrt((x_sample(ndx_start) - x_sample(ndx_end))^2 + (y_sample(ndx_start) - y_sample(ndx_end))^2)
    
    
    % If the image is upsample apply the correction here
    gap_measurement = gap_measurement * 1/handles.upsample;
    
    
    % Set the GUI label to show this number
    set(handles.measurementLabel, 'String', num2str(gap_measurement))
    
    
    
function Plot_Intensities(handles, x, y)
    % After making a measurement line plot the intensities in axes 3
        
    % Fit a line to the points selected
    fitvars = polyfit(x, y, 1);
    m = fitvars(1);
    b = fitvars(2);
        

    % Sample points on the line
    x_sample = round(x(1):x(2))
    y_sample = round(m*x_sample + b);
    
%     % Is the image a 3D or 4D image?
%     if (length(size(handles.images(handles.image_index).img)) == 3)
%         % Get the image    
%         temp_image = handles.images(handles.image_index).img(:,:,handles.curr_slice);      
%     else
%         % The image is a 4D image
%         % Get the image    
%         temp_image = handles.images(handles.image_index).img(:,handles.curr_time_slice,:,handles.curr_slice);       
%         temp_image = ipermute(temp_image, [1 3 2]);    
%     end
%     

    temp_image = getimage(handles.axes1);


     % Get the intensities on the measurement line
    img_intensities = [];
    for i = 1:length(x_sample)
        img_intensities(i) = temp_image(y_sample(i), x_sample(i));
    end

    % Pad img_intensities with zeros so it aligns with the image in axes 2
    img_intensities = [zeros(1,handles.zoom_offset) img_intensities zeros(1,handles.zoom_offset) ]
    % Plot the line in axes 1
    axes(handles.axes1)
    hold on      
    plot(x_sample, y_sample, 'b--')
    
    
    % Plot the line in axes 2
    axes(handles.axes2)
    hold on      
    plot(x_sample, y_sample, 'b--')
    
    
    % Plot the intensities in axes 3
    axes(handles.axes3)
    cla(handles.axes3)
    plot(img_intensities, 'b--')

    
function [x,y] = Get_Input_Line(handles)
    % Get two mouse clicks on the image to get the line between them
    % Take the measurement on the large image in axes 1
    % Left click then right click
    
    [x,y] = getline(handles.axes1);
    

function Show_Zoom_Image(handles, x, y)
    % After making a measurement line show a zoomed in version in the top
    % left figure (i.e. axes 2)

    % First need to sort x and y to be in order
    x = sort(x);
    y = sort(y);

%     
%     % Is the image a 3D or 4D image?
%     if (length(size(handles.images(handles.image_index).img)) == 3)
%         % Get the image    
%         temp_image = handles.images(handles.image_index).img(:,:,handles.curr_slice);      
%     else
%         % The image is a 4D image
%         % Get the image    
%         temp_image = handles.images(handles.image_index).img(:,handles.curr_time_slice,:,handles.curr_slice);       
%         temp_image = ipermute(temp_image, [1 3 2]);    
%     end

    temp_image = getimage(handles.axes1);
    
    % Crop this image based on the measurement line
    x_ndx = round(x(1) - handles.zoom_offset: x(2) + handles.zoom_offset);
    y_ndx = round(y(1) - handles.zoom_offset: y(2) + handles.zoom_offset);


    % Display the image
    axes(handles.axes2)
    cla(handles.axes2)
    imagesc(temp_image)
    colormap(handles.colormap)

    
    % Zoom in around the line selected
    xlim([x_ndx(1) x_ndx(end)])
    ylim([y_ndx(1) y_ndx(end)])

    %Remove the 'ticks' from the axes
    set(handles.axes2,'xtick',[],'ytick',[])
    
    axis square

function Show_Image(handles)
    % Show the image given an image index and a slice number
    
    % Reset the GUI plots and the measurement label
    cla(handles.axes1)
    cla(handles.axes2)
    cla(handles.axes3)
    set(handles.measurementLabel, 'String', num2str(0))    
    
    % Get the image
    temp_image = handles.images(handles.image_index).img;

    % Display the image
    axes(handles.axes1)
    cla(handles.axes1)
    colormap(handles.colormap)    
    
    
    % Is this a 3D or 4D image?    
    if (length(size(handles.images(handles.image_index).img)) == 3)
        
        % Is the upsample image checked or not?   
        if (get(handles.upsample_image_checkmark, 'Value') == true)
            handles.upsample = str2num(get(handles.upsample_image_edit,'String'));            
            temp_image_slice = imresize(temp_image(:,:,handles.curr_slice), handles.upsample);
            imagesc(temp_image_slice)
        else       
            imagesc(temp_image(:,:,handles.curr_slice))
        end        

        % Set the slider values based on the shown image 
        set(handles.slice_slider, 'Min', 1);
        set(handles.slice_slider, 'Max', size(temp_image,3));

        xlim([0 size(temp_image(:,:,handles.curr_slice),1)])
        ylim([0 size(temp_image(:,:,handles.curr_slice),2)])
    else
       
        temp_img = temp_image(:,handles.curr_slice,:,handles.curr_time_slice);        
        temp_img = ipermute(temp_img, [1 3 2]);
        
        % Rotate the image 90 degrees now
        temp_img = imrotate(temp_img, 90);
        
        
        % Is the upsample image checked or not?   
        if (get(handles.upsample_image_checkmark, 'Value') == true)
            handles.upsample = str2num(get(handles.upsample_image_edit,'String'));
            temp_img = imresize(temp_img, handles.upsample);
            imagesc(temp_img)
        else       
            imagesc(temp_img)
        end            
        
        % Set the slider values based on the shown image 
        set(handles.slice_slider, 'Min', 1);
        set(handles.slice_slider, 'Max', 6);

    end
    

    set(handles.slice_slider, 'Value', handles.curr_slice);
    set(handles.slice_label, 'String', num2str(handles.curr_slice))
    
    axis tight
    
    % Fix the slider steps here
    maxSliderValue = get(handles.slice_slider, 'Max');
    minSliderValue = get(handles.slice_slider, 'Min');
    theRange = maxSliderValue - minSliderValue;
    steps = [1/theRange, 10/theRange];
    set(handles.slice_slider, 'SliderStep', steps);

    maxSliderValue = get(handles.time_slider, 'Max');
    minSliderValue = get(handles.time_slider, 'Min');
    theRange = maxSliderValue - minSliderValue;
    steps = [1/theRange, 10/theRange];
    set(handles.time_slider, 'SliderStep', steps);

    % Remove the 'ticks' from the axes
    set(handles.axes1,'xtick',[],'ytick',[])
    enableWL
    set(handles.axes2,'xtick',[],'ytick',[])
    set(handles.axes3,'xtick',[],'ytick',[])

    


% --- Executes on button press in record_measurement.
function record_measurement_Callback(hObject, eventdata, handles)
% hObject    handle to record_measurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Record the current bone gap measure
    handles.Output(handles.measure_num).gap_measurement = handles.gap_measurement;
    handles.Output(handles.measure_num).filename   = handles.images(handles.image_index).fileprefix;
    handles.Output(handles.measure_num).slice  = handles.curr_slice;
    handles.Output(handles.measure_num).time   = handles.curr_time_slice;
    handles.Output(handles.measure_num).pix_dim   = handles.images(handles.image_index).hdr.dime.pixdim(2:4);
    handles.Output(handles.measure_num).upsample = handles.upsample;

    % Add one to the measurement number index
    handles.measure_num = handles.measure_num + 1;
    
    % Update handles structure
    guidata(hObject, handles);

function upsample_image_edit_Callback(hObject, eventdata, handles)
% hObject    handle to upsample_image_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of upsample_image_edit as text
%        str2double(get(hObject,'String')) returns contents of upsample_image_edit as a double


handles.upsample = str2num(get(handles.upsample_image_edit,'String'));

% Update the image shown
Show_Image(handles)

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function upsample_image_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upsample_image_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in upsample_image_checkmark.
function upsample_image_checkmark_Callback(hObject, eventdata, handles)
% hObject    handle to upsample_image_checkmark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of upsample_image_checkmark

% Update the image shown
Show_Image(handles)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in next_image_button.
function next_image_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_image_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Simply go to the next image
handles.image_index = handles.image_index + 1;

set(handles.Filename_Listbox, 'Value', handles.image_index);


% Choose a slice to show (based on whether it is a 3D or 4D image)
if (length(size(handles.images(handles.image_index).img)) == 3)
    handles.curr_slice = round(size(handles.images(handles.image_index).img,3)/2);
else
    handles.curr_slice = 1;
end

% Update the image being shown
Show_Image(handles);

% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
