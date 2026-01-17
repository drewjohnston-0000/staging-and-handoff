--- Vehicle Classifier
--- Pure Lua module - no GIANTS engine dependencies
--- Classifies vehicles based on configuration and attached implements

local VehicleClassifier = {}
VehicleClassifier.__index = VehicleClassifier

--- Vehicle type constants
VehicleClassifier.Type = {
    RIGID = "rigid",
    ARTICULATED = "articulated",
    OVERSIZE = "oversize"
}

--- Thresholds for classification (meters)
VehicleClassifier.OVERSIZE_LENGTH_THRESHOLD = 12.0
VehicleClassifier.OVERSIZE_WIDTH_THRESHOLD = 4.0

--- Create new classifier
--- @return table New VehicleClassifier instance
function VehicleClassifier.new()
    local self = setmetatable({}, VehicleClassifier)
    return self
end

--- Classify a vehicle based on its properties
--- @param vehicleData table Vehicle configuration data
--- @return string Vehicle type (RIGID, ARTICULATED, OVERSIZE)
function VehicleClassifier:classify(vehicleData)
    if not vehicleData then
        return VehicleClassifier.Type.RIGID
    end
    
    -- Check for articulation points
    if vehicleData.hasArticulationAxis then
        return VehicleClassifier.Type.ARTICULATED
    end
    
    -- Check dimensions
    local length = vehicleData.length or 0
    local width = vehicleData.width or 0
    
    if length > VehicleClassifier.OVERSIZE_LENGTH_THRESHOLD or 
       width > VehicleClassifier.OVERSIZE_WIDTH_THRESHOLD then
        return VehicleClassifier.Type.OVERSIZE
    end
    
    -- Check attached implements
    if vehicleData.attachedImplements then
        for _, implement in ipairs(vehicleData.attachedImplements) do
            local implType = self:classify(implement)
            if implType == VehicleClassifier.Type.ARTICULATED or 
               implType == VehicleClassifier.Type.OVERSIZE then
                return implType
            end
        end
    end
    
    return VehicleClassifier.Type.RIGID
end

--- Check if a vehicle type is compatible with a staging point type
--- @param vehicleType string Vehicle type
--- @param stagingPointType string Staging point compatible type
--- @return boolean True if compatible
function VehicleClassifier:isCompatible(vehicleType, stagingPointType)
    -- For MVP, exact match required
    return vehicleType == stagingPointType
end

return VehicleClassifier
