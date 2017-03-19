require("../utils")

Log = {}

function Log:new(xLabel,yLabel)
    -- Initialise the instance
    local result  = {}
    result.data   = {}
    result.xLabel = xLabel or "x"
    result.yLabel = yLabel or "y"

    -- Do Lua class stuff
    setmetatable(result,self)
    self.__index = self

    -- Return the new instance
    return result
end

function Log:log(x,y)
    if(self.data[x] == nil) then
        self.data[x] = {};
    end
    table.insert(self.data[x],y)
end

function Log:get_labels()
    return self.xLabel, self.yLabel, self.yLabel .. "_stddev"
end

function Log:get_data()
    result = {}
    for x,ys in pairs(self.data) do
        result[x]         = {}
        result[x].average = mean(ys)
        result[x].stddev  = stddev(ys)
    end
    return result
end
