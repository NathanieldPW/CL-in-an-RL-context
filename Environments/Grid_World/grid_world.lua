require("./board")

GridWorld = {}

function GridWorld:new(startRow,startCol)
    -- Default values for input parameters
    startRow = startRow or Board.startRow
    startCol = startCol or Board.startCol

    -- The new grid world object to return
    result = {}
    result.startRow = startRow
    result.startCol = startCol
    
    -- Make the object actually an instance of GridWorld
    setmetatable(result,self)
    self.__index = self
    
    return result
end

function GridWorld:game_over()
    return self.gameOver;
end

function GridWorld:get_initial_state()
    -- Set up the game
    self.gameOver = false;
    self.board = Board:new()

    -- Place the agent on the correct starting position
    local row,col = find_agent(self.board)
    self.board[row][col] = SPACE
    self.board[self.startRow][self.startCol] = AGENT

    -- Return a copy of the initial state
    local boardCopy = Board:new()
    boardCopy:copy(self.board)
    return boardCopy
end

function GridWorld:take_action(action)
    -- A more convenient variable name
    local board = self.board;

    -- Determine the agent's location
    local row, col = find_agent(board)

    local newRow = row;
    local newCol = col;

    -- Check if the proposed move is within the bounds of the board
    if(action == UP and row-1 >= 1) then
        newRow = row-1;
    end
    if(action == DOWN and row+1 <= board.numRows) then
        newRow = row+1;
    end
    if(action == LEFT and col-1 >= 1) then
        newCol = col-1;
    end
    if(action == RIGHT and col+1 <= board.numCols) then
        newCol = col+1;
    end

    -- if(the attempted move places the agent on a WALL tile)
    if(board[newRow][newCol] == WALL) then
        -- Keep the agent in the same location
        newRow = row;
        newCol = col;
    end

    local reward = 0;
    if(board[newRow][newCol] == GOAL) then
        reward = 10;
        self.gameOver = true;
    end
    if(board[newRow][newCol] == DEATH) then
        reward = -10;
        self.gameOver = true;
    end

    board[row][col] = SPACE;
    board[newRow][newCol] = AGENT;

    -- Return a copy of the board
    local boardCopy = Board:new()
    boardCopy:copy(board)

    return boardCopy, reward;
end 
