local CharacterSkillQueue = {} --# assume CharacterSkillQueue: CHARACTER_SKILL_QUEUE
CharacterSkillQueue.__index = CharacterSkillQueue;
CharacterSkillQueue.eventManager = nil --: EVENT_MANAGER

--v function(characterCqi: CA_CQI, eventManager: EVENT_MANAGER) --> CHARACTER_SKILL_QUEUE
function CharacterSkillQueue.new(characterCqi, eventManager)
    local csq = {};
    setmetatable(csq, CharacterSkillQueue);
    --# assume csq: CHARACTER_SKILL_QUEUE
    csq.characterCqi = characterCqi;
    csq.eventManager = eventManager;
    csq.queuedSkills = {} --: vector<string>
    return csq
end

--v function(self: CHARACTER_SKILL_QUEUE, skillName: string)
function CharacterSkillQueue.addSkillToQueue(self, skillName)
    table.insert(self.queuedSkills, skillName);
    self.eventManager:NotifyEvent("SKILL_QUEUE_MODIFIED");
end

--v function(self: CHARACTER_SKILL_QUEUE) --> string
function CharacterSkillQueue.getNextSkill(self)
    return self.queuedSkills[1];
end

--v function(self: CHARACTER_SKILL_QUEUE) --> vector<string>
function CharacterSkillQueue.getAllSkills(self)
    return self.queuedSkills;
end

--v function(self: CHARACTER_SKILL_QUEUE, skillName: string)
function CharacterSkillQueue.skilledInto(self, skillName)
    removeFromList(self.queuedSkills, skillName);
    self.eventManager:NotifyEvent("SKILL_QUEUE_MODIFIED");
end

--v function(self: CHARACTER_SKILL_QUEUE, index: int)
function CharacterSkillQueue.moveSkillUp(self, index)
    local queuedSkills = self.queuedSkills;
    local itemAtIndex = queuedSkills[index];
    table.remove(queuedSkills, index);
    insertTableIndex(queuedSkills, index - 1, itemAtIndex);
    self.eventManager:NotifyEvent("SKILL_QUEUE_MODIFIED");
end

--v function(self: CHARACTER_SKILL_QUEUE, index: int)
function CharacterSkillQueue.moveSkillDown(self, index)
    local queuedSkills = self.queuedSkills;
    local itemAtIndex = queuedSkills[index];
    table.remove(queuedSkills, index);
    insertTableIndex(queuedSkills, index + 1, itemAtIndex);
    self.eventManager:NotifyEvent("SKILL_QUEUE_MODIFIED");
end

--v function(self: CHARACTER_SKILL_QUEUE, index: int)
function CharacterSkillQueue.removeSkill(self, index)
    table.remove(self.queuedSkills, index);
    self.eventManager:NotifyEvent("SKILL_QUEUE_MODIFIED");
end

return {
    new = CharacterSkillQueue.new
}