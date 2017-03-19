require("./log")
require("../utils")

-- The Logger "class" table
Logger = {}

-- The constructor for the Logger class.
-- Creates a new empty logger.
function Logger:new(base)
    -- Initialise the instance
    local result  = {}
    result.logs   = {}
    result.base   = base

    -- Do Lua class stuff
    setmetatable(result,self)
    self.__index = self

    -- Return the new instance
    return result
end

-- Returns the log associated with the passed in key;
-- or creates it if it does not exist. The labels
-- are used if the log is created.
function Logger:get_log(key,xLabel,yLabel)
    if(self.logs[key] == nil) then
        self.logs[key] = Log:new(xLabel,yLabel)
    end
    return self.logs[key]
end

-- Writes the data the logger is tracking to log files
function Logger:log_to_files(parentDirectory)
    -- The directory to store all the log files
    local directory = parentDirectory .. "/" .. self.base 
    os.execute("mkdir " .. directory)

    -- for(each quantity we were tracking)
    for key,log in pairs(self.logs) do
        -- Create and open a unique log file for the quantity
        local fileName = directory .. "/" .. key
        local file = io.open(fileName,"w")

        -- Write the labels/column headers as the first line in the file.
        -- Make the headers a comment in the matlab language (start with %).
        local xLabel,yLabel,yStddevLabel = log:get_labels()
        file:write("% " .. xLabel .. " " .. yLabel .. " " .. yStddevLabel .. "\n")
        
        -- Write the data to the file (in order)
        local data = log:get_data()
        local xs = sorted_keys(data)
        for index,x in pairs(xs) do
            stats = data[x]
            file:write(x .. " " .. stats.average .. " " .. stats.stddev .. "\n")
        end

        -- Close the log file
        file:close()
    end
end
