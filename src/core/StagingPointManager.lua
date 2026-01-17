--- Staging Point Manager
--- Pure Lua module - no GIANTS engine dependencies
--- Manages creation, storage, and selection of staging points

local StagingPointManager = {}
StagingPointManager.__index = StagingPointManager

--- Vehicle compatibility types
StagingPointManager.VehicleType = {
    RIGID = "rigid",
    ARTICULATED = "articulated",
    OVERSIZE = "oversize"
}

--- @param config table Optional configuration
--- @return table New StagingPointManager instance
function StagingPointManager.new(config)
    local self = setmetatable({}, StagingPointManager)
    
    self.points = {}
    self.nextId = 1
    self.maxPoints = (config and config.maxPoints) or 100
    
    return self
end

--- Add a staging point
--- @param x number World X coordinate
--- @param y number World Y coordinate
--- @param z number World Z coordinate
--- @param compatibleTypes table List of compatible vehicle types
--- @return number|nil Staging point ID, or nil if failed
function StagingPointManager:addPoint(x, y, z, compatibleTypes)
    if #self.points >= self.maxPoints then
        return nil
    end
    
    local id = self.nextId
    self.nextId = self.nextId + 1
    
    local point = {
        id = id,
        x = x,
        y = y,
        z = z,
        compatibleTypes = compatibleTypes or {
            StagingPointManager.VehicleType.RIGID,
            StagingPointManager.VehicleType.ARTICULATED,
            StagingPointManager.VehicleType.OVERSIZE
        },
        createdAt = os.time()
    }
    
    self.points[id] = point
    return id
end

--- Remove a staging point
--- @param id number Staging point ID
--- @return boolean Success
function StagingPointManager:removePoint(id)
    if self.points[id] then
        self.points[id] = nil
        return true
    end
    return false
end

--- Find the nearest compatible staging point to a destination
--- @param destX number Destination X coordinate
--- @param destZ number Destination Z coordinate
--- @param vehicleType string Vehicle type constant
--- @return table|nil Staging point or nil if none found
function StagingPointManager:findNearestCompatible(destX, destZ, vehicleType)
    local nearest = nil
    local nearestDistSq = math.huge
    
    for _, point in pairs(self.points) do
        -- Check compatibility
        local isCompatible = false
        for _, compatType in ipairs(point.compatibleTypes) do
            if compatType == vehicleType then
                isCompatible = true
                break
            end
        end
        
        if isCompatible then
            local dx = point.x - destX
            local dz = point.z - destZ
            local distSq = dx * dx + dz * dz
            
            if distSq < nearestDistSq then
                nearestDistSq = distSq
                nearest = point
            end
        end
    end
    
    return nearest
end

--- Get all staging points
--- @return table Array of staging points
function StagingPointManager:getAllPoints()
    local result = {}
    for _, point in pairs(self.points) do
        table.insert(result, point)
    end
    return result
end

--- Get staging point by ID
--- @param id number Staging point ID
--- @return table|nil Staging point or nil
function StagingPointManager:getPoint(id)
    return self.points[id]
end

--- Clear all staging points
function StagingPointManager:clear()
    self.points = {}
    self.nextId = 1
end

return StagingPointManager
