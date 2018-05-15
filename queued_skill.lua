local QueuedSkill = {} --# assume QueuedSkill: QUEUED_SKILL
QueuedSkill.__index = QueuedSkill;
QueuedSkill.skill = nil --: string
QueuedSkill.index = nil --: int
QueuedSkill.charRank = nil --: int
QueuedSkill.skillRank = nil --: int

--v function(skill: string) --> QUEUED_SKILL
function QueuedSkill.new(skill)
    local qs = {};
    setmetatable(qs, QueuedSkill);
    --# assume qs: QUEUED_SKILL
    qs.skill = skill;
    qs.index = nil;
    qs.charRank = nil;
    qs.skillRank = nil;
    return qs;
end

return {
    new = QueuedSkill.new
}