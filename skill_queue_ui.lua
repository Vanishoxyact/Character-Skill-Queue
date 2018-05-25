local SkillQueueViewModel = require("skill_queue_view_model")
local QueuedSkillContainer = require("queued_skill_container")
local SkillQueueUi = {} --# assume SkillQueueUi: SKILL_QUEUE_UI
SkillQueueUi.__index = SkillQueueUi;
SkillQueueUi.viewModel = nil --: SKILL_QUEUE_VIEW_MODEL
SkillQueueUi.skillsPanel = nil --: CA_UIC
SkillQueueUi.skillQueuePanel = nil --: CONTAINER
SkillQueueUi.skillQueueButton = nil --: BUTTON
SkillQueueUi.queuedSkillToQueuedSkillContainer = {} --: map<QUEUED_SKILL, CONTAINER>

--v function(self: SKILL_QUEUE_UI)
function SkillQueueUi.panelClosed(self)
    self.viewModel:setQueueExpanded(false);
    self.skillQueueButton:Delete();
    self.skillQueuePanel:Clear();
end

--v function(self: SKILL_QUEUE_UI)
function SkillQueueUi.addSkillQueueButton(self)
    local skillQueueButton = Button.new("skillQueueButton", self.skillsPanel, "CIRCULAR_TOGGLE", "ui/skins/default/advisor_beastmen_2d.png");
    skillQueueButton:RegisterForClick(
        function(context)
            self.viewModel:setQueueExpanded(not self.viewModel.queueExpanded);
        end
    );
    self.skillQueueButton = skillQueueButton;
end

--v function(self: SKILL_QUEUE_UI)
function SkillQueueUi.resizeSkillList(self)
    local skillList = find_uicomponent(core:get_ui_root(), "character_details_panel", "background", "skills_subpanel", "listview");
    skillList:SetCanResizeHeight(true);
    skillList:SetCanResizeWidth(true);
    local skillListWidth = self.viewModel.skillListWidth;
    if not skillListWidth then
        output("Failed to resize skill list as skill list width not known.")
        return;
    end
    local w, h = skillList:Dimensions();
    if self.viewModel.queueExpanded then
        skillList:Resize(skillListWidth - self.viewModel.skillQueueWidth, h);
    else
        skillList:Resize(skillListWidth, h);
    end
end

--v function(self: SKILL_QUEUE_UI)
function SkillQueueUi.updateSkillQueuePanel(self)
    local skillQueuePanel = self.skillQueuePanel;
    if skillQueuePanel:Visible() ~= self.viewModel.queueExpanded then
        skillQueuePanel:SetVisible(self.viewModel.queueExpanded);
    end
    if not self.viewModel.queueExpanded then
        return;
    end
    skillQueuePanel:Reposition();
end

--v function(self: SKILL_QUEUE_UI) --> map<QUEUED_SKILL, CONTAINER>
function SkillQueueUi.calculateMissingSkillQueueContainers(self)
    local missingSkillQueueContrainers = {} --: map<QUEUED_SKILL, CONTAINER>
    for queuedSkill, container in pairs(self.queuedSkillToQueuedSkillContainer) do
        if not listContains(self.viewModel.queuedSkills, queuedSkill) then
            missingSkillQueueContrainers[queuedSkill] = container;
        end
    end
    return missingSkillQueueContrainers;
end

--v function(self: SKILL_QUEUE_UI, queuedSkillsContainer: CONTAINER)
function SkillQueueUi.updateQueuedSkillPanel(self, queuedSkillsContainer)
    queuedSkillsContainer.components = {};
    for i, queuedSkill in ipairs(self.viewModel.queuedSkills) do
        local queuedSkillContainer = self.queuedSkillToQueuedSkillContainer[queuedSkill];
        if not queuedSkillContainer then
            queuedSkillContainer = QueuedSkillContainer.new(queuedSkill, self.skillsPanel, self.viewModel):getContainer();
            self.queuedSkillToQueuedSkillContainer[queuedSkill] = queuedSkillContainer;
        end
        queuedSkillsContainer:AddComponent(queuedSkillContainer);
    end
    local missingSkillQueueContrainers = self:calculateMissingSkillQueueContainers();
    for queuedSkill, missingSkillQueueContainer in pairs(missingSkillQueueContrainers) do
        missingSkillQueueContainer:Clear();
        self.queuedSkillToQueuedSkillContainer[queuedSkill] = nil;
    end
    queuedSkillsContainer:Reposition();
end

--v function(self: SKILL_QUEUE_UI) --> CONTAINER
function SkillQueueUi.createQueuedSkillsPanel(self)
    local queuedSkillsContainer = Container.new(FlowLayout.VERTICAL);
    self.viewModel:RegisterForEvent(
        "SKILL_QUEUE_UPDATED",
        function()
            self:updateQueuedSkillPanel(queuedSkillsContainer);
        end
    )
    self:updateQueuedSkillPanel(queuedSkillsContainer);
    return queuedSkillsContainer;
end

--v function(self: SKILL_QUEUE_UI)
function SkillQueueUi.createSkillQueuePanel(self)
    local skillQueuePanel = Container.new(FlowLayout.VERTICAL);
    local title = Text.new("skillQueuePanelTitle", self.skillsPanel, "HEADER", "Skill Queue");
    skillQueuePanel:AddComponent(title);
    local queuedSkillsPanel = self:createQueuedSkillsPanel();
    skillQueuePanel:AddComponent(queuedSkillsPanel);
    skillQueuePanel:SetVisible(false);
    local skillList = find_uicomponent(core:get_ui_root(), "character_details_panel", "background", "skills_subpanel", "listview");
    skillQueuePanel:PositionRelativeTo(skillList, skillList:Bounds() - self.viewModel.skillQueueWidth, 0);
    self.skillQueuePanel = skillQueuePanel;
end

--v function(self: SKILL_QUEUE_UI)
function SkillQueueUi.setUpRegistrations(self)
    self.viewModel:RegisterForEvent(
        "QUEUE_EXPANDED_CHANGE",
        function()
            self:resizeSkillList();
            self:updateSkillQueuePanel();
        end
    );
end

--v function(characterSkillQueue: CHARACTER_SKILL_QUEUE) --> SKILL_QUEUE_UI
function SkillQueueUi.new(characterSkillQueue)
    local squi = {};
    setmetatable(squi, SkillQueueUi);
    --# assume squi: SKILL_QUEUE_UI
    squi.viewModel = SkillQueueViewModel.new(characterSkillQueue);
    squi.queuedSkillToQueuedSkillContainer = {};
    squi.skillsPanel = find_uicomponent(core:get_ui_root(), "character_details_panel", "background", "skills_subpanel");
    squi:setUpRegistrations();
    squi:addSkillQueueButton();
    squi:createSkillQueuePanel();
    return squi;
end

return {
    new = SkillQueueUi.new
}