local QueuedSkillContainer = {} --# assume QueuedSkillContainer: QUEUED_SKILL_CONTAINER
QueuedSkillContainer.__index = QueuedSkillContainer;
QueuedSkillContainer.container = nil --: CONTAINER
QueuedSkillContainer.queuedSkill = nil --: QUEUED_SKILL
QueuedSkillContainer.viewModel = nil --: SKILL_QUEUE_VIEW_MODEL
QueuedSkillContainer.parentPanel = nil --: CA_UIC

--v function(self: QUEUED_SKILL_CONTAINER) --> CONTAINER
function QueuedSkillContainer.createSkillNameContainer(self)
    local queuedSkill = self.queuedSkill;
    local skillNameContainer = Container.new(FlowLayout.HORIZONTAL);
    local skillName = queuedSkill.skill;
    local skillRank = queuedSkill.skillRank;
    local localizedname = effect.get_localised_string("character_skills_localised_name_" .. skillName);
    local skillNameText = Text.new("QueuedSkillContainerSkillName" .. queuedSkill.id, self.parentPanel, "NORMAL", localizedname);
    skillNameContainer:AddComponent(skillNameText);
    return skillNameContainer;
end

--v function(self: QUEUED_SKILL_CONTAINER) --> CONTAINER
function QueuedSkillContainer.createCharacterRankContainer(self)
    local queuedSkill = self.queuedSkill;
    local characterRankContainer = Container.new(FlowLayout.VERTICAL);
    local characterRankFrame = Image.new("QueuedSkillContainercharacterRankFrame" .. queuedSkill.id, self.parentPanel, "ui/skins/warhammer2/rank_dspl_frame.png");
    characterRankFrame:Resize(30, 30);
    characterRankContainer:AddComponent(characterRankFrame);

    local rankString = tostring(queuedSkill.charRank);
    if queuedSkill.charRank < 10 then
        rankString = " " .. rankString;
    end
    local characterRankNumber = Text.new("QueuedSkillContainercharacterRankNumber" .. queuedSkill.id, self.parentPanel, "NORMAL", rankString);
    characterRankNumber:Resize(10, 10);

    local textOffsetFromTop = characterRankFrame:Height() /2 - characterRankNumber:Height() / 2;
    characterRankContainer:AddGap((characterRankFrame:Height() * -1) + textOffsetFromTop);

    local characterRankNumberContainer = Container.new(FlowLayout.HORIZONTAL);
    characterRankNumberContainer:AddGap(characterRankFrame:Width() / 2 - characterRankNumber:Width() / 2)
    characterRankNumberContainer:AddComponent(characterRankNumber);

    characterRankContainer:AddComponent(characterRankNumberContainer);
    characterRankContainer:AddGap(characterRankFrame:Height() / 2);

    queuedSkill:RegisterForEvent(
        "QUEUED_SKILL_CHAR_RANK_CHANGE",
        function()
            local rankString = tostring(queuedSkill.charRank);
            if queuedSkill.charRank < 10 then
                rankString = " " .. rankString;
            end
            characterRankNumber:SetText(rankString);
        end
    );
    return characterRankContainer;
end

--v function(self: QUEUED_SKILL_CONTAINER) --> CONTAINER
function QueuedSkillContainer.createButtonsContainer(self)
    local queuedSkill = self.queuedSkill;
    local viewModel = self.viewModel;
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
    return buttonsContainer;
end

--v function(self: QUEUED_SKILL_CONTAINER, skillRankContainer: CONTAINER)
function QueuedSkillContainer.updateSkillRankContainer(self, skillRankContainer)
    local rankIcons = skillRankContainer:RecursiveRetrieveAllComponents();
    for i, rankIcon in ipairs(rankIcons) do
        --# assume rankIcon: IMAGE
        if i <= self.queuedSkill.skillRank then
            rankIcon:SetVisible(true);
        else
            rankIcon:SetVisible(false);
        end
    end
end

--v function(self: QUEUED_SKILL_CONTAINER) --> CONTAINER
function QueuedSkillContainer.createSkillRankContainer(self)
    local queuedSkill = self.queuedSkill;
    local skillRankContainer = Container.new(FlowLayout.VERTICAL);
    local maxRank = self.viewModel.maxSkillLevel[queuedSkill.skill];
    for i=0, maxRank do
        local rankIcon = Image.new("QueuedSkillRankIcon" .. i .. queuedSkill.id, self.parentPanel, "ui/skins/warhammer2/skills_tab_level_off.png");
        rankIcon:Resize(10, 10);
        skillRankContainer:AddComponent(rankIcon);
    end
    self:updateSkillRankContainer(skillRankContainer);
    queuedSkill:RegisterForEvent(
        "QUEUED_SKILL_SKILL_RANK_CHANGE",
        function()
            self:updateSkillRankContainer(skillRankContainer);
        end
    );
    return skillRankContainer;
end

--v function(self: QUEUED_SKILL_CONTAINER, queuedSkill: QUEUED_SKILL, viewModel: SKILL_QUEUE_VIEW_MODEL)
function QueuedSkillContainer.populateContainer(self, queuedSkill, viewModel)
    local container = self.container;
    local rowContainer = Container.new(FlowLayout.HORIZONTAL);
    container:AddComponent(rowContainer);

    local characterRankContainer = self:createCharacterRankContainer();
    rowContainer:AddComponent(characterRankContainer);

    local skillNameContainer = self:createSkillNameContainer();
    rowContainer:AddComponent(skillNameContainer);

    local skillRankContainer = self:createSkillRankContainer();
    rowContainer:AddComponent(skillRankContainer);

    local buttonsContainer = self:createButtonsContainer();
    rowContainer:AddComponent(buttonsContainer);

    local queuedSkillContainerDivider = Image.new("QueuedSkillContainerDivider" .. queuedSkill.id, self.parentPanel, "ui/skins/default/separator_line.png");
    queuedSkillContainerDivider:Resize(viewModel.skillQueueWidth, 2);
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
    -- queuedSkill:RegisterForEvent(
    --     "QUEUED_SKILL_SKILL_RANK_CHANGE",
    --     function()
    --         skillNameText:SetText(tostring(localizedname .. queuedSkill.skillRank));
    --     end
    -- );
end

--v function(queuedSkill: QUEUED_SKILL, parentPanel: CA_UIC, viewModel: SKILL_QUEUE_VIEW_MODEL) --> QUEUED_SKILL_CONTAINER
function QueuedSkillContainer.new(queuedSkill, parentPanel, viewModel)
    local qsc = {};
    setmetatable(qsc, QueuedSkillContainer);
    --# assume qsc: QUEUED_SKILL_CONTAINER
    qsc.container = Container.new(FlowLayout.VERTICAL);
    qsc.queuedSkill = queuedSkill;
    qsc.viewModel = viewModel;
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