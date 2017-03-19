Counter = {}

function Counter:new(initialValue,limit,extension)
    -- Initialise the instance
    local result     = {}
    result.value     = initialValue or 0
    result.extension = extension    or 0
    result.limit     = limit

    -- Do Lua class stuff
    setmetatable(result,self)
    self.__index = self

    -- Return the new instance
    return result
end

function Counter:get_limit()
    return self.limit
end

function Counter:get_value()
    return self.value
end

function Counter:is_infinite()
    return self.limit == nil
end

function Counter:inc()
    self.value = self.value + 1
end

function Counter:limit_reached()
    return (not self:is_infinite()) and (self.value >= self.limit)
end

function Counter:extend_limit()
    self.limit = self.limit + self.extension
end
