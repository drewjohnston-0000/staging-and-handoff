--- Unit tests for BlockedDetector

local BlockedDetector = require("BlockedDetector")

function test_blocked_detector(assert_equal, assert_true, assert_false, assert_not_nil, assert_nil)
    local detector = BlockedDetector.new({
        stationaryThreshold = 3.0,
        movementEpsilon = 0.1
    })
    
    local vehicleId = 1
    local currentTime = 0
    
    -- Test: First update (not blocked)
    local blocked = detector:update(vehicleId, 100, 100, currentTime)
    assert_false(blocked, "First update should not be blocked")
    
    -- Test: Moving vehicle (not blocked)
    currentTime = currentTime + 1
    blocked = detector:update(vehicleId, 102, 102, currentTime)
    assert_false(blocked, "Moving vehicle should not be blocked")
    
    -- Test: Stationary but below threshold (not blocked)
    currentTime = currentTime + 1
    blocked = detector:update(vehicleId, 102, 102, currentTime)
    assert_false(blocked, "Stationary below threshold should not be blocked")
    
    currentTime = currentTime + 1
    blocked = detector:update(vehicleId, 102, 102, currentTime)
    assert_false(blocked, "Still below threshold")
    
    -- Test: Stationary exceeds threshold (blocked)
    currentTime = currentTime + 2
    blocked = detector:update(vehicleId, 102, 102, currentTime)
    assert_true(blocked, "Stationary exceeding threshold should be blocked")
    
    -- Test: Vehicle starts moving again (not blocked)
    currentTime = currentTime + 1
    blocked = detector:update(vehicleId, 105, 105, currentTime)
    assert_false(blocked, "Moving vehicle should reset blocked state")
    
    -- Test: Small movements within epsilon (should still detect as stationary)
    currentTime = currentTime + 1
    blocked = detector:update(vehicleId, 105.05, 105.05, currentTime)
    assert_false(blocked, "Small movement below threshold")
    
    currentTime = currentTime + 1
    blocked = detector:update(vehicleId, 105.05, 105.05, currentTime)
    assert_false(blocked, "Still below stationary threshold")
    
    currentTime = currentTime + 2.1
    blocked = detector:update(vehicleId, 105.05, 105.05, currentTime)
    assert_true(blocked, "Stationary for >3 seconds should be blocked")
    
    -- Test: Reset vehicle
    detector:reset(vehicleId)
    currentTime = currentTime + 1
    blocked = detector:update(vehicleId, 105, 105, currentTime)
    assert_false(blocked, "Reset vehicle should not be blocked")
    
    -- Test: Multiple vehicles
    local vehicle2Id = 2
    blocked = detector:update(vehicle2Id, 200, 200, currentTime)
    assert_false(blocked, "Second vehicle should track independently")
    
    -- Test: Clear all
    detector:clear()
    blocked = detector:update(vehicleId, 100, 100, currentTime)
    assert_false(blocked, "Cleared detector should reset all tracking")
end
