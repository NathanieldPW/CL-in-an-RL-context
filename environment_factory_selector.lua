require("Environments/Grid_World/grid_world_factory")

function select_environment_factory(name)
    if name == "Grid World" then
        return gridWorldFactory
    end
end
