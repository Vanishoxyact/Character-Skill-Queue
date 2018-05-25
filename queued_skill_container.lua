local QueuedSkillContainer = {} --# assume QueuedSkillContainer: QUEUED_SKILL_CONTAINER
QueuedSkillContainer.__index = QueuedSkillContainer;
QueuedSkillContainer.container = nil --: CONTAINER
QueuedSkillContainer.queuedSkill = nil --: QUEUED_SKILL
QueuedSkillContainer.parentPanel = nil --: CA_UIC

--v function(self: QUEUED_SKILL_CONTAINER, queuedSkill: QUEUED_SKILL, viewModel: SKILL_QUEUE_VIEW_MODEL)
function QueuedSkillContainer.populateContainer(self, queuedSkill, viewModel)
    local container = self.container;
    local skillName = queuedSkill.skill;
    local skillRank = queuedSkill.skillRank;
    local localizedname = effect.get_localised_string("character_skills_localised_name_" .. skillName);
    local skillNameText = Text.new("QueuedSkillContainerSkillName" .. queuedSkill.id, self.parentPanel, "NORMAL", localizedname .. skillRank);
    container:AddComponent(skillNameText);
    local charRankText = Text.new("QueuedSkillContainerCharRankText" .. queuedSkill.id, self.parentPanel, "NORMAL", tostring(queuedSkill.charRank));
    container:AddComponent(charRankText);
    local indexText = Text.new("QueuedSkillContainerIndexText" .. queuedSkill.id, self.parentPanel, "NORMAL", tostring(queuedSkill.index));
    container:AddComponent(indexText);
    local idText = Text.new("QueuedSkillContainerIdText" .. queuedSkill.id, self.parentPanel, "NORMAL", tostring(queuedSkill.id));
    container:AddComponent(idText);

    local buttonsContainer = Container.new(FlowLayout.HORIZONTAL);
    local moveUpButton = Button.new("QueuedSkillContainerMoveUpButton" .. queuedSkill.id, self.parentPanel, "CIRCULAR", "ui/skins/warhammer2/slider_vertical_top_active.png");
    moveUpButton:RegisterForClick(
        function(context)
            viewModel:moveQueuedSkillUp(queuedSkill.index);
        end
    );
    buttonsContainer:AddComponent(moveUpButton);

    local moveDownButton = Button.new("QueuedSkillContainerMoveDownButton" .. queuedSkill.id, self.parentPanel, "CIRCULAR", "ui/skins/warhammer2/slider_vertical_bottom_active.png");
    moveDownButton:RegisterForClick(
        function(context)
            viewModel:moveQueuedSkillDown(queuedSkill.index);
        end
    );
    buttonsContainer:AddComponent(moveDownButton);

    local removeButton = Button.new("QueuedSkillContainerRemoveButton" .. queuedSkill.id, self.parentPanel, "CIRCULAR", "ui/skins/default/advisor_beastmen_2d.png");
    removeButton:RegisterForClick(
        function(context)
            viewModel:removeQueuedSkill(queuedSkill.index);
        end
    );
    buttonsContainer:AddComponent(removeButton);
    container:AddComponent(buttonsContainer);

    queuedSkill:RegisterForEvent(
        "QUEUED_SKILL_INDEX_CHANGE",
        function()
            indexText:SetText(tostring(queuedSkill.index));
        end
    );
    queuedSkill:RegisterForEvent(
        "QUEUED_SKILL_CHAR_RANK_CHANGE",
        function()
            charRankText:SetText(tostring(queuedSkill.charRank));
        end
    );
    queuedSkill:RegisterForEvent(
        "QUEUED_SKILL_SKILL_RANK_CHANGE",
        function()
            skillNameText:SetText(tostring(localizedname .. queuedSkill.skillRank));
        end
    );
end

--v function(queuedSkill: QUEUED_SKILL, parentPanel: CA_UIC, viewModel: SKILL_QUEUE_VIEW_MODEL) --> QUEUED_SKILL_CONTAINER
function QueuedSkillContainer.new(queuedSkill, parentPanel, viewModel)
    local qsc = {};
    setmetatable(qsc, QueuedSkillContainer);
    --# assume qsc: QUEUED_SKILL_CONTAINER
    qsc.container = Container.new(FlowLayout.VERTICAL);
    qsc.queuedSkill = queuedSkill;
    qsc.parentPanel = parentPanel;
    qsc:populateContainer(queuedSkill, viewModel);
    return qsc;
end

--v function(self: QUEUED_SKILL_CONTAINER) --> CONTAINER
function QueuedSkillContainer.getContainer(self)
    return self.container;
end

return {
    new = QueuedSkillContainer.new
}