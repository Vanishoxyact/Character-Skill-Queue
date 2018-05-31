require("skill_queue_util");
local SkillQueueManager = require("skill_queue_manager");
local SkillQueueUi = require("skill_queue_ui");
local currentUi = nil --: SKILL_QUEUE_UI
local skillQueueManager = nil --: SKILL_QUEUE_MANAGER

function startSkillQueue()
    out("Skill queue started");
    skillQueueManager = SkillQueueManager.new();
    -- local testCqi = 31;
    -- --# assume testCqi: CA_CQI
    -- local testQueue = skillQueueManager.model:createCharacterSkillQueue(cm:get_character_by_cqi(testCqi));
    -- testQueue:addSkillToQueue("wh2_main_skill_hef_noble_unique_combat");
    -- testQueue:addSkillToQueue("wh2_main_skill_hef_combat_valour_of_ages");
    -- testQueue:addSkillToQueue("wh2_main_skill_hef_combat_valour_of_ages");
    -- testQueue:addSkillToQueue("wh_main_skill_all_all_self_hard_to_hit");
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

-- core:add_listener(
--     "SkillQueuePanelListener",
--     "PanelOpenedCampaign",
--     function(context) 
--         return context.string == "character_details_panel"; 
--     end,
--     function(context)
--         cm:callback(
--             function()
--                 out("Init skill queue");
--                 if not currentUi then
--                     local testCqi = 31;
--                     --# assume testCqi: CA_CQI
--                     currentUi = SkillQueueUi.new(skillQueueManager.model:getSkillQueueForCharacter(cm:get_character_by_cqi(testCqi)));
--                 end
--             end, 0, "SkillQueueUiCreator"
--         )
--     end, 
--     true
-- );

-- core:add_listener(
--     "SkillQueueCharacterSelectedListener",
--     "CharacterSelected",
--     function(context) 
--         return true;
--     end,
--     function(context)
--         if currentUi then
--             currentUi:panelClosed();
--             local testCqi = 31;
--             --# assume testCqi: CA_CQI
--             currentUi = SkillQueueUi.new(skillQueueManager.model:getSkillQueueForCharacter(cm:get_character_by_cqi(testCqi)));
--         end
--     end, 
--     true
-- );

local currentChar = nil --: CA_CHAR

applyFunctionWhenCharSelected(
    function(selectedChar)
        if selectedChar == currentChar then
            return;
        end
        if not find_uicomponent(core:get_ui_root(), "character_details_panel") then
            return;
        end
        currentChar = selectedChar;
        if not currentUi then
            cm:callback(
                function()
                    out("Init skill queue");
                    currentUi = SkillQueueUi.new(skillQueueManager.model:getOrCreateCharacterSkillQueue(selectedChar));
                end, 0, "SkillQueueUiCreator"
            );
        else
            currentUi:panelClosed(true);
            currentUi = SkillQueueUi.new(skillQueueManager.model:getOrCreateCharacterSkillQueue(selectedChar));
        end
    end
);

core:add_listener(
    "SkillQueuePanelListener",
    "PanelClosedCampaign",
    function(context) 
        return context.string == "character_details_panel"; 
    end,
    function(context)
        if currentUi then
            currentUi:panelClosed(false);
            currentUi = nil;
            currentChar = nil;
        end
    end, 
    true
);