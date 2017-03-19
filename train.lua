require("agent_selector")
require("environment_factory_selector")
require("./Logging/logger")
require("./Logging/counter")

function train_in_env(env,agent,logMode,countsPerEnv)
    -- Get the initial state from the environment
    local state = env:get_initial_state()
    local reward = 0
    local mainCounter
    local gameCounter
    local timeCounter
    if logMode == "Game" then
        timeCounter = Counter:new(0,nil)
        gameCounter = Counter:new(0,countsPerEnv)
        mainCounter = gameCounter
    else
        gameCounter = Counter:new(0,nil)
        timeCounter = Counter:new(0,countsPerEnv)
        mainCounter = timeCounter
    end


    -- while(the trial is not over)
    while not mainCounter:limit_reached() do

        -- Get the action for the state from the agent
        action = agent:get_action(state)

        -- Get the reward for the action, and the next state, from the environment
        newState, reward = env:take_action(action)

        -- Give all the transition/reward information to the agent
        agent:process_transition(state,action,reward,newState)

        -- Give the agent the new state on the next pass
        state = newState

        -- if(the current game has ended)
        if env:game_over() then
            -- Start new game!
            state = env:get_initial_state()
            gameCounter:inc()
        end
        timeCounter:inc()
    end
    return timeCounter:get_value()
end

function run_trial(params,logger)

    -- Get the agent from the agent selector
    local agent = select_agent(params.agentString)

    -- Get the environment factory from the environment factory selector
    local envFactory = select_environment_factory(params.envString)
    local envs = {}
    local difficultyBorders = {}

    ------------------------------------------------------------------------
    -- Get the environment(s) from the environment factory
    ------------------------------------------------------------------------
    if(params.mode ~= "CL") then
        -- Single environment for normal RL
        local environment = envFactory:single_environment()
        -- The remaining code assumes a list of environments
        envs = {environment}
    else
        -- Multiple environments grouped by difficulty level from easiest 
        -- to hardest
        envs, difficultyBorders = 
                envFactory:curriculum_learning_environments()
    end
    ------------------------------------------------------------------------

    ------------------------------------------------------------------------
    -- In the event of no given difficulty levels (i.e. not using curriculum
    -- learning), we say that there is implictly one difficulty level. We 
    -- also artificially insert phantom boundaries for the start and end of 
    -- the list of environments. This is to make the main loop code simpler.
    --
    -- e.g. (where bX is the Xth entry in difficultyBoundaries)
    --
    -- (b1 = 1) and (b5 = #envs) are the entries we insert here
    -- (b1)         b2            b3      b4           (b5)
    --       {env1, env2, | env3, env4, | env5, | env6, env7}
    ------------------------------------------------------------------------
    table.insert(difficultyBorders,1,0)
    difficultyBorders[#difficultyBorders+1] = #envs
    ------------------------------------------------------------------------

    -- Spread the games/time evenly across the different difficulties
    local countsPerDifficulty = params.count / (#difficultyBorders-1)
    
    local totalTrainingTime = 0

    -- for(each difficulty level)
    for difficulty=2,#difficultyBorders do

        -- The start of the current difficulty level is one past the border
        -- of the previous difficulty level
        local envIndexMin = difficultyBorders[difficulty-1]+1
        local envIndexMax = difficultyBorders[difficulty]

        -- Spread the games/time for this difficulty evenly across the environments
        local numEnvsInDifficulty = envIndexMax - envIndexMin + 1
        local countsPerEnv = countsPerDifficulty/numEnvsInDifficulty

        -- for(all the environments at this difficulty level)
        for envIndex = envIndexMin, envIndexMax do
            -- Get the environment for the next game
            local env = envs[envIndex]
            
            local time = train_in_env(env,agent,params.logMode,countsPerEnv)
            totalTrainingTime = totalTrainingTime + time
        end
    end
    if params.logMode == "Game" then
        local numGames = params.count
        logger:get_log("TvG","#Games","Time"):log(numGames,totalTrainingTime)
    end
    if params.logMode == "Time" then
        local time = params.count
        agent:log(logger,time)
    end
end

function run_experiment(logMode,timeLimit,dataPoints,experimentDirectory)
    
    local TIME_LIMIT                      = timeLimit
    local NUM_DATA_POINTS                 = dataPoints
    local LOG_INTERVAL                    = TIME_LIMIT/NUM_DATA_POINTS

    local NUM_TRIALS       = 200

    -- Experimental parameters that the trials need to know about
    local experimentParams          = {}
    experimentParams.envString      = "Grid World"
    experimentParams.agentString    = "gridWorldTabular"
    experimentParams.logMode        = logMode

    experimentParams.mode = "normal"
    local nonCLLogger = Logger:new("nonCL")
    for trial=1,NUM_TRIALS do
        print("trial (nonCL) = " .. trial)
        for time=0,TIME_LIMIT,LOG_INTERVAL do
            experimentParams.count = time
            run_trial(experimentParams,nonCLLogger)
        end
    end

    experimentParams.mode = "CL"
    local CLLogger = Logger:new("CL")
    for trial=1,NUM_TRIALS do
        print("trial (CL) = " .. trial)
        for time=0,TIME_LIMIT,LOG_INTERVAL do
            experimentParams.count = time
            run_trial(experimentParams,CLLogger)
        end
    end

    os.execute("mkdir " .. experimentDirectory)
    nonCLLogger:log_to_files(experimentDirectory)
    CLLogger:log_to_files(experimentDirectory)
end



-- Top-level experimental constants
local TOTAL_GAMES      = 10000
local TOTAL_ITERATIONS = 100000

local mainDirectory = os.date("%Y_%m_%d_%H:%M")
local dataDirectory = mainDirectory .. "/" .. "data"
os.execute("mkdir " .. mainDirectory)
os.execute("mkdir " .. dataDirectory)

local experimentDirectory = dataDirectory .. "/TvG"
local numDataPoints = 20
run_experiment("Game",TOTAL_GAMES,numDataPoints,experimentDirectory)

experimentDirectory = dataDirectory .. "/QvT"
numDataPoints = 30
run_experiment("Time",TOTAL_ITERATIONS,numDataPoints,experimentDirectory)
