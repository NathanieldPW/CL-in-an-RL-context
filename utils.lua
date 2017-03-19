function sum(values)
    local total = 0
    for index,value in pairs(values) do
        total = total + value
    end
    return total
end

function mean(values)
    return sum(values) / #values
end

function stddev(values)
    local average = mean(values)
    local variance = 0
    for index, value in pairs(values) do
        variance = variance + math.pow(value-average,2)
    end
    variance = variance / (#values-1)
    return math.sqrt(variance)
end

function sorted_keys(dataTable)
    local keys = {}
    for key,value in pairs(dataTable) do
        table.insert(keys,(key))
    end
    table.sort(keys)
    return keys
end
