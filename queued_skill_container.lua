local QueuedSkillContainer = {} --# assume QueuedSkillContainer: QUEUED_SKILL_CONTAINER
QueuedSkillContainer.__index = QueuedSkillContainer;
QueuedSkillContainer.container = nil --: CONTAINER
QueuedSkillContainer.queuedSkill = nil --: QUEUED_SKILL
QueuedSkillContainer.parentPanel = nil --: CA_UIC

--v function(self: QUEUED_SKILL_CONTAINER, queuedSkill: QUEUED_SKILL)
function QueuedSkillContainer.populateContainer(self, queuedSkill)
    local container = self.container;
    local skillName = queuedSkill.skill;
    local skillRank = queuedSkill.skillRank;
    local localizedname = effect.get_localised_string("character_skills_localised_name_" .. skillName);
    local skillNameText = Text.new("QueuedSkillContainer" .. skillName .. skillRank, self.parentPanel, "NORMAL", localizedname .. skillRank);
    container:AddComponent(skillNameText);
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