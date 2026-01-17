--- Unit tests for VehicleClassifier

local VehicleClassifier = require("VehicleClassifier")

function test_vehicle_classifier(assert_equal, assert_true, assert_false, assert_not_nil, assert_nil)
    local classifier = VehicleClassifier.new()
    
    -- Test: Nil vehicle data
    local typeNil = classifier:classify(nil)
    assert_equal(typeNil, VehicleClassifier.Type.RIGID, "Nil data should default to RIGID")
    
    -- Test: Rigid vehicle
    local rigidVehicle = {
        length = 8.0,
        width = 2.5,
        hasArticulationAxis = false
    }
    local typeRigid = classifier:classify(rigidVehicle)
    assert_equal(typeRigid, VehicleClassifier.Type.RIGID, "Should classify as RIGID")
    
    -- Test: Articulated vehicle
    local articulatedVehicle = {
        length = 10.0,
        width = 2.5,
        hasArticulationAxis = true
    }
    local typeArticulated = classifier:classify(articulatedVehicle)
    assert_equal(typeArticulated, VehicleClassifier.Type.ARTICULATED, "Should classify as ARTICULATED")
    
    -- Test: Oversize by length
    local oversizeLength = {
        length = 15.0,
        width = 2.5,
        hasArticulationAxis = false
    }
    local typeOversizeL = classifier:classify(oversizeLength)
    assert_equal(typeOversizeL, VehicleClassifier.Type.OVERSIZE, "Should classify as OVERSIZE (length)")
    
    -- Test: Oversize by width
    local oversizeWidth = {
        length = 8.0,
        width = 5.0,
        hasArticulationAxis = false
    }
    local typeOversizeW = classifier:classify(oversizeWidth)
    assert_equal(typeOversizeW, VehicleClassifier.Type.OVERSIZE, "Should classify as OVERSIZE (width)")
    
    -- Test: Vehicle with oversize implement
    local withOversizeImplement = {
        length = 6.0,
        width = 2.5,
        hasArticulationAxis = false,
        attachedImplements = {
            {
                length = 14.0,
                width = 3.0,
                hasArticulationAxis = false
            }
        }
    }
    local typeWithImplement = classifier:classify(withOversizeImplement)
    assert_equal(typeWithImplement, VehicleClassifier.Type.OVERSIZE, "Should inherit OVERSIZE from implement")
    
    -- Test: Compatibility check
    assert_true(
        classifier:isCompatible(VehicleClassifier.Type.RIGID, VehicleClassifier.Type.RIGID),
        "Same types should be compatible"
    )
    assert_false(
        classifier:isCompatible(VehicleClassifier.Type.RIGID, VehicleClassifier.Type.ARTICULATED),
        "Different types should be incompatible"
    )
end
