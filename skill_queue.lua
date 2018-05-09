require("skill_queue_util");
local SkillQueueManager = require("skill_queue_manager");
local SkillQueueUi = require("skill_queue_ui");
local currentUi = nil --: SKILL_QUEUE_UI

function startSkillQueue()
    output("Skill queue started");
    local skillQueueManager = SkillQueueManager.new();
    local testCqi = 31;
    --# assume testCqi: CA_CQI
    local testQueue = skillQueueManager.model:createCharacterSkillQueue(get_character_by_cqi(testCqi));
    testQueue:addSkillToQueue("wh2_main_skill_hef_noble_unique_combat");
    testQueue:addSkillToQueue("wh2_main_skill_hef_combat_valour_of_ages");
    testQueue:addSkillToQueue("wh2_main_skill_hef_combat_valour_of_ages");
    testQueue:addSkillToQueue("wh_main_skill_all_all_self_hard_to_hit");
end

core:add_listener(
    "SkillQueueStartListener",
    "FirstTickAfterWorldCreated",
    function(context)
        return true;
    end,
    function(context)
        startSkillQueue();
    end,
    true
);

core:add_listener(
    "SkillQueuePanelListener",
    "PanelOpenedCampaign",
    function(context) 
        return context.string == "character_details_panel"; 
    end,
    function(context)
        output("Init skill queue");
        if not currentUi then
            currentUi = SkillQueueUi.new();
        end
    end, 
    true
);

core:add_listener(
    "SkillQueuePanelListener",
    "PanelClosedCampaign",
    function(context) 
        return context.string == "character_details_panel"; 
    end,
    function(context)
        currentUi:panelClosed();
        currentUi = nil;
    end, 
    true
);