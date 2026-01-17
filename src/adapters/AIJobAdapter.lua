--- AI Job Adapter
--- FS25 engine integration for AI job dispatch and monitoring

AIJobAdapter = {}
local AIJobAdapter_mt = Class(AIJobAdapter)

function AIJobAdapter.new(deliveryDispatcher, mission)
    local self = setmetatable({}, AIJobAdapter_mt)
    
    self.deliveryDispatcher = deliveryDispatcher
    self.mission = mission
    
    return self
end

--- Extract vehicle data for classification
--- @param vehicle table FS25 vehicle object
--- @return table Vehicle data for classifier
function AIJobAdapter:extractVehicleData(vehicle)
    local sizeData = vehicle.size or {length = 0, width = 0}
    
    return {
        length = sizeData.length,
        width = sizeData.width,
        hasArticulationAxis = vehicle.spec_articulatedAxis ~= nil,
        attachedImplements = self:extractAttachedImplements(vehicle)
    }
end

--- Extract attached implement data recursively
--- @param vehicle table FS25 vehicle object
--- @return table Array of implement data
function AIJobAdapter:extractAttachedImplements(vehicle)
    local implements = {}
    
    if vehicle.spec_attacherJoints then
        local spec = vehicle.spec_attacherJoints
        for _, implement in ipairs(spec.attachedImplements or {}) do
            if implement.object then
                table.insert(implements, self:extractVehicleData(implement.object))
            end
        end
    end
    
    return implements
end

--- Dispatch delivery job for vehicle
--- @param vehicle table FS25 vehicle object
--- @param destX number Destination X coordinate
--- @param destZ number Destination Z coordinate
--- @return number|nil Job ID or nil if failed
function AIJobAdapter:dispatchDelivery(vehicle, destX, destZ)
    local vehicleData = self:extractVehicleData(vehicle)
    local jobId = self.deliveryDispatcher:createJob(
        vehicle.id,
        vehicleData,
        destX,
        destZ
    )
    
    if not jobId then
        g_currentMission:addIngameNotification(
            FSBaseMission.INGAME_NOTIFICATION_CRITICAL,
            "No compatible staging zone available"
        )
        return nil
    end
    
    local job = self.deliveryDispatcher:getJob(jobId)
    
    -- Start AI helper
    local aiDriveStrategy = vehicle:getAIDriveStrategy()
    if aiDriveStrategy then
        aiDriveStrategy:setAIVehicle(vehicle)
        aiDriveStrategy:driveToPoint(job.targetX, job.targetZ, true)
        
        self.deliveryDispatcher:startJob(jobId)
        
        g_currentMission:addIngameNotification(
            FSBaseMission.INGAME_NOTIFICATION_OK,
            string.format("Delivery job started (ID: %d)", jobId)
        )
        
        return jobId
    end
    
    return nil
end

return AIJobAdapter
