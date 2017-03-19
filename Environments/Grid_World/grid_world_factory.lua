require("./grid_world")

local factory = {}

function factory:single_environment()
    return GridWorld:new()
end

function factory:multiple_environments(numEnvs)
    local envs = {}
    for envIndex=1,numEnvs do
        envs[envIndex] = GridWorld:new()
    end
    return envs
end

function factory:curriculum_learning_environments()
    -- There is only one row in the current incarnation of Grid World
    local startRow = 1

    local leftStart = 2
    local rightStart = Board.numCols-1
    -- Remove the two ends, and the middle, then halve
    local numIterations = (Board.numCols-3)/2
    
    -- The different starting positions, in order of ascending difficulty
    -- levels. Difficulty level borders shown.
    --             (b1)    b2 |    b3 |    b4 |   b5 | (b6)
    local startCols = {}--{10, 2,   9, 3,   8, 4,   7,5,   6}
    
    for i=1,numIterations do
        startCols[#startCols+1] = rightStart
        startCols[#startCols+1] = leftStart

        rightStart = rightStart - 1
        leftStart = leftStart + 1
    end 
    startCols[#startCols+1] = Board.startCol

    -- The corresponding difficulty border indices
    --                         b2, b3, b4, b5
    local difficultyBorders = {}--{2,  4,  6,  8}
    for borderIndex=2,#startCols-1,2 do
        difficultyBorders[#difficultyBorders+1] = borderIndex
    end
    
    -- Create a collection of ordered environments with these start positions
    local envs = {}
    for colIndex=1,#startCols do
        startCol = startCols[colIndex]
        envs[colIndex] = GridWorld:new(startRow,startCol)
    end

    return envs,difficultyBorders
end

gridWorldFactory = factory
