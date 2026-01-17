--- Unit tests for DeliveryDispatcher

local StagingPointManager = require("StagingPointManager")
local VehicleClassifier = require("VehicleClassifier")
local DeliveryDispatcher = require("DeliveryDispatcher")

function test_delivery_dispatcher(assert_equal, assert_true, assert_false, assert_not_nil, assert_nil)
    -- Setup
    local spm = StagingPointManager.new()
    local vc = VehicleClassifier.new()
    local dispatcher = DeliveryDispatcher.new(spm, vc)
    
    -- Add staging points
    spm:addPoint(100, 50, 100, {VehicleClassifier.Type.RIGID})
    spm:addPoint(200, 50, 200, {VehicleClassifier.Type.ARTICULATED})
    
    -- Test: Create job for rigid vehicle
    local rigidVehicleData = {
        length = 8.0,
        width = 2.5,
        hasArticulationAxis = false
    }
    local jobId = dispatcher:createJob(1, rigidVehicleData, 110, 110)
    assert_not_nil(jobId, "Should create job for compatible vehicle")
    
    local job = dispatcher:getJob(jobId)
    assert_equal(job.state, DeliveryDispatcher.State.IDLE, "New job should be IDLE")
    assert_equal(job.vehicleType, VehicleClassifier.Type.RIGID, "Should classify vehicle correctly")
    
    -- Test: Start job
    local started = dispatcher:startJob(jobId)
    assert_true(started, "Should start job")
    assert_equal(dispatcher:getJob(jobId).state, DeliveryDispatcher.State.EN_ROUTE, "Job should be EN_ROUTE")
    
    -- Test: Can't start already started job
    local restarted = dispatcher:startJob(jobId)
    assert_false(restarted, "Should not restart already started job")
    
    -- Test: Update job state
    local updated = dispatcher:updateJobState(jobId, DeliveryDispatcher.State.STAGED)
    assert_true(updated, "Should update job state")
    assert_equal(dispatcher:getJob(jobId).state, DeliveryDispatcher.State.STAGED, "State should be STAGED")
    
    -- Test: Create job with no compatible staging point
    local oversizeVehicleData = {
        length = 15.0,
        width = 3.0,
        hasArticulationAxis = false
    }
    local noStagingJob = dispatcher:createJob(2, oversizeVehicleData, 50, 50)
    assert_nil(noStagingJob, "Should not create job without compatible staging point")
    
    -- Test: Get active jobs
    local job2Id = dispatcher:createJob(3, rigidVehicleData, 105, 105)
    dispatcher:startJob(job2Id)
    dispatcher:updateJobState(job2Id, DeliveryDispatcher.State.BLOCKED)
    
    local activeJobs = dispatcher:getActiveJobs()
    assert_equal(#activeJobs, 1, "Should have 1 active job (BLOCKED)")
    
    -- Test: Cancel job
    local cancelled = dispatcher:cancelJob(job2Id)
    assert_true(cancelled, "Should cancel job")
    assert_nil(dispatcher:getJob(job2Id), "Cancelled job should not exist")
end
