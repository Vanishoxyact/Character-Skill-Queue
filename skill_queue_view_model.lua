local EventManager = require("event_manager");
local QueuedSkill = require("queued_skill");
local SkillQueueViewModel = {} --# assume SkillQueueViewModel: SKILL_QUEUE_VIEW_MODEL
SkillQueueViewModel.__index = SkillQueueViewModel;
SkillQueueViewModel.eventManager = nil --: EVENT_MANAGER
SkillQueueViewModel.skillListWidth = nil --: number
SkillQueueViewModel.queueExpanded = false --: boolean
SkillQueueViewModel.skillQueueWidth = 200;
SkillQueueViewModel.characterSkillQueue = nil --: CHARACTER_SKILL_QUEUE
SkillQueueViewModel.queuedSkills = {} --: vector<QUEUED_SKILL>

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
    return queuedSkill;
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, characterSkillQueue: CHARACTER_SKILL_QUEUE)
function SkillQueueViewModel.createQueuedSkills(self, characterSkillQueue)
    local queuedSkills = characterSkillQueue:getAllSkills();
    for i, skill in ipairs(queuedSkills) do
        queuedSkill = self:createQueuedSkill(skill);
        table.insert(self.queuedSkills, queuedSkill);
    end
end

--v function(characterSkillQueue: CHARACTER_SKILL_QUEUE) --> SKILL_QUEUE_VIEW_MODEL
function SkillQueueViewModel.new(characterSkillQueue)
    local sqvm = {};
    setmetatable(sqvm, SkillQueueViewModel);
    --# assume sqvm: SKILL_QUEUE_VIEW_MODEL
    sqvm.eventManager = EventManager.new();
    sqvm.queueExpanded = false;
    sqvm.characterSkillQueue = characterSkillQueue;
    sqvm:setupSkillListWidth();
    sqvm:createQueuedSkills(characterSkillQueue);
    return sqvm;
end

return {
    new = SkillQueueViewModel.new
}