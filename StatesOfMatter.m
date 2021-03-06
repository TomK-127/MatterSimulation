function varargout = StatesOfMatter(varargin)

% Last Modified by GUIDE v2.5 20-Sep-2021 01:11:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StatesOfMatter_OpeningFcn, ...
                   'gui_OutputFcn',  @StatesOfMatter_OutputFcn, ...
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


% --- Executes just before StatesOfMatter is made visible.
function StatesOfMatter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StatesOfMatter (see VARARGIN)

% Choose default command line output for StatesOfMatter
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StatesOfMatter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StatesOfMatter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sl_temperature_Callback(hObject, eventdata, handles)
% hObject    handle to sl_temperature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider



% Get temperature from slider
handles.temperature = get(hObject, 'Value');

%Change temperature if it lies on boiling/melting points
if handles.temperature == handles.boiling_pt
    handles.temperatre = handles.temperature + 1;
end
if handles.temperature == handles.melting_pt
    handles.temperature = handles.temperature + 1;
end


% Display temperature on static text
temp_disp = sprintf('%.f K', handles.temperature);
set(handles.st_temperature, 'String', temp_disp);
set(handles.st_state_of_matter, 'String', ' ');

% Enable simulate button
set(handles.pb_simulate, 'Enable', 'on');

% Calculate properties of material
k_b = 1.38e-23; % Boltzmann constant (J/K)

% Calculate average velocity of gas based on thermal theory of gasses
handles.velocity = sqrt(2 * k_b * handles.temperature / (pi * handles.mass));

velocity_text = sprintf('%.2f', handles.velocity);

%Display average velocity
set(handles.st_velocity, 'Visible', 'on');
set(handles.st_velocity, 'String', velocity_text);




guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sl_temperature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_temperature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





% --- Executes on button press in pb_exit.
function pb_exit_Callback(hObject, eventdata, handles)
% hObject    handle to pb_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.figure1);


% --- Executes on button press in pb_simulate.
function pb_simulate_Callback(hObject, eventdata, handles)
% hObject    handle to pb_simulate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear axes
cla(handles.ax_simulation, 'reset');
axes(handles.ax_simulation);
xlabel('Size (Angstrom)')
ylabel('Size (Angstrom)')

set(handles.ax_simulation, 'ycolor', 'w');
set(handles.ax_simulation, 'xcolor', 'w');

% Disable features while simulation is running
set(handles.pb_simulate, 'Enable', 'off');
set(handles.sl_temperature, 'Enable', 'off');
set(handles.bg_material_selection, 'Visible', 'off');
% set(handles.pb_home, 'Enable', 'off');
set(handles.pb_exit, 'Enable', 'off');
set(handles.st_intro, 'Visible', 'off');

if handles.temperature >= handles.boiling_pt % Run gas simulation
    
    % Turn on descriptions
    set(handles.st_gas, 'Visible', 'on');
    set(handles.st_liquid, 'Visible', 'off');
    set(handles.st_solid, 'Visible', 'off');
    set(handles.st_state_of_matter, 'String', 'GAS'); % Display status
    min_width = 0; %axes dimensions
    min_height = 0; 
    delta_t = .01; %change in time (s)
    index = 0;   %element number
    markersize  = 22;  %Size of atom
    bounds_tol = .5;  % tolerance of boundries
    bounds_toly = .7; % tolerance of boundries in y direction
    width = 14;   % width of viewing window
    height = 14;    % height of viewing window
    collision_tol = .85;   %Minimum distance between atoms for collision (m)
    if handles.gas_scale == 1
        vel_scale =  handles.velocity / 50;  %Scale for setting initial velocity
    else
        vel_scale =  handles.velocity / 100;  %Scale for setting initial velocity
    end
    axis([min_width width min_height height])
    
    for col = [1:1:4]     % Initialize atoms and velocities
        for row = [1:1:4]
            index = index + 1;
            pos(index, 1) = 3 + 3 * (col - 1);
            pos(index, 2) = 3 + 3 * (row - 1);
            
            % Randomize direction(positive or negative)
            if round(rand)
                a = 1;
            else
                a = -1;
            end
            if round(rand)
                b = 1;
            else
                b = -1;
            end
            vel(index, 1) = a * random('norm', vel_scale, vel_scale / 2); % Randomize velocities
            vel(index, 2) = b * random('norm', vel_scale, vel_scale / 2);
        end
    end
    
    num_atoms = row * col;  % Total number of atoms
    next_collision = zeros(num_atoms); % Matrix keeping track of collisions
    
    for t = [1:delta_t:6]
        axes(handles.ax_simulation);
        time_rem = sprintf('%.2f', 6 - t);
        set(handles.st_sim_time, 'String', time_rem);  % Display remaining Simulation time        
        numb_collision = 1;   % collision counter
        collision = [];    %Index of atoms that collided
        pause(.01)    
        cla
        
        for atom_1 = [1:1:(num_atoms - 1)]    % Calculate distance between every atom
            for atom_2 = [(atom_1 + 1):1:num_atoms]
                r_vector_to_atom_1 = pos(atom_1, :) - pos(atom_2, :);  % position vector
                r_mag = norm(r_vector_to_atom_1);   % Displacement between atoms
                if r_mag <= collision_tol   % Simulate collision
                    if (abs(next_collision(atom_1) - t) > delta_t * 80) & (abs(next_collision(atom_2) - t) > delta_t * 80)
                    temp_vel = vel(atom_1, :);
                    next_collision(atom_1) = t;
                    next_collision(atom_2) = t;
                    collision(numb_collision) = atom_1;
                    collision(numb_collision + 1) = atom_2;
                    vel(atom_1, :) = vel(atom_2, :); %Collision is elastic, atoms exchange velocities
                    vel(atom_2, :) = temp_vel;
                    numb_collision = numb_collision + 2;  % 2 atoms collided
                    end
                end
            end
        end
        
        % Find atoms that reached boundries of window
        bounds_x = find(pos(:, 1) >= (width - bounds_tol)  | pos(:, 1) <= bounds_tol);
        bounds_y = find(pos(:, 2) >= (height - bounds_toly) | pos(:, 2) <= bounds_toly);
        
        % Bounce atom off if boundry reached
        if any(bounds_x)
            vel(bounds_x, 1) = -vel(bounds_x, 1);
        end
        if any(bounds_y)
            vel(bounds_y, 2) = -vel(bounds_y, 2);
        end
        
        % Plot position
        hold on
        plot(pos(:, 1) , pos(:, 2), 'o', 'markersize', markersize, 'markerfacecolor', [0 0 0], 'MarkerEdgeColor', [.2 .2 .2]) 
        
        % Plot collsions in a different color
        if ~isempty (collision)
            for i = [1:1:numb_collision - 1]
                hold on
                atom = collision(i);
                plot(pos(atom, 1), pos(atom, 2), 'o', 'markersize', markersize, 'markerfacecolor', 'r')
                %pause(.001)  % Slow down simulation to show collision
            end
        end
        
        % Make sure axis is correct size
        axis([min_width width min_height height])
        pos = pos + vel * delta_t; % Update position
    end
    

elseif handles.temperature >= handles.melting_pt     % Simulate liquid
    
    % Turn on descriptions
    set(handles.st_gas, 'Visible', 'off');
    set(handles.st_liquid, 'Visible', 'on');
    set(handles.st_solid, 'Visible', 'off');
    set(handles.st_state_of_matter, 'String', 'LIQUID'); % Change satatus text
    
    sep_dist = 1;  % Seperation distance between atoms (angstrom)
    index = 0;  % atom index
    delta_t = .01;  % Change in time
    center_tol = .2;  % Tolerance from how far force is calculated from center of 2 atoms
    collision_tol = .1;   % Tolerance for collision (how close atoms have to get to collide) in m
    mass = handles.mass * 1e24;    % Mass of atoms (kg)
    min_width = 0;   % Figure dimensions
    min_height = 0;
    marker_size = 22;   % Size of atom
    k_constant = handles.interatomic_bond;    % constant for calculating force 
    num_atoms = 16;    % Number of atoms in simulation
    width = 12;   % Width of viewing window (angstrom)
    height = 12;   % Height of viewing window (angstrom
    axis([min_width width min_height height])   % Set axis to correctly display atoms
    radius = 4;   % Radius of atom's existence (angstrong)
    center(1) = width / 2;  % center of viewing window x coordinate
    center(2) = height / 2;  % center of viewing window y coordinate
    vel_scale = handles.velocity / handles.liquid_scale;  % Scale of initial velocity of atoms
    wait = 80;  % Time waited before checking for collisions
    
    for row = [1:1:4]  % Initialize atom positions and velocities
        for col = [1:1:4]
            index = index + 1;
            
            % Randomize direction(positive or negative)
            if round(rand)
                a = 1;
            else
                a = -1;
            end
            if round(rand)
                b = 1;
            else
                b = -1;
            end
            
            % Initialize position and velocity of atoms
            pos(index, 1) = 3 + sep_dist * col + a * random('norm', .05 * sep_dist , sep_dist / 100);  % atoms start off at center
            pos(index, 2) = 3 + sep_dist * row + b * random('norm', .05 * sep_dist , sep_dist / 100);
            vel(index, 1) = a * random('norm', vel_scale, vel_scale / 4);
            vel(index, 2) = b * random('norm', vel_scale, vel_scale / 4);
        end
    end
    
    accel = zeros(num_atoms, 2);  % Restart acceleration
    next_collision = zeros(num_atoms);  % Initialize collision counter
    
    t = 1;  % Calculate if any atoms started on top of each other
    for atom_1 = [1:1:(num_atoms - 1)]  % Calculate if collision occurs between any atoms
        for atom_2 = [(atom_1 + 1):1:num_atoms]
            r_vector_to_atom_1 = pos(atom_1, :) - pos(atom_2, :); % position vector
            r_mag = norm(r_vector_to_atom_1);   % Displacement between 2 atoms being compared
            normal_to_pos = r_vector_to_atom_1 / r_mag;
            
            if r_mag <= collision_tol   % Simulate collision
                if (abs(next_collision(atom_1) - t) > delta_t * wait) & (abs(next_collision(atom_2) - t) > delta_t * wait)
                    temp_vel = vel(atom_1, :);   % elastic collsion, atoms exchange velocities
                    next_collision(atom_1) = t;
                    next_collision(atom_2) = t;
                end
            end
        end
    end
    
    
    
    for t = [0:delta_t:5]
        time_rem = sprintf('%.2f', 5 - t); % Calculate time remaining
        set(handles.st_sim_time, 'String', time_rem);  % Display Simulation time
        pause(.001)
        cla
        
        force = zeros(num_atoms, 2);  % Restart force acting on atoms
        
        for atom_1 = [1:1:(num_atoms - 1)]  % Calculate forces between atoms
            for atom_2 = [(atom_1 + 1):1:num_atoms]
                r_vector_to_atom_1 = pos(atom_1, :) - pos(atom_2, :); % position vector
                r_mag = norm(r_vector_to_atom_1);   % Displacement between 2 atoms being compared
                normal_to_pos = r_vector_to_atom_1 / r_mag;
                if r_mag > center_tol % Avoid calculating force when atoms are too close
                    if r_mag - sep_dist < 0   % Reverse the direction of force if atoms are fairly close
                        normal_to_pos = -normal_to_pos;
                    end
                    force(atom_1, :) = force(atom_1, :) - k_constant / r_mag ^ 2 * normal_to_pos;
                    force(atom_2, :) = force(atom_2, :) + k_constant / r_mag ^ 2 * normal_to_pos;
                end
                
                if r_mag <= collision_tol   % Simulate collision
                    if (abs(next_collision(atom_1) - t) > delta_t * 5) & (abs(next_collision(atom_2) - t) > delta_t * 5)
                        temp_vel = vel(atom_1, :);   % elastic collsion, atoms exchange velocities
                        next_collision(atom_1) = t;
                        next_collision(atom_2) = t;
                        vel(atom_1, :) = vel(atom_2, :);
                        vel(atom_2, :) = temp_vel;
                    end
                end
            end
        end
        
        %Make sure no atom strays too far away from center of mas
        for atom = [1:1:num_atoms]
            r_vector_to_atom = pos(atom, :) - center;  % position vector to atom
            r_mag = norm(r_vector_to_atom);   % Displacement to atom
            
            if r_mag >= radius * 1.2  % atom is further away than 1.2 * radius from center
                normal_to_pos = r_vector_to_atom / r_mag; % Normal vector to atom position
                vel_mag = norm(vel(atom, :));
                vel(atom, :) = -.50 * normal_to_pos .* vel_mag;  % Change atom velocity so that it travels towards center
            end
        end
        
        hold on;
        accel = force / mass; % force = mass * acceleration
        
        plot(pos(:, 1) , pos(:, 2), 'o', 'markersize', marker_size, 'markerfacecolor', [0 0 0], 'MarkerEdgeColor', [.2 .2 .2])  % plot atoms
        axis([min_width width min_height height])
        
        % Update position and velocity
        vel = vel + accel * delta_t;
        pos = pos + vel * delta_t;
        
       %Adjust center of mass as liquid moves
       center(1) = sum(pos(: , 1)) / num_atoms; % Calculate new center of mass
       center(2) = sum(pos(: , 2)) / num_atoms; % y coordinates

        if (min_width > (min(pos(: , 1)) - .5)) | (width < max(pos(: , 1)) + .5) | (min_height > (min(pos(: , 2)) - .5)) | (height < max(pos(: , 2)) + .5)
           min_width = center(1) - radius * 1.5;  % Adjust viewing window
           width = center(1) + radius * 1.5;
           min_height = center(2) - radius * 1.5;
           height = center(2) + radius * 1.5;
           axis([min_width width min_height height])
        end    
    end
    
else %Simulate solid
    
    % Turn on descriptions
    set(handles.st_gas, 'Visible', 'off');
    set(handles.st_liquid, 'Visible', 'off');
    set(handles.st_solid, 'Visible', 'on');
        
    % Calculates colormap for plotting
    num_colors = 200;
    cmap = colormap(cool(num_colors));
    
    % Simulate Solid
    set(handles.st_state_of_matter, 'String', 'SOLID');
   
    index = 0;  % Index of atom
    mass = handles.mass * 1e24;  % Mass of atom (kg)
    k = handles.k / 2;    % Atomic spring constant (N/m)
    sep_dist = 1; % Seperation distance between atoms (angstrom)  
    sep_scale = .3; % Scale for the random offset of atoms from center locations 
    height = 5; % Height of viewing window
    vel_scale = handles.velocity / 250;
    width = 5; % Width of viewing window
    delta_t = .01; % Change in time
    min_height = 0;
    min_width = 0;
    axis([min_height height min_width width])
    
    % Calculate bond color scale
    for col = [1:sep_dist:4]  % Initialize atom positions and velocities
        for row = [1:sep_dist:4]
            index = index + 1;
            
            % Randomize direction(positive or negative)
            if round(rand)
                a = 1;
            else
                a = -1;
            end
            if round(rand)
                b = 1;
            else
                b = -1;
            end
            
            center_pos(index, 1) = row; % Center positions of atoms
            center_pos(index, 2) = col;
            pos(index, 1) = row; % atoms start off at center
            pos(index, 2) = col; 
            vel(index, 1) = a * random('norm', vel_scale, vel_scale / 4);
            vel(index, 2) = b * random('norm', vel_scale, vel_scale / 4);
        end
    end
    num_atoms = row * col; % Number of atoms
    accel = zeros(num_atoms, 2);  %X and y coordinates of acceleration of each atom (m / s ^ 2) 
    hold on
    
    % Ensure center of mass doesn't move for viewing purposes
    center_mass(1) = sum(pos(: , 1)) / num_atoms;
    center_mass(2) = sum(pos(: , 2)) / num_atoms;
    
    for t = [0:delta_t:2]
        % Display remaining time
        time_rem = sprintf('%.2f', 5 - 2.5 * t); % Time is scaled because solid simulation runs slower
        set(handles.st_sim_time, 'String', time_rem);  % Display Simulation time
        
        pause(.01)
        cla
        force = zeros(num_atoms, 2);  % Force is zero at the start of each iteration
        
        for atom_1 = [1:1:(num_atoms - 1)] % Calculate every interaction between atoms
            for atom_2 = [(atom_1 + 1):1:num_atoms]
                r_vector_to_atom_1 = pos(atom_1, :) - pos(atom_2, :); % position vector
   
                % Calculate forces
                r_mag = norm(r_vector_to_atom_1);  % Displacement between 2 atoms
                relax_length = norm(center_pos(atom_1, :) - center_pos(atom_2, :)); % Normal displacement when no interaction is happening
                force_r = relax_length - r_mag;   % Interatomic spring stretch / compression
                normal_to_pos = r_vector_to_atom_1 / r_mag; % Normal vector to position
                
                % Calculate forces
                force(atom_1, :) = force(atom_1, :) + (k  * force_r * normal_to_pos);  % F = k * x
                force(atom_2, :) = force(atom_2, :) - force(atom_1, :);   % Force reciprocity
            end
        end
        
        hold on;
        num_row = 1; % Index of the current row
        
        % plot bonds between atoms
        for atom = [1:1:(num_atoms - 1)] % Plots bond to upper and to the right atom of every atom
            for next_atom = [1:1:2]
                if next_atom == 1 % Atom to the right
                    if (atom + next_atom <= num_atoms) && (atom ~= row * num_row) % Makes sure atom is not on edge
                        bond = pos(atom, :) - pos(atom + 1, :);
                        bond_length = norm(bond);
                        bond = [pos(atom, :); pos(atom, :) - bond]; % bond in x y coordinates
                        force_scale = (abs(bond_length - sep_dist)) * k;
                        bond_color = 1 + round(force_scale / relax_length * num_colors * .75); % get color from size of force of bond
                        if bond_color > num_colors  % make sure bond color exists
                            bond_color = num_colors;
                        end
                        plot(bond(:, 1), bond(:, 2), 'LineWidth', 4, 'color', cmap(bond_color, :))  % Plots bond
                        
                    else
                        num_row = num_row + 1; % Move to next row
                    end
                    
                else  % Atom above
                    if (atom + col <= num_atoms)  % col is number of elements per row - skips to element 1 row above
                        bond = pos(atom, :) - pos(atom + col, :);
                        bond_length = norm(bond);
                        bond = [pos(atom, :); pos(atom, :) - bond];
                        force_scale = (abs(bond_length - sep_dist)) * k;
                        bond_color = 1 + round(force_scale / relax_length * num_colors * .75); % get color from size of force of bond
                        if bond_color > num_colors  % make sure bond color exists
                            bond_color = num_colors;
                        end
                        plot(bond(:, 1), bond(:, 2), 'LineWidth', 4, 'color', cmap(bond_color, :))  % Plots bond
                       
                    end
                end
            end
        end
    
        accel = force / mass;  % Force = mass * acceleration converted to angsstroms
        plot(pos(:, 1) , pos(:, 2), 'o', 'markersize', 20, 'markerfacecolor', [0 0 0], 'MarkerEdgeColor', [.2 .2 .2])  % Plot position       
        
        if (min_width > (min(pos(: , 1)) - .3)) | (width < max(pos(: , 1)) + .3) | (min_height > (min(pos(: , 2)) - .3)) | (height < max(pos(: , 2)) + .3)
            axis([(min(pos(: , 1)) - 1), (max(pos(: , 1)) + 1), (min(pos(: , 2)) - 1), (max(pos(: , 1)) + 1)])
            min_width = min(pos(: , 1)) - 1;  % Adjust window to ensure simulation is in the middle
            width = max(pos(: , 1)) + 1;
            min_height = min(pos(: , 2)) - 1;
            height = max(pos(: , 2)) + 2;
        end
        
        % Update position and velocity
        vel = vel + accel * delta_t;
        pos = pos + vel * delta_t;
        
        % Ensure center of mass doesn't move
        new_center_mass(1) = sum(pos(: , 1)) / num_atoms; % Calculate new center of mass
        new_center_mass(2) = sum(pos(: , 2)) / num_atoms; % y coordinates
        offset = center_mass - new_center_mass;  % Calculate the offset from the original center of mass
        pos(:, 1) = pos(:, 1) + offset(1);  % Update position
        pos(:, 2) = pos(:, 2) + offset(2); 
    end
end

% Enable features when simulation is done
set(handles.pb_simulate, 'Enable', 'on');
set(handles.sl_temperature, 'Enable', 'on');
set(handles.bg_material_selection, 'Visible', 'on');
% set(handles.pb_home, 'Enable', 'on');
set(handles.pb_exit, 'Enable', 'on');

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ax_atom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax_atom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

image = imread('legend.jpg');
imshow(image);

% Hint: place code in OpeningFcn to populate ax_atom
guidata(hObject, handles);


% --- Executes when selected object is changed in bg_material_selection.
function bg_material_selection_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bg_material_selection 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

k_constant = 1.29e-9;

% Restart Temperature display
set(handles.st_temperature, 'String', ' ');
set(handles.st_state_of_matter, 'String', ' ');

% Reset Average Velocity display
set(handles.st_velocity, 'Visible', 'off');

% Reset Slider
set(handles.sl_temperature, 'Value', 0);

% Enable slider
set(handles.sl_temperature, 'Enable', 'on');

% Disable Simulation button
set(handles.pb_simulate, 'Enable', 'off');

% Determine material
handles.material = get(eventdata.NewValue, 'tag');

% Restarts limit for slider bar
set(handles.sl_temperature, 'Max', 100);

% Sets properties of material based on user selection
% Note: for beta version, only boiling/melting points are used / are
% accurate
switch handles.material
    case 'rb_hydrogen'  % Selected material is hydrogen
        handles.melting_pt = 13.9;  % Melting point (k)
        handles.boiling_pt = 20;   % Boiling point (k)
        handles.mass = 3.332e-27;          % mass of atom (kg)
        handles.interatomic_bond = .05;   % Strength of interatomic bond (N)
        handles.k = .1;           % Spring constant (N / m)
        handles.liquid_scale = 100;
        handles.gas_scale = 0;
        
        
        % Sets appropriate scale for temperature slider bar
        set(handles.sl_temperature, 'Max', 800);
        
    case 'rb_gold'  % Selected material is gold
        handles.melting_pt = 1337;  % Melting point (k)
        handles.boiling_pt = 3243;  % Boiling point (k)
        handles.mass = 3.28e-25;            % mass of atom (kg)
        handles.interatomic_bond = 3;   % Strength of interatomic bond (N)
        handles.k = 10;          % Spring constant (N / m)
        handles.liquid_scale = 200;
        handles.gas_scale = 1;
        
        
        % Sets appropriate scale for temperature slider bar
        set(handles.sl_temperature, 'Max', 3500);
        
%     case 'rb_carbon'  % Selected material is carbon
%         handles.melting_pt = 3823;  % Melting point (k)
%         handles.boiling_pt = 4098;  %  Boiling point (k)
%         handles.mass = 1.999e-26;             % mass of atom (kg)
%         handles.interatomic_bond = 1;   % Strength of interatomic bond (N)
%         handles.k = 40;          % Spring constant (N / m)

        % Sets appropriate scale for temperature slider bar
        %set(handles.sl_temperature, 'Max', 4400);
    case 'rb_iron'
        handles.melting_pt = 1811;  % Melting point (k)
        handles.boiling_pt = 3135;  %  Boiling point (k)
        handles.mass = 1.999e-26;             % mass of atom (kg)
        handles.interatomic_bond = 1;   % Strength of interatomic bond (N)
        handles.k = 15;          % Spring constant (N / m)
        handles.liquid_scale = 1000;
        handles.gas_scale = 0;
        
        % Sets appropriate scale for temperature slider bar
        set(handles.sl_temperature, 'Max', 3800);
        
end




  
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function ax_simulation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax_simulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate ax_simulation

% Hint: place code in OpeningFcn to populate ax_table


% --- Executes on button press in pb_table.
function pb_table_Callback(hObject, eventdata, handles)
% hObject    handle to pb_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function pb_table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pb_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

image = imread('table.jpg');
set(hObject, 'CData', image);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% Get temperature from slider
handles.temperature = str2num(get(hObject, 'string'));

% Display temperature on static text
temp_disp = sprintf('%.f K', handles.temperature);
set(handles.st_temperature, 'String', temp_disp);

% Enable simulate button
set(handles.pb_simulate, 'Enable', 'on');

% Calculate properties of material
k_b = 1.38e-23; % Boltzmann constant (J/K)

% Calculate average velocity of gas based on thermal theory of gasses
handles.velocity = sqrt(2 * k_b * handles.temperature / (pi * handles.mass));

velocity_text = sprintf('%.2f', handles.velocity);

%Display average velocity
set(handles.st_velocity, 'Visible', 'on');
set(handles.st_velocity, 'String', velocity_text);

guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function p_legend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_legend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pb_legend.
function pb_legend_Callback(hObject, eventdata, handles)
% hObject    handle to pb_legend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function pb_legend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pb_legend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

image = imread('legend.jpg');
set(hObject, 'CData', image);


% --- Executes on button press in pb_colorbar.
function pb_colorbar_Callback(hObject, eventdata, handles)
% hObject    handle to pb_colorbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function pb_colorbar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pb_colorbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
image = imread('colorbar_tom.jpg');
set(hObject, 'CData', image);


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
