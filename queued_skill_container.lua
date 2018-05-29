local QueuedSkillContainer = {} --# assume QueuedSkillContainer: QUEUED_SKILL_CONTAINER
QueuedSkillContainer.__index = QueuedSkillContainer;
QueuedSkillContainer.container = nil --: CONTAINER
QueuedSkillContainer.queuedSkill = nil --: QUEUED_SKILL
QueuedSkillContainer.parentPanel = nil --: CA_UIC

--v function(self: QUEUED_SKILL_CONTAINER) --> CONTAINER
function QueuedSkillContainer.createCharacterRankContainer(self)
    local queuedSkill = self.queuedSkill;
    local characterRankContainer = Container.new(FlowLayout.VERTICAL);
    local characterRankFrame = Image.new("QueuedSkillContainercharacterRankFrame" .. queuedSkill.id, self.parentPanel, "ui/skins/warhammer2/rank_dspl_frame.png");
    characterRankFrame:Resize(50, 50);
    characterRankContainer:AddComponent(characterRankFrame);
    characterRankContainer:AddGap(characterRankFrame:Height() / 2 * -1 - 7);

    local characterRankNumberContainer = Container.new(FlowLayout.HORIZONTAL);
    characterRankNumberContainer:AddGap(characterRankFrame:Width() / 2 - 10)
    if queuedSkill.charRank < 10 then
        characterRankNumberContainer:AddGap(3);
    end
    local characterRankNumber = Text.new("QueuedSkillContainercharacterRankNumber" .. queuedSkill.id, self.parentPanel, "NORMAL", tostring(queuedSkill.charRank));
    characterRankNumberContainer:AddComponent(characterRankNumber);
    characterRankContainer:AddComponent(characterRankNumberContainer);
    characterRankContainer:AddGap(characterRankFrame:Height() / 2);

    queuedSkill:RegisterForEvent(
        "QUEUED_SKILL_CHAR_RANK_CHANGE",
        function()
            characterRankNumber:SetText(tostring(queuedSkill.charRank));
        end
    );
    return characterRankContainer;
end

--v function(self: QUEUED_SKILL_CONTAINER, queuedSkill: QUEUED_SKILL, viewModel: SKILL_QUEUE_VIEW_MODEL)
function QueuedSkillContainer.populateContainer(self, queuedSkill, viewModel)
    local container = self.container;
    local skillName = queuedSkill.skill;
    local skillRank = queuedSkill.skillRank;
    local localizedname = effect.get_localised_string("character_skills_localised_name_" .. skillName);
    local skillNameText = Text.new("QueuedSkillContainerSkillName" .. queuedSkill.id, self.parentPanel, "NORMAL", localizedname .. skillRank);
    container:AddComponent(skillNameText);
    --local charRankText = Text.new("QueuedSkillContainerCharRankText" .. queuedSkill.id, self.parentPanel, "NORMAL", tostring(queuedSkill.charRank));
    --container:AddComponent(charRankText);
    --local indexText = Text.new("QueuedSkillContainerIndexText" .. queuedSkill.id, self.parentPanel, "NORMAL", tostring(queuedSkill.index));
    --container:AddComponent(indexText);
    --local idText = Text.new("QueuedSkillContainerIdText" .. queuedSkill.id, self.parentPanel, "NORMAL", tostring(queuedSkill.id));
    --container:AddComponent(idText);

    local characterRankContainer = self:createCharacterRankContainer();
    container:AddComponent(characterRankContainer);

    local buttonsContainer = Container.new(FlowLayout.HORIZONTAL);
    local moveUpButton = Button.new("QueuedSkillContainerMoveUpButton" .. queuedSkill.id, self.parentPanel, "SQUARE", "ui/skins/warhammer2/icon_toggle_vertical_panel_flipped.png");
    moveUpButton:Resize(25, 25);
    moveUpButton:RegisterForClick(
        function(context)
            viewModel:moveQueuedSkillUp(queuedSkill.index);
        end
    );
    buttonsContainer:AddComponent(moveUpButton);

    local moveDownButton = Button.new("QueuedSkillContainerMoveDownButton" .. queuedSkill.id, self.parentPanel, "SQUARE", "ui/skins/warhammer2/icon_toggle_vertical_panel.png");
    moveDownButton:Resize(25, 25);
    moveDownButton:RegisterForClick(
        function(context)
            viewModel:moveQueuedSkillDown(queuedSkill.index);
        end
    );
    buttonsContainer:AddComponent(moveDownButton);

    local removeButton = Button.new("QueuedSkillContainerRemoveButton" .. queuedSkill.id, self.parentPanel, "SQUARE", "ui/skins/warhammer2/icon_cross.png");
    removeButton:Resize(25, 25);
    removeButton:RegisterForClick(
        function(context)
            viewModel:removeQueuedSkill(queuedSkill.index);
        end
    );
    buttonsContainer:AddComponent(removeButton);
    container:AddComponent(buttonsContainer);

    local queuedSkillContainerDivider = Image.new("QueuedSkillContainerDivider" .. queuedSkill.id, self.parentPanel, "ui/skins/default/separator_line.png");
    queuedSkillContainerDivider:Resize(200, 2);
    container:AddComponent(queuedSkillContainerDivider);


    -- queuedSkill:RegisterForEvent(
    --     "QUEUED_SKILL_INDEX_CHANGE",
    --     function()
    --         indexText:SetText(tostring(queuedSkill.index));
    --     end
    -- );
    -- queuedSkill:RegisterForEvent(
    --     "QUEUED_SKILL_CHAR_RANK_CHANGE",
    --     function()
    --         charRankText:SetText(tostring(queuedSkill.charRank));
    --     end
    -- );
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