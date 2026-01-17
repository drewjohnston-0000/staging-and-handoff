--- Delivery Dispatcher
--- Pure Lua module - no GIANTS engine dependencies
--- Manages delivery job lifecycle and state transitions

local DeliveryDispatcher = {}
DeliveryDispatcher.__index = DeliveryDispatcher

--- Job states
DeliveryDispatcher.State = {
    IDLE = "idle",
    EN_ROUTE = "en_route",
    STAGED = "staged",
    BLOCKED = "blocked",
    FAILED = "failed"
}

--- @param stagingPointManager table StagingPointManager instance
--- @param vehicleClassifier table VehicleClassifier instance
--- @return table New DeliveryDispatcher instance
function DeliveryDispatcher.new(stagingPointManager, vehicleClassifier)
    local self = setmetatable({}, DeliveryDispatcher)
    
    self.stagingPointManager = stagingPointManager
    self.vehicleClassifier = vehicleClassifier
    self.jobs = {}
    self.nextJobId = 1
    
    return self
end

--- Create a delivery job
--- @param vehicleId number Vehicle identifier
--- @param vehicleData table Vehicle configuration data
--- @param destX number Destination X coordinate
--- @param destZ number Destination Z coordinate
--- @return number|nil Job ID or nil if no compatible staging point
function DeliveryDispatcher:createJob(vehicleId, vehicleData, destX, destZ)
    -- Classify vehicle
    local vehicleType = self.vehicleClassifier:classify(vehicleData)
    
    -- Find compatible staging point
    local stagingPoint = self.stagingPointManager:findNearestCompatible(
        destX, destZ, vehicleType
    )
    
    if not stagingPoint then
        return nil  -- No compatible staging point available
    end
    
    local jobId = self.nextJobId
    self.nextJobId = self.nextJobId + 1
    
    local job = {
        id = jobId,
        vehicleId = vehicleId,
        vehicleType = vehicleType,
        stagingPointId = stagingPoint.id,
        targetX = stagingPoint.x,
        targetZ = stagingPoint.z,
        state = DeliveryDispatcher.State.IDLE,
        createdAt = os.time(),
        lastUpdateAt = os.time()
    }
    
    self.jobs[jobId] = job
    return jobId
end

--- Start a delivery job
--- @param jobId number Job ID
--- @return boolean Success
function DeliveryDispatcher:startJob(jobId)
    local job = self.jobs[jobId]
    if not job or job.state ~= DeliveryDispatcher.State.IDLE then
        return false
    end
    
    job.state = DeliveryDispatcher.State.EN_ROUTE
    job.lastUpdateAt = os.time()
    return true
end

--- Update job state
--- @param jobId number Job ID
--- @param newState string New state
--- @return boolean Success
function DeliveryDispatcher:updateJobState(jobId, newState)
    local job = self.jobs[jobId]
    if not job then
        return false
    end
    
    job.state = newState
    job.lastUpdateAt = os.time()
    return true
end

--- Get job by ID
--- @param jobId number Job ID
--- @return table|nil Job data or nil
function DeliveryDispatcher:getJob(jobId)
    return self.jobs[jobId]
end

--- Get all active jobs (not STAGED or FAILED)
--- @return table Array of active jobs
function DeliveryDispatcher:getActiveJobs()
    local active = {}
    for _, job in pairs(self.jobs) do
        if job.state ~= DeliveryDispatcher.State.STAGED and 
           job.state ~= DeliveryDispatcher.State.FAILED then
            table.insert(active, job)
        end
    end
    return active
end

--- Cancel a job
--- @param jobId number Job ID
--- @return boolean Success
function DeliveryDispatcher:cancelJob(jobId)
    if self.jobs[jobId] then
        self.jobs[jobId] = nil
        return true
    end
    return false
end

return DeliveryDispatcher
