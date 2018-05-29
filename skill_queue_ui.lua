local SkillQueueViewModel = require("skill_queue_view_model")
local QueuedSkillContainer = require("queued_skill_container")
local SkillValidator = require("skill_validator")
local SkillQueuer = require("skill_queuer")
local SkillQueueUi = {} --# assume SkillQueueUi: SKILL_QUEUE_UI
SkillQueueUi.__index = SkillQueueUi;
SkillQueueUi.viewModel = nil --: SKILL_QUEUE_VIEW_MODEL
SkillQueueUi.skillQueuer = nil --: SKILL_QUEUER
SkillQueueUi.skillsPanel = nil --: CA_UIC
SkillQueueUi.skillQueuePanel = nil --: CONTAINER
SkillQueueUi.skillQueueButton = nil --: TEXT_BUTTON
SkillQueueUi.skillQueuerButton = nil --: TEXT_BUTTON
SkillQueueUi.queuedSkillToQueuedSkillContainer = {} --: map<QUEUED_SKILL, CONTAINER>
SkillQueueUi.markedSkills = {} --: vector<CA_UIC>

--v function(self: SKILL_QUEUE_UI, switched: boolean)
function SkillQueueUi.panelClosed(self, switched)
    self.skillQueueButton:Delete();
    self.skillQueuePanel:Clear();
    if not switched then
        self.skillQueuer:resetSkillHighlights();
    else
        core:remove_listener("SkillCardClickListener");
    end
    self.skillQueuer:resetDefaultStates();
    self.viewModel:setQueueExpanded(false);
end

--v function(self: SKILL_QUEUE_UI)
function SkillQueueUi.addSkillQueueButton(self)
    local skillQueueButton = TextButton.new("skillQueueButton", self.skillsPanel, "TEXT_TOGGLE_SMALL", "Queue Skills");
    skillQueueButton:Resize(200, skillQueueButton:Height());
    local statsResetHolder = find_uicomponent(self.skillsPanel, "stats_reset_holder");
    local x, y = statsResetHolder:Position();
    local w, h = statsResetHolder:Bounds();
    local skillList = find_uicomponent(core:get_ui_root(), "character_details_panel", "background", "skills_subpanel", "listview");
    skillQueueButton:PositionRelativeTo(skillList, skillList:Bounds() - skillQueueButton:Width(), 0);
    skillQueueButton:MoveTo(skillQueueButton:XPos(), y + h );
    skillQueueButton:RegisterForClick(
        function(context)
            self.viewModel:setQueueExpanded(not self.viewModel.queueExpanded);
        end
    );
    self.skillQueueButton = skillQueueButton;
end

--v function(self: SKILL_QUEUE_UI)
function SkillQueueUi.addSkillQueuerButton(self)
    local skillQueuerButton = TextButton.new("skillQueuerButton", self.skillsPanel, "TEXT_TOGGLE_SMALL", "Select skills...");
    skillQueuerButton:Resize(200, skillQueuerButton:Height());
    skillQueuerButton:RegisterForClick(
        function(context)
            if not skillQueuerButton:IsSelected() then
                self.skillQueuer:highightQueueableSkills();
            else
                self.skillQueuer:resetSkillHighlights();
            end
        end
    );
    skillQueuerButton:SetVisible(false);
    self.skillQueuePanel:AddComponent(skillQueuerButton);
    self.skillQueuerButton = skillQueuerButton;
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
        self.skillQueuer:resetSkillHighlights();
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

--v function(self: SKILL_QUEUE_UI)
function SkillQueueUi.markSelectedSkills(self)
    for i, markedSkill in ipairs(self.markedSkills) do
        markedSkill:SetState("locked");
        markedSkill:SetOpacity(255);
    end
    self.markedSkills = {};
    if self.viewModel.queueExpanded then
        local queuedSkills = self.viewModel.queuedSkills;
        for i, queuedSkill in ipairs(queuedSkills) do
            local skillRankUic = self.viewModel:getUicForSkillRank(queuedSkill.skill, queuedSkill.skillRank);
            skillRankUic:SetState("active");
            skillRankUic:SetOpacity(150);
            table.insert(self.markedSkills, skillRankUic);
        end
    end
end

--v function(self: SKILL_QUEUE_UI) --> CONTAINER
function SkillQueueUi.createQueuedSkillsPanel(self)
    local queuedSkillsContainer = Container.new(FlowLayout.VERTICAL);
    self.viewModel:RegisterForEvent(
        "SKILL_QUEUE_UPDATED",
        function()
            self:updateQueuedSkillPanel(queuedSkillsContainer);
            self.skillQueuePanel:Reposition();
            self:markSelectedSkills();
        end
    )
    self:updateQueuedSkillPanel(queuedSkillsContainer);
    return queuedSkillsContainer;
end

--v function(self: SKILL_QUEUE_UI)
function SkillQueueUi.createSkillQueuePanel(self)
    local skillQueuePanel = Container.new(FlowLayout.VERTICAL);
    skillQueuePanel:AddGap(20);
    local skillQueuePanelDivider = Image.new("skillQueuePanelDivider", self.skillsPanel, "ui/skins/default/separator_line.png");
    skillQueuePanelDivider:Resize(200, 2);
    skillQueuePanel:AddComponent(skillQueuePanelDivider);

    local skillList = find_uicomponent(core:get_ui_root(), "character_details_panel", "background", "skills_subpanel", "listview");
    local skillListW, skillListH = skillList:Bounds();
    local outerPanel = Container.new(FlowLayout.HORIZONTAL);
    local skillQueuePanelSideDivider = Image.new("skillQueuePanelSideDivider", self.skillsPanel, "ui/skins/default/separator_line.png");
    skillQueuePanelSideDivider:Resize(4, skillListH -  50);
    outerPanel:AddComponent(skillQueuePanelSideDivider);
    local queuedSkillsPanel = self:createQueuedSkillsPanel();
    outerPanel:AddComponent(queuedSkillsPanel);
    skillQueuePanel:AddComponent(outerPanel);

    skillQueuePanel:SetVisible(false);
    skillQueuePanel:PositionRelativeTo(skillList, skillListW - self.viewModel.skillQueueWidth, 0);
    self.skillQueuePanel = skillQueuePanel;
    self:updateSkillQueuePanel();
end

--v function(self: SKILL_QUEUE_UI)
function SkillQueueUi.setUpRegistrations(self)
    self.viewModel:RegisterForEvent(
        "QUEUE_EXPANDED_CHANGE",
        function()
            self:resizeSkillList();
            self:updateSkillQueuePanel();
            self.skillQueuerButton:SetState("active");
            self:markSelectedSkills();
        end
    );
end

--v function(characterSkillQueue: CHARACTER_SKILL_QUEUE) --> SKILL_QUEUE_UI
function SkillQueueUi.new(characterSkillQueue)
    output("SkillQueueUi init");
    local squi = {};
    setmetatable(squi, SkillQueueUi);
    --# assume squi: SKILL_QUEUE_UI
    squi.viewModel = SkillQueueViewModel.new(characterSkillQueue);
    squi.markedSkills = {};
    squi.skillQueuer = SkillQueuer.new(
        function(skill) 
            squi.viewModel:queueSkill(skill);
        end, SkillValidator.new(squi.viewModel)
    );
    squi.queuedSkillToQueuedSkillContainer = {};
    squi.skillsPanel = find_uicomponent(core:get_ui_root(), "character_details_panel", "background", "skills_subpanel");
    squi:setUpRegistrations();
    squi:addSkillQueueButton();
    squi:createSkillQueuePanel();
    squi:addSkillQueuerButton();
    return squi;
end

return {
    new = SkillQueueUi.new
}