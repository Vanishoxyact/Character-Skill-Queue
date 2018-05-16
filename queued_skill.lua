local EventManager = require("event_manager");
local QueuedSkill = {} --# assume QueuedSkill: QUEUED_SKILL
QueuedSkill.__index = QueuedSkill;
QueuedSkill.skill = nil --: string
QueuedSkill.id = nil --: int
QueuedSkill.index = nil --: int
QueuedSkill.charRank = nil --: int
QueuedSkill.skillRank = nil --: int
QueuedSkill.eventManager = nil --: EVENT_MANAGER

--v function(skill: string) --> QUEUED_SKILL
function QueuedSkill.new(skill)
    local qs = {};
    setmetatable(qs, QueuedSkill);
    --# assume qs: QUEUED_SKILL
    qs.skill = skill;
    qs.id = nil;
    qs.index = nil;
    qs.charRank = nil;
    qs.skillRank = nil;
    qs.eventManager = EventManager.new();
    return qs;
end

--v function(self: QUEUED_SKILL, eventType: QUEUED_SKILL_EVENT, callback: function())
function QueuedSkill.RegisterForEvent(self, eventType, callback)
    self.eventManager:RegisterForEvent(eventType, callback);
end

--v function(self: QUEUED_SKILL, eventType: QUEUED_SKILL_EVENT)
function QueuedSkill.NotifyEvent(self, eventType)
    self.eventManager:NotifyEvent(eventType);
end

--v function(self: QUEUED_SKILL, index: int)
function QueuedSkill.setIndex(self, index)
    self.index = index;
    self:NotifyEvent("QUEUED_SKILL_INDEX_CHANGE");
end

--v function(self: QUEUED_SKILL, charRank: int)
function QueuedSkill.setCharRank(self, charRank)
    self.charRank = charRank;
    self:NotifyEvent("QUEUED_SKILL_CHAR_RANK_CHANGE");
end

--v function(self: QUEUED_SKILL, skillRank: int)
function QueuedSkill.setSkillRank(self, skillRank)
    self.skillRank = skillRank;
    self:NotifyEvent("QUEUED_SKILL_SKILL_RANK_CHANGE");
end

--v function(self: QUEUED_SKILL, skill: string)
function QueuedSkill.setSkill(self, skill)
    self.skill = skill;
    self:NotifyEvent("QUEUED_SKILL_SKILL_CHANGE");
end

return {
    new = QueuedSkill.new
}