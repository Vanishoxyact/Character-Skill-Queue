my_load_mod_script("skill_queue_table_loading");
my_load_mod_script("skill_queue_util");
local SkillQueueManager = my_load_mod_script("skill_queue_manager");
local SkillQueueUi = my_load_mod_script("skill_queue_ui");
local currentUi = nil --: SKILL_QUEUE_UI
local skillQueueManager = nil --: SKILL_QUEUE_MANAGER

function startSkillQueue()
    out("Skill queue started");
    skillQueueManager = SkillQueueManager.new();
end

cm.first_tick_callbacks[#cm.first_tick_callbacks+1] = 
function(context)
   skillQueueLoadTables();
    startSkillQueue();
end

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
                   if not find_uicomponent(core:get_ui_root(), "character_details_panel") then
                      out("UI closed since char selected");
                      currentChar = nil;
                      return;
                   end
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
        end
       currentChar = nil;
    end, 
    true
);