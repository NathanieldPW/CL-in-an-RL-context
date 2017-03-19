SPACE = '_'
AGENT = 'A'
WALL = '#'
GOAL = 'O'
DEATH = 'X'

NUM_ACTIONS = 2
LEFT  = 1
RIGHT = 2
--UP    = 3
--DOWN  = 4

NUM_ROWS=1
NUM_COLS=101

function find_agent(board)
    for row=1,board.numRows do
        for col=1,board.numCols do
            if board[row][col] == AGENT then
                return row,col
            end
        end
    end
    print("Error: Could not find agent on grid world board")
    return 0,0
end
