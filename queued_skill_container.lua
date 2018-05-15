local QueuedSkillContainer = {} --# assume QueuedSkillContainer: QUEUED_SKILL_CONTAINER
QueuedSkillContainer.__index = QueuedSkillContainer;
QueuedSkillContainer.container = nil --: CONTAINER
QueuedSkillContainer.queuedSkill = nil --: QUEUED_SKILL
QueuedSkillContainer.parentPanel = nil --: CA_UIC

--v function(self: QUEUED_SKILL_CONTAINER, queuedSkill: QUEUED_SKILL)
function QueuedSkillContainer.populateContainer(self, queuedSkill)
    local container = self.container;
    -- TODO update name with rank
    local skillName = Text.new("QueuedSkillContainer" .. queuedSkill.skill, self.parentPanel, "NORMAL", queuedSkill.skill);
    container:AddComponent(skillName);
end

--v function(queuedSkill: QUEUED_SKILL, parentPanel: CA_UIC) --> QUEUED_SKILL_CONTAINER
function QueuedSkillContainer.new(queuedSkill, parentPanel)
    local qsc = {};
    setmetatable(qsc, QueuedSkillContainer);
    --# assume qsc: QUEUED_SKILL_CONTAINER
    qsc.container = Container.new(FlowLayout.HORIZONTAL);
    qsc.queuedSkill = queuedSkill;
    qsc.parentPanel = parentPanel;
    qsc:populateContainer(queuedSkill);
    return qsc;
end

--v function(self: QUEUED_SKILL_CONTAINER) --> CONTAINER
function QueuedSkillContainer.getContainer(self)
    return self.container;
end

return {
    new = QueuedSkillContainer.new
}