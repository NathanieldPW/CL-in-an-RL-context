require("Agents/Grid_World_Tabular/grid_world_tabular")

function select_agent(agentName)
    if agentName == "gridWorldTabular" then
        return GridWorldTabularAgent:new()
    end
end
