local EventManager = require("event_manager");
local SkillQueueViewModel = {} --# assume SkillQueueViewModel: SKILL_QUEUE_VIEW_MODEL
SkillQueueViewModel.__index = SkillQueueViewModel;
SkillQueueViewModel.eventManager = nil --: EVENT_MANAGER
SkillQueueViewModel.skillListWidth = nil --: number
SkillQueueViewModel.queueExpanded = false --: boolean
SkillQueueViewModel.skillQueueWidth = 200;

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

--v function() --> SKILL_QUEUE_VIEW_MODEL
function SkillQueueViewModel.new()
    local sqvm = {};
    setmetatable(sqvm, SkillQueueViewModel);
    --# assume sqvm: SKILL_QUEUE_VIEW_MODEL
    sqvm.eventManager = EventManager.new();
    sqvm.queueExpanded = false;
    sqvm:setupSkillListWidth();
    return sqvm;
end

return {
    new = SkillQueueViewModel.new
}