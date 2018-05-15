local EventManager = require("event_manager");
local QueuedSkill = require("queued_skill");
local SkillQueueViewModel = {} --# assume SkillQueueViewModel: SKILL_QUEUE_VIEW_MODEL
SkillQueueViewModel.__index = SkillQueueViewModel;
SkillQueueViewModel.skillQueueWidth = 200;

SkillQueueViewModel.eventManager = nil --: EVENT_MANAGER
SkillQueueViewModel.skillListWidth = nil --: number
SkillQueueViewModel.queueExpanded = false --: boolean
SkillQueueViewModel.characterSkillQueue = nil --: CHARACTER_SKILL_QUEUE
SkillQueueViewModel.queuedSkills = {} --: vector<QUEUED_SKILL>
SkillQueueViewModel.currentSkillLevel = {} --: map<string, int>

--v function(self: SKILL_QUEUE_VIEW_MODEL, eventType: SKILL_QUEUE_EVENT, callback: function())
function SkillQueueViewModel.RegisterForEvent(self, eventType, callback)
    self.eventManager:RegisterForEvent(eventType, callback);
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, expanded: boolean)
function SkillQueueViewModel.setQueueExpanded(self, expanded)
    self.queueExpanded = expanded;
    self.eventManager:NotifyEvent("QUEUE_EXPANDED_CHANGE");
end

--v function(self: SKILL_QUEUE_VIEW_MODEL)
function SkillQueueViewModel.setupSkillListWidth(self)
    local skillList = find_uicomponent(core:get_ui_root(), "character_details_panel", "background", "skills_subpanel", "listview");
    local w, h = skillList:Dimensions();
    self.skillListWidth = w;
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, skill: string) --> QUEUED_SKILL
function SkillQueueViewModel.createQueuedSkill(self, skill)
    local queuedSkill = QueuedSkill.new(skill);
    queuedSkill.skillRank = self.currentSkillLevel[skill] + 1
    return queuedSkill;
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, skill: string) --> (int, int)
function SkillQueueViewModel.detectSkillLevels(self, skill)
    local skillList = find_uicomponent(core:get_ui_root(), "character_details_panel", "background", "skills_subpanel", "listview");
    local skillNode = find_uicomponent(skillList, skill);
    if not skillNode then
        output("Failed to find skill node: " ..  skill);
        return 0, 0;
    end
    local skillLevelParent = find_uicomponent(skillNode, "card", "level_parent");
    local level1 = find_uicomponent(skillLevelParent, "level1");
    local currentLevel = 0;
    local maxLevel = 0;
    -- active, inactive, locked
    local activeSkill = "active";
    if level1:Visible() then
        maxLevel = 1;
        if level1:CurrentState() == activeSkill then
            currentLevel = 1;
        end
    end
    local level2 = find_uicomponent(skillLevelParent, "level2");
    if level2:Visible() then
        maxLevel = 2;
        if level2:CurrentState() == activeSkill then
            currentLevel = 2;
        end
    end
    local level3 = find_uicomponent(skillLevelParent, "level3");
    if level3:Visible() then
        maxLevel = 3;
        if level3:CurrentState() == activeSkill then
            currentLevel = 3;
        end
    end
    output("Skill max level: " .. skill .. maxLevel);
    output("Current level: " .. skill .. currentLevel);
    return currentLevel, maxLevel;
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, characterSkillQueue: CHARACTER_SKILL_QUEUE)
function SkillQueueViewModel.createQueuedSkills(self, characterSkillQueue)
    local queuedSkills = characterSkillQueue:getAllSkills();
    for i, skill in ipairs(queuedSkills) do
        local currentLevel, maxLevel = self:detectSkillLevels(skill);
        if not self.currentSkillLevel[skill] then
            self.currentSkillLevel[skill] = currentLevel;
        end
        queuedSkill = self:createQueuedSkill(skill);
        table.insert(self.queuedSkills, queuedSkill);
        self.currentSkillLevel[skill] = currentLevel + 1;
    end
end

--v function(characterSkillQueue: CHARACTER_SKILL_QUEUE) --> SKILL_QUEUE_VIEW_MODEL
function SkillQueueViewModel.new(characterSkillQueue)
    local sqvm = {};
    setmetatable(sqvm, SkillQueueViewModel);
    --# assume sqvm: SKILL_QUEUE_VIEW_MODEL
    sqvm.eventManager = EventManager.new();
    sqvm.skillListWidth = nil
    sqvm.queueExpanded = false;
    sqvm.characterSkillQueue = characterSkillQueue;
    sqvm.queuedSkills = {};
    sqvm.currentSkillLevel = {};
    
    sqvm:setupSkillListWidth();
    sqvm:createQueuedSkills(characterSkillQueue);
    return sqvm;
end

return {
    new = SkillQueueViewModel.new
}