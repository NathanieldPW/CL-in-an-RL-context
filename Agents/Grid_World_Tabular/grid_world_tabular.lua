require("../../Environments/Grid_World/grid_world_defs")

GridWorldTabularAgent = {};

function GridWorldTabularAgent:new()
    -- Initialise the instance
    local result  = {}

    -- Intialise the Q-Value table
    result.qValues = {}
    result.qValues.numRows = NUM_ROWS
    result.qValues.numCols = NUM_COLS

    for row=1,NUM_ROWS do
        result.qValues[row] = {}
        for col=1,NUM_COLS do
            result.qValues[row][col] = {}
            for action=1,NUM_ACTIONS do
                result.qValues[row][col][action] = 0;
            end
        end
    end

    -- Do Lua class stuff
    setmetatable(result,self)
    self.__index = self

    -- Return the new instance
    return result
end

function GridWorldTabularAgent:print_q_values()
    for action=1,NUM_ACTIONS do
        io.write('Action: ' .. action .. '\n')
        for row=1,self.qValues.numRows do
            for col=1,self.qValues.numCols do
                io.write(string.format("%.2f,", self.qValues[row][col][action]));
            end
            io.write('\n')
        end
        io.write('\n')
    end
end

function GridWorldTabularAgent:average_q_values()
    local averages = {}
    for action=1,NUM_ACTIONS do
        averages[action] = 0;
        for row=1,self.qValues.numRows do
            for col=1,self.qValues.numCols do
                local qValue = self.qValues[row][col][action]
                averages[action] = averages[action] + qValue
            end
        end
        local numPositions = self.qValues.numRows*self.qValues.numCols
        averages[action] = averages[action] / (numPositions)
    end
    return averages
end

function GridWorldTabularAgent:get_action(board)
    -- Get the position of the agent on the board
    local row, col = find_agent(board);

    -- Return the action with the highest QValue
    return self:determineBestAction(row, col);
end

function GridWorldTabularAgent:have_information(row,col)
    local info = false
    for action=1,NUM_ACTIONS-1 do
        if(self.qValues[row][col][action] ~= self.qValues[row][col][action+1]) then
            info = true;
            break;
        end
    end
    return info;
end

function GridWorldTabularAgent:determineBestAction(row, col)

    -- Get the Q-Values associated with the agent's current position
    currentQValues = self.qValues[row][col];

    -- if(we have no idea which action is the best)
    if(true) then --(not self:have_information(row,col)) then
        return (torch.random() % NUM_ACTIONS) + 1;
    end
    
    -- If we make it this far, then there was some
    -- inequality between the action scores. Let's
    -- look for the best one.
    
    -- Start off by assuming the first action is the best
    local maxQValue = currentQValues[1];
    local bestAction = 1;

    -- for(all possible actions)
    for action=1,NUM_ACTIONS do
        -- if(this action is the best one we've seen)
        if(currentQValues[action] > maxQValue) then
            -- Remember it for later
            maxQValue = currentQValues[action];
            bestAction = action;
        end
    end

    return bestAction
end

function GridWorldTabularAgent:process_transition(state,action,reward,nextState)

    local row, col = find_agent(state);
    local nextRow, nextCol = find_agent(nextState);

    -- Get the previous Q-Value for this transition
    Q = self.qValues[row][col][action];

    -- Some RL hyper-parameters
    learningRate = 0.01;
    discount = 0.99;
    
    -- Get the action with the highest Q-Value in the new state
    bestAction = self:determineBestAction(nextRow,nextCol);
    -- Get the maximum Q-Value in the new state
    QMaxCurrent = self.qValues[nextRow][nextCol][bestAction];

    -- Standard Q-learning update rule
    Q = Q + learningRate*(reward+discount*QMaxCurrent - Q);

    -- Store the updated Q-Value back into the table
    self.qValues[row][col][action] = Q;
end

function GridWorldTabularAgent:average_q_value(action)
    local average = 0
    for row=1, self.qValues.numRows do
        for col=1, self.qValues.numCols do
            average = average + self.qValues[row][col][action];
        end
    end
    return average / (self.qValues.numRows*self.qValues.numCols);
end

function GridWorldTabularAgent:log(logger,time)
    local averages = self:average_q_values()
    for action=1,NUM_ACTIONS do
        local logKey = "Q_" .. action;
        logger:get_log(logKey,"Time","Avg_Q"):log(time,averages[action])
    end
end

function GridWorldTabularAgent:log_raw(logger,time)
    local averages = self:average_q_values()
    for action=1,NUM_ACTIONS do
        for row=1,self.qValues.numRows do
            for col=1,self.qValues.numCols do
                local logKey = "Q_" .. action .. "_" .. row .. "_" .. col;
                local qVal = self.qValues[row][col][action];
                logger:get_log(logKey,"Time",logKey):log(time,qVal);
            end
        end
    end
end
