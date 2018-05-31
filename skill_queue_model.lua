local CharacterSkillQueue = require("character_skill_queue");
local SkillQueueModel = {} --# assume SkillQueueModel: SKILL_QUEUE_MODEL
SkillQueueModel.__index = SkillQueueModel;
SkillQueueModel.characterSkillQueues = {} --: map<CA_CQI, CHARACTER_SKILL_QUEUE>
SkillQueueModel.eventManager = nil --: EVENT_MANAGER

local skillQueueTableName = "skillQueue";

--v function(self: SKILL_QUEUE_MODEL, callback: function())
function SkillQueueModel.registerForSkillQueueModification(self, callback)
    self.eventManager:RegisterForEvent("SKILL_QUEUE_MODIFIED", callback);
end

--v function(self: SKILL_QUEUE_MODEL, character: CA_CHAR) --> CHARACTER_SKILL_QUEUE
function SkillQueueModel.getSkillQueueForCharacter(self, character)
    return self.characterSkillQueues[character:cqi()];
end

--v function(self: SKILL_QUEUE_MODEL, character: CA_CHAR) --> CHARACTER_SKILL_QUEUE
function SkillQueueModel.createCharacterSkillQueue(self, character)
    local characterSkillQueue = CharacterSkillQueue.new(character:cqi(), self.eventManager);
    self.characterSkillQueues[character:cqi()] = characterSkillQueue;
    return characterSkillQueue;
end

--v function(self: SKILL_QUEUE_MODEL, character: CA_CHAR) --> CHARACTER_SKILL_QUEUE
function SkillQueueModel.getOrCreateCharacterSkillQueue(self, character)
    if self.characterSkillQueues[character:cqi()] then
        return self.characterSkillQueues[character:cqi()];
    else
        return self:createCharacterSkillQueue(character);
    end
end

--v function(self: SKILL_QUEUE_MODEL)
function SkillQueueModel.loadSkillQueues(self)
    local tableString = cm:get_saved_value(skillQueueTableName);
    if tableString then
        loadedTable = loadstring(tableString)();
        --# assume loadedTable: map<string, vector<string>>
        for charCqi, skillList in pairs(loadedTable) do
            local cqi = tonumber(charCqi, 10);
            --# assume cqi : CA_CQI
            local characterSkillQueue = CharacterSkillQueue.new(cqi, self.eventManager);
            for i, skill in ipairs(skillList) do
                characterSkillQueue:addSkillToQueue(skill);
            end
            self.characterSkillQueues[cqi] = characterSkillQueue;
        end
    end
end

--v function(self: SKILL_QUEUE_MODEL) --> map<string, vector<string>>
function SkillQueueModel.generateSaveTable(self)
    local saveTable = {}  --: map<string, vector<string>>
    for charCqi, characterSkillQueue in pairs(self.characterSkillQueues) do
        saveTable[tostring(charCqi)] = characterSkillQueue:getAllSkills();
    end
    return saveTable;
end

--v function(tab: any) --> string
local function GetTableSaveState(tab)
    local ret = "return {"..cm:process_table_save(tab).."}";
    return ret;
end

--v function(self: SKILL_QUEUE_MODEL)
function SkillQueueModel.saveSkillQueues(self)
    local tableString = GetTableSaveState(self:generateSaveTable());
    cm:set_saved_value(skillQueueTableName, GetTableSaveState(self:generateSaveTable()));
end

--v function() --> SKILL_QUEUE_MODEL
function SkillQueueModel.new()
    local sqm = {};
    setmetatable(sqm, SkillQueueModel);
    --# assume sqm: SKILL_QUEUE_MODEL
    sqm.characterSkillQueues = {};
    sqm.eventManager = EventManager.new();
    sqm:loadSkillQueues();
    sqm:registerForSkillQueueModification(
        function()
            sqm:saveSkillQueues();
        end
    );
    return sqm;
end

return {
    new = SkillQueueModel.new
}