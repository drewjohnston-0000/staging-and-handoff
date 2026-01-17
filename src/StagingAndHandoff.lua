--- Staging & Handoff - Main Mod Entry Point
--- This is the engine integration layer that bootstraps the mod.
--- Core logic is implemented in pure Lua modules under src/core/

StagingAndHandoff = {}
local StagingAndHandoff_mt = Class(StagingAndHandoff)

function StagingAndHandoff.new(mission, i18n, modDirectory, modName)
    local self = setmetatable({}, StagingAndHandoff_mt)
    
    self.mission = mission
    self.i18n = i18n
    self.modDirectory = modDirectory
    self.modName = modName
    
    self.isServer = mission:getIsServer()
    self.isClient = mission:getIsClient()
    
    return self
end

function StagingAndHandoff:load(mission)
    self.mission = mission
    
    -- Load core modules (pure Lua, testable)
    source(self.modDirectory .. "src/core/StagingPointManager.lua")
    source(self.modDirectory .. "src/core/VehicleClassifier.lua")
    source(self.modDirectory .. "src/core/DeliveryDispatcher.lua")
    source(self.modDirectory .. "src/core/BlockedDetector.lua")
    
    -- Load engine adapters (FS25-specific integration)
    source(self.modDirectory .. "src/adapters/MapInteraction.lua")
    source(self.modDirectory .. "src/adapters/AIJobAdapter.lua")
    source(self.modDirectory .. "src/adapters/ConeRenderer.lua")
    
    print("Staging & Handoff: Mod loaded successfully")
    
    return true
end

function StagingAndHandoff:delete()
    -- Cleanup
end

function StagingAndHandoff:update(dt)
    -- Main update loop
end

function StagingAndHandoff:draw()
    -- Render staging zone indicators
end

-- Register mod with GIANTS engine
Mission00.load = Utils.prependedFunction(Mission00.load, function()
    local modItem = g_modManager:getModByName("FS25_StagingAndHandoff")
    if modItem ~= nil then
        g_stagingAndHandoff = StagingAndHandoff.new(
            g_currentMission,
            g_i18n,
            modItem.modDir,
            modItem.modName
        )
        addModEventListener(g_stagingAndHandoff)
    end
end)
