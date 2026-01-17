--- Unit tests for StagingPointManager

local StagingPointManager = require("StagingPointManager")

function test_staging_point_manager(assert_equal, assert_true, assert_false, assert_not_nil, assert_nil)
    -- Test: Create manager
    local manager = StagingPointManager.new()
    assert_not_nil(manager, "Manager should be created")
    
    -- Test: Add staging point
    local id = manager:addPoint(100, 50, 200, {StagingPointManager.VehicleType.RIGID})
    assert_not_nil(id, "Should return ID for new point")
    assert_equal(id, 1, "First ID should be 1")
    
    -- Test: Get staging point
    local point = manager:getPoint(id)
    assert_not_nil(point, "Should retrieve added point")
    assert_equal(point.x, 100, "X coordinate should match")
    assert_equal(point.z, 200, "Z coordinate should match")
    
    -- Test: Add multiple points
    local id2 = manager:addPoint(150, 50, 250, {StagingPointManager.VehicleType.ARTICULATED})
    assert_equal(id2, 2, "Second ID should be 2")
    
    -- Test: Find nearest compatible
    local nearest = manager:findNearestCompatible(110, 210, StagingPointManager.VehicleType.RIGID)
    assert_not_nil(nearest, "Should find compatible point")
    assert_equal(nearest.id, id, "Should find first point as nearest")
    
    -- Test: Incompatible vehicle type
    local incompatible = manager:findNearestCompatible(110, 210, StagingPointManager.VehicleType.OVERSIZE)
    assert_nil(incompatible, "Should not find incompatible point")
    
    -- Test: Remove point
    local removed = manager:removePoint(id)
    assert_true(removed, "Should successfully remove point")
    assert_nil(manager:getPoint(id), "Removed point should not be retrievable")
    
    -- Test: Max points limit
    local limitedManager = StagingPointManager.new({maxPoints = 2})
    limitedManager:addPoint(0, 0, 0)
    limitedManager:addPoint(1, 0, 1)
    local overflow = limitedManager:addPoint(2, 0, 2)
    assert_nil(overflow, "Should reject point beyond limit")
    
    -- Test: Get all points
    local allPoints = manager:getAllPoints()
    assert_equal(#allPoints, 1, "Should have 1 point remaining")
    
    -- Test: Clear all points
    manager:clear()
    allPoints = manager:getAllPoints()
    assert_equal(#allPoints, 0, "Should have no points after clear")
end
