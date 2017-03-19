require("./grid_world_defs")

Board = {}

Board.numRows = NUM_ROWS
Board.numCols = NUM_COLS

Board.startRow = 1
Board.startCol = ((Board.numCols-1) / 2) +1 

function Board:new()
    -- Make the first position of the new board the "anti-goal"
    local result = { {DEATH} }

    -- Give the new board the normal number of rows and cols
    result.numRows = self.numRows
    result.numCols = self.numCols

    -- Fill every position with SPACE, except for the first and last
    for col=2,result.numCols-1 do
        result[self.startRow][col] = SPACE
    end

    -- Make the last position the goal
    result[self.startRow][result.numCols] = GOAL

    -- Put the agent on the default start position
    result[self.startRow][self.startCol] = AGENT

    setmetatable(result,self)
    self.__index = self
    return result
end

function Board:to_string()
    local str = ""
    for row=1,self.numRows do
        for col=1,self.numCols do
            str = str .. self[row][col];
        end
        str = str .. '\n';
    end
    return str;
end

function Board:copy(newBoard)
    setmetatable(self,Board)
    self.__index = Board
    self.numRows = newBoard.numRows
    self.numCols = newBoard.numCols
    for row=1,newBoard.numRows do
        self[row] = {}
        for col=1,newBoard.numCols do
            self[row][col] = newBoard[row][col]
        end
    end
end
