#!/usr/bin/env lua
--- Test Runner for Staging & Handoff
--- Runs all unit tests and reports results

package.path = package.path .. ";../src/core/?.lua"

local totalTests = 0
local passedTests = 0
local failedTests = 0

--- Simple assertion framework
local function assert_equal(actual, expected, message)
    totalTests = totalTests + 1
    if actual == expected then
        passedTests = passedTests + 1
        io.write(".")
    else
        failedTests = failedTests + 1
        io.write("F")
        print("\nFAILED: " .. (message or "Assertion failed"))
        print("  Expected: " .. tostring(expected))
        print("  Actual:   " .. tostring(actual))
    end
end

local function assert_true(value, message)
    assert_equal(value, true, message)
end

local function assert_false(value, message)
    assert_equal(value, false, message)
end

local function assert_not_nil(value, message)
    totalTests = totalTests + 1
    if value ~= nil then
        passedTests = passedTests + 1
        io.write(".")
    else
        failedTests = failedTests + 1
        io.write("F")
        print("\nFAILED: " .. (message or "Expected non-nil value"))
    end
end

local function assert_nil(value, message)
    totalTests = totalTests + 1
    if value == nil then
        passedTests = passedTests + 1
        io.write(".")
    else
        failedTests = failedTests + 1
        io.write("F")
        print("\nFAILED: " .. (message or "Expected nil value"))
        print("  Actual: " .. tostring(value))
    end
end

--- Run test suite
local function run_test_suite(name, suite)
    print("\n\nRunning " .. name .. "...")
    suite(assert_equal, assert_true, assert_false, assert_not_nil, assert_nil)
end

--- Load test modules
dofile("test_staging_point_manager.lua")
dofile("test_vehicle_classifier.lua")
dofile("test_delivery_dispatcher.lua")
dofile("test_blocked_detector.lua")

--- Run all tests
print("=== Staging & Handoff Unit Tests ===")
run_test_suite("StagingPointManager Tests", test_staging_point_manager)
run_test_suite("VehicleClassifier Tests", test_vehicle_classifier)
run_test_suite("DeliveryDispatcher Tests", test_delivery_dispatcher)
run_test_suite("BlockedDetector Tests", test_blocked_detector)

--- Print summary
print("\n\n=== Test Summary ===")
print(string.format("Total:  %d", totalTests))
print(string.format("Passed: %d", passedTests))
print(string.format("Failed: %d", failedTests))

if failedTests == 0 then
    print("\n✓ All tests passed!")
    os.exit(0)
else
    print("\n✗ Some tests failed")
    os.exit(1)
end
