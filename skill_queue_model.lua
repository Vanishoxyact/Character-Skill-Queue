local EventManager = require("event_manager");
local CharacterSkillQueue = require("character_skill_queue");
local SkillQueueModel = {} --# assume SkillQueueModel: SKILL_QUEUE_MODEL
SkillQueueModel.__index = SkillQueueModel;

--v function() --> SKILL_QUEUE_MODEL
function SkillQueueModel.new()
    local sqm = {};
    setmetatable(sqm, SkillQueueModel);
    --# assume sqm: SKILL_QUEUE_MODEL
    sqm.characterSkillQueues = {} --: map<CA_CQI, CHARACTER_SKILL_QUEUE>
    sqm.eventManager = EventManager.new();
    return sqm;
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

return {
    new = SkillQueueModel.new
}