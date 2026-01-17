--- Blocked Detector
--- Pure Lua module - no GIANTS engine dependencies
--- Detects when vehicles are stuck or blocked during delivery

local BlockedDetector = {}
BlockedDetector.__index = BlockedDetector

--- Default configuration
BlockedDetector.DEFAULT_STATIONARY_THRESHOLD = 5.0  -- seconds
BlockedDetector.DEFAULT_MOVEMENT_EPSILON = 0.1      -- meters

--- @param config table Optional configuration
--- @return table New BlockedDetector instance
function BlockedDetector.new(config)
    local self = setmetatable({}, BlockedDetector)
    
    config = config or {}
    self.stationaryThreshold = config.stationaryThreshold or BlockedDetector.DEFAULT_STATIONARY_THRESHOLD
    self.movementEpsilon = config.movementEpsilon or BlockedDetector.DEFAULT_MOVEMENT_EPSILON
    
    self.vehicleStates = {}
    
    return self
end

--- Update vehicle position and check for blocked state
--- @param vehicleId number Vehicle identifier
--- @param x number Current X position
--- @param z number Current Z position
--- @param currentTime number Current timestamp
--- @return boolean True if vehicle is blocked
function BlockedDetector:update(vehicleId, x, z, currentTime)
    local state = self.vehicleStates[vehicleId]
    
    if not state then
        -- First observation
        self.vehicleStates[vehicleId] = {
            lastX = x,
            lastZ = z,
            lastMoveTime = currentTime,
            stationarySince = nil
        }
        return false
    end
    
    -- Calculate distance moved since last update
    local dx = x - state.lastX
    local dz = z - state.lastZ
    local distMoved = math.sqrt(dx * dx + dz * dz)
    
    if distMoved > self.movementEpsilon then
        -- Vehicle has moved
        state.lastX = x
        state.lastZ = z
        state.lastMoveTime = currentTime
        state.stationarySince = nil
        return false
    else
        -- Vehicle is stationary
        if not state.stationarySince then
            state.stationarySince = currentTime
        end
        
        local stationaryDuration = currentTime - state.stationarySince
        return stationaryDuration >= self.stationaryThreshold
    end
end

--- Reset tracking for a vehicle
--- @param vehicleId number Vehicle identifier
function BlockedDetector:reset(vehicleId)
    self.vehicleStates[vehicleId] = nil
end

--- Clear all vehicle states
function BlockedDetector:clear()
    self.vehicleStates = {}
end

return BlockedDetector
