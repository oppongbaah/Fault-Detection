function solution = pso(problem, params)
    %% Problem Definiton
    CostFunction = problem.CostFunction;    % Cost Function
    nVar = problem.nVar;                    % Number of Unknown (Decision) Variables
    varSize = [nVar 1];                     % Matrix Size of Decision Variables
    varMin = problem.varMin;	            % Lower Bound of Decision Variables
    varMax = problem.varMax;                % Upper Bound of Decision Variables

    %% Parameters Definition
    maxIteration = params.maxIteration;     % Maximum Number of Iterations
    nPop = params.nPop;                     % Population Size (Swarm Size)
    w = params.w;                           % Intertia Coefficient
    wdamp = params.wdamp;                   % Damping Ratio of Inertia Coefficient
    c1 = params.c1;                         % Personal Acceleration Coefficient
    c2 = params.c2;                         % Social Acceleration Coefficient
    r1 = unifrnd(0, 1);                     % uniformly random value between 0 and 1
    r2 = unifrnd(0, 1);                     % uniformly random value between 0 and 1
    showIterInfo = params.verbose;          % The Flag for Showing Iteration Information
    maxVelocity = zeros([2 1]);             % Upper Bound for the Velocity
    minVelocity = zeros([2 1]);             % Lower Bound for the Velocity
    dimension = problem.nVar;               % dimension is the unknown variables

    %% Initialization
    % Create a Particle Object [Class]
    Particle.position = zeros([2 1]);
    Particle.velocity = [];
    Particle.cost = []; % the RMSE
    Particle.anfis = [];
    Particle.train = [];
    Particle.test = [];
    Particle.prediction = 0;
    Particle.best.position = zeros([2 1]);
    Particle.best.cost = 0;
    Particle.best.anfis = [];
    Particle.best.train = [];
    Particle.best.test = [];
    Particle.best.prediction = 0;

    % Create Population Array
    particle = repmat(Particle, nPop, 1);

    % Create a GLobal Best Object [Class]
    GlobalBest.cost = inf;
    GlobalBest.position = zeros([2 1]);
    GlobalBest.anfis = [];

    % Initialize Population Members
    for i=1:nPop
        % Generate Random Solution
        for j=1:dimension
           if j == 2
            particle(i).position(j) = round(unifrnd(varMin(j), ...
                varMax(j)), 1);
           else
            particle(i).position(j) = round(unifrnd(varMin(j), ...
                varMax(j)));
           end
        end

        % Initialize Velocity
        particle(i).velocity = zeros(varSize);

        % Evaluation
        [rmse, ANFIS, train, test, prediction] = CostFunction(particle(i).position, ...
            params.fisOptions, params.Data);

        particle(i).cost = rmse;
        particle(i).anfis = ANFIS;
        particle(i).train = train;
        particle(i).test = test;
        particle(i).prediction = prediction;

        % Update the Initial Personal Best
        temp = rmfield(particle(i), "velocity");
        particle(i).best = temp;

        % Update Global Best
        if particle(i).best.cost < GlobalBest.cost
            GlobalBest = particle(i).best;
        end
    end

    % Array to Hold Best Cost Value on Each Iteration
    BestCosts = zeros(maxIteration, 1);

    %% Searching Algorithm
    for it=1:maxIteration
        for n=1:nPop
            for d=1:dimension
                % Update Velocity
                particle(n).velocity(d) = w*particle(n).velocity(d) ...
                    + c1*r1.*(particle(n).best.position(d) - particle(n).position(d)) ...
                    + c2*r2.*(GlobalBest.position(d) - particle(n).position(d));
    
                % Update Position
                if d == 2
                    particle(n).position(d) = round(particle(n).position(d) + particle(n).velocity(d), 1);
                else
                    particle(n).position(d) = round(particle(n).position(d) + particle(n).velocity(d));
                end

                % Apply Lower and Upper Bound Limits
                maxVelocity(d) = 0.2*(varMax(d)-varMin(d));
                minVelocity(d) = -maxVelocity(d);
                particle(n).velocity(d) = max(particle(n).velocity(d), minVelocity(d));
                particle(n).velocity(d) = min(particle(n).velocity(d), maxVelocity(d));

                particle(n).position(d) = max(particle(n).position(d), varMin(d));
                particle(n).position(d) = min(particle(n).position(d), varMax(d));
            end

            % Evaluation
            [rmse, ANFIS, train, test, prediction] = CostFunction(particle(i).position, ...
                params.fisOptions, params.Data);
    
            particle(n).cost = rmse;
            particle(n).anfis = ANFIS;
            particle(n).train = train;
            particle(n).test = test;
            particle(n).prediction = prediction;

            % Update Personal Best
            if particle(n).cost < particle(n).best.cost
                temp = rmfield(particle(n), "velocity");
                particle(n).best = temp;

                % Update Global Best
                if particle(n).best.cost < GlobalBest.cost
                    GlobalBest = particle(n).best;
                end            
            end
        end

        % Store the Best Cost Values
        BestCosts(it) = GlobalBest.cost;

        % Display Iteration Information, if desired
        if showIterInfo == 1
            disp(['PSO: Iteration count = ' num2str(it) ', Best Cost = ' num2str(BestCosts(it))]);
        end

        % Damping Inertia Coefficient
        w = w * wdamp;
    end

    %% Map the optimized solution
    solution.optimized = GlobalBest;
    solution.allBestCosts = BestCosts;
end
