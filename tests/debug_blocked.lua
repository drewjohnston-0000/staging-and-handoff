package.path = package.path .. ";../src/core/?.lua"
local BlockedDetector = require("BlockedDetector")

local detector = BlockedDetector.new({
    stationaryThreshold = 3.0,
    movementEpsilon = 0.1
})

local vehicleId = 1
local currentTime = 0

print("=== Debug Blocked Detector ===\n")

-- Big move to 105, 105
currentTime = currentTime + 1
local blocked = detector:update(vehicleId, 105, 105, currentTime)
print(string.format("Time %.1f: Pos (105, 105), blocked: %s", currentTime, tostring(blocked)))

-- Small move to 105.05, 105.05
currentTime = currentTime + 1
blocked = detector:update(vehicleId, 105.05, 105.05, currentTime)
print(string.format("Time %.1f: Pos (105.05, 105.05), blocked: %s", currentTime, tostring(blocked)))

-- Check distance
local dx = 105.05 - 105
local dz = 105.05 - 105
local dist = math.sqrt(dx*dx + dz*dz)
print(string.format("  Distance from (105,105) to (105.05,105.05): %.6f (epsilon: 0.1)", dist))

-- Same position
currentTime = currentTime + 1
blocked = detector:update(vehicleId, 105.05, 105.05, currentTime)
print(string.format("Time %.1f: Pos (105.05, 105.05), blocked: %s", currentTime, tostring(blocked)))

-- Same position, more time  
currentTime = currentTime + 1.5
blocked = detector:update(vehicleId, 105.05, 105.05, currentTime)
print(string.format("Time %.1f: Pos (105.05, 105.05), blocked: %s", currentTime, tostring(blocked)))
print("\nExpected blocked: true")
print("Threshold: 3.0 seconds")
