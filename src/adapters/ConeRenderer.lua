--- Cone Renderer Adapter
--- FS25 engine integration for visual staging point indicators

ConeRenderer = {}
local ConeRenderer_mt = Class(ConeRenderer)

function ConeRenderer.new(stagingPointManager, mission)
    local self = setmetatable({}, ConeRenderer_mt)
    
    self.stagingPointManager = stagingPointManager
    self.mission = mission
    self.coneNodes = {}
    
    return self
end

--- Load cone visual asset (traffic cone prop)
function ConeRenderer:loadConeAsset()
    -- For MVP: use simple sphere primitive
    -- Future: load actual traffic cone model
    self.coneAssetLoaded = true
end

--- Create cone visual for staging point
--- @param point table Staging point data
function ConeRenderer:createCone(point)
    if self.coneNodes[point.id] then
        return -- Already exists
    end
    
    -- Create visual node (simplified for MVP)
    -- In real implementation, would load 3D model
    local node = createTransformGroup("StagingCone_" .. point.id)
    link(getRootNode(), node)
    setTranslation(node, point.x, point.y, point.z)
    
    self.coneNodes[point.id] = node
end

--- Remove cone visual
--- @param pointId number Staging point ID
function ConeRenderer:removeCone(pointId)
    local node = self.coneNodes[pointId]
    if node then
        delete(node)
        self.coneNodes[pointId] = nil
    end
end

--- Refresh all cone visuals
function ConeRenderer:refresh()
    -- Remove old cones
    for id, _ in pairs(self.coneNodes) do
        self:removeCone(id)
    end
    
    -- Create cones for all staging points
    local points = self.stagingPointManager:getAllPoints()
    for _, point in ipairs(points) do
        self:createCone(point)
    end
end

--- Draw cone labels (called in draw loop)
function ConeRenderer:draw()
    local camera = getCamera()
    if not camera then
        return
    end
    
    for id, node in pairs(self.coneNodes) do
        local point = self.stagingPointManager:getPoint(id)
        if point then
            local x, y, z = getWorldTranslation(node)
            
            -- Simple distance check for label rendering
            local camX, camY, camZ = getWorldTranslation(camera)
            local dx = x - camX
            local dy = y - camY
            local dz = z - camZ
            local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
            
            if dist < 50 then -- Only render labels within 50m
                -- Render label above cone (simplified)
                setTextAlignment(RenderText.ALIGN_CENTER)
                setTextBold(false)
                setTextColor(1, 1, 1, 1)
                -- renderText would go here in actual implementation
            end
        end
    end
end

--- Cleanup
function ConeRenderer:delete()
    for id, _ in pairs(self.coneNodes) do
        self:removeCone(id)
    end
end

return ConeRenderer
