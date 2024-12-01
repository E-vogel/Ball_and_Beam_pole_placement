function ball_and_beam_pole()

% Close all existing figures
close all

% Create a figure and set up callback functions for mouse and keyboard interactions
fig = figure('Position',[300 200 730 300], ...
    'WindowButtonDownFcn', @myBDCallback, ...
    'WindowButtonUpFcn', @myBUCallback);
fig.KeyPressFcn = @simulatior_break;
state = 0; % Interaction state variable
fin = 0;   % Simulation end flag

% Physical constants
g = -9.81;  % Gravitational acceleration [m/s^2]
M = 1;     % Mass of the beam [kg]
L = 2;     % Length of the beam [m]

% Beam moment of inertia
I = M * L^2 / 12;

% State-space representation matrices
A = [0 1 0 0;
     0 0 -g 0;
     0 0 0 1;
     0 0 0 0];

B = [0; 0; 0; 1/I];

C = [1 0 0 0;
     0 1 0 0];

% Initial pole locations
p = [-4+1j -3+2j -4-1j -3-2j];

% Main simulation loop
while fin == 0

    % Initial conditions
    x0 = -0.4;       % Initial position of the ball
    dx0 = 0;         % Initial velocity of the ball
    theta0 = -pi/10; % Initial angle of the beam
    dtheta0 = 0;     % Initial angular velocity of the beam

    % State vector initialization
    X = [x0; dx0; theta0; dtheta0];

    % Initialize trajectory storage
    X_str = zeros(4, 1);
    X_str(:, 1) = X;

    % Calculate feedback gain using pole placement
    K = place(A, B, p);

    % Time parameters
    i = 1;
    h = 0.01; % Time step

    % Simulation loop until the system stabilizes or exceeds limits
    while abs(X(1)) > 1e-3 || abs(X(2)) > 1e-3
        % Compute control torque
        tau = -K * X;

        % Update state using Euler integration
        dX = A * X + B * tau;
        X = X + dX * h;

        % Limit ball position to within beam length
        if abs(X(1)) > L / 2
            X(1) = L / 2 * sign(X(1));
        end

        % Limit beam angle to within ±π/2
        if abs(X(3)) > pi / 2
            X(3) = pi / 2 * sign(X(3));
        end

        % Increment time step and store state
        i = i + 1;
        X_str(:, i) = X;

        % Break simulation if too many iterations
        if i > 2000
            break
        end
    end

    % Visualization setup
    tiledlayout(1, 2)

    % Beam and ball visualization
    nexttile
    beam_left = [-L / 2 * cos(theta0), -L / 2 * sin(theta0)];
    beam_right = [L / 2 * cos(theta0), L / 2 * sin(theta0)];
    beam = plot([beam_left(1) beam_right(1)], [beam_left(2) beam_right(2)], 'LineWidth', 5, 'Color', 'k');
    hold on
    joint = scatter(0, 0, 'white', 'filled', 'SizeData', 10); % Joint at the center
    ball = scatter(x0 * cos(theta0), x0 * sin(theta0), 'red', 'filled', 'SizeData', 100); % Ball on the beam
    timetext = text(0.5, 1, '$t =$', 'FontSize', 12, 'Interpreter', 'latex');
    time = text(0.8, 1, '0', 'FontSize', 12, 'Interpreter', 'latex');
    hold off
    ax = gca;
    ax.TickLabelInterpreter = 'latex';
    axis([-L / 2 L / 2 -L / 2 L / 2] * 1.2);
    daspect([1 1 1]);

    % Pole placement visualization
    nexttile
    Rep = real(p);
    Imp = imag(p);
    pole = scatter(Rep, Imp, "o", "filled"); % Pole locations
    hold on
    fill([-5 0 0 -5], [-5 -5 5 5], 'r', 'FaceAlpha', 0.1); % Damping region
    ax = gca;
    ax.XAxisLocation = "origin";
    ax.YAxisLocation = "origin";
    ax.TickLabelInterpreter = 'latex';
    grid on
    xlabel("Re", 'Interpreter', 'latex')
    ylabel("Im", 'Interpreter', 'latex')
    title("Pole placement", 'Interpreter', 'latex', 'FontSize', 12)
    axis([-5 5 -5 5]);
    xticks(-5:5)
    yticks(-5:5)
    box on
    daspect([1 1 1])

    % Animation of ball and beam motion
    for ii = 2:i
        beam_left = [-L / 2 * cos(X_str(3, ii)), -L / 2 * sin(X_str(3, ii))];
        beam_right = [L / 2 * cos(X_str(3, ii)), L / 2 * sin(X_str(3, ii))];

        beam.XData = [beam_left(1) beam_right(1)];
        beam.YData = [beam_left(2) beam_right(2)];

        ball.XData = X_str(1, ii) * cos(X_str(3, ii)) + 0.1 * cos(pi / 2 + X_str(3, ii));
        ball.YData = X_str(1, ii) * sin(X_str(3, ii)) + 0.1 * sin(pi / 2 + X_str(3, ii));

        time.String = (ii - 1) * h;
        drawnow
    end

end

% Callback function for mouse button down
function myBDCallback(src, ~)
    set(src, 'WindowButtonMotionFcn', @myBMCallback);

    % Callback function for mouse motion
    function myBMCallback(~, ~)
        Cp = get(gca, 'CurrentPoint'); % Get current mouse position
        for k = 1:length(p)
            if Cp(1, 1) < Rep(k) + 0.2 && Cp(1, 1) > Rep(k) - 0.2 && ...
               Cp(1, 2) < Imp(k) + 0.2 && Cp(1, 2) > Imp(k) - 0.2 && ...
               (state == 0 || state == k)
                state = k;
                p(k) = Cp(1, 1) + Cp(1, 2) * 1j;
                p(mod(k + 2, 4)) = Cp(1, 1) - Cp(1, 2) * 1j;
                Rep = real(p);
                Imp = imag(p);
                set(pole, 'XData', Rep, 'YData', Imp);
            end
        end
    end
end

% Callback function for mouse button up
function myBUCallback(src, ~)
    state = 0; % Reset interaction state
    set(src, 'WindowButtonMotionFcn', '');
end

% Callback function for breaking the simulation using the Escape key
function simulatior_break(~, eventdata)
    if strcmp(eventdata.Key, 'escape')
        fin = 1; % End simulation
    end
end

end
