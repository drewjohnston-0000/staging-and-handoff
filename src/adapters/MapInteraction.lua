--- Map Interaction Adapter
--- FS25 engine integration for player map interaction and staging point creation

MapInteraction = {}
local MapInteraction_mt = Class(MapInteraction)

function MapInteraction.new(stagingPointManager, mission)
    local self = setmetatable({}, MapInteraction_mt)
    
    self.stagingPointManager = stagingPointManager
    self.mission = mission
    
    return self
end

--- Handle create staging point action
function MapInteraction:onCreateStagingPoint()
    local player = self.mission.player
    if not player then
        return
    end
    
    local x, y, z = getWorldTranslation(player.rootNode)
    
    -- For MVP: all compatibility types enabled by default
    local compatibleTypes = {
        require("VehicleClassifier").Type.RIGID,
        require("VehicleClassifier").Type.ARTICULATED,
        require("VehicleClassifier").Type.OVERSIZE
    }
    
    local id = self.stagingPointManager:addPoint(x, y, z, compatibleTypes)
    
    if id then
        g_currentMission:addIngameNotification(
            FSBaseMission.INGAME_NOTIFICATION_OK,
            "Staging point created"
        )
        -- Trigger cone renderer to update
        if g_stagingAndHandoff and g_stagingAndHandoff.coneRenderer then
            g_stagingAndHandoff.coneRenderer:refresh()
        end
    else
        g_currentMission:addIngameNotification(
            FSBaseMission.INGAME_NOTIFICATION_CRITICAL,
            "Failed to create staging point (limit reached?)"
        )
    end
end

return MapInteraction
