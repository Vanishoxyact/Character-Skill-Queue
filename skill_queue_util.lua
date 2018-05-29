--v function() --> number
function calculateIndexOfSelectedAgent()
    local unitsList = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "units");
    for i=0, unitsList:ChildCount()-1  do
        local child = UIComponent(unitsList:Find(i));
        local childId = child:Id();
        if string.match(childId, "Agent ") and child:Visible() then
            if child:CurrentState() == "Selected" then
                local agentNumber = string.match(childId, "Agent (%d+)");
                output("agentNumber: " .. agentNumber);
                return tonumber(agentNumber, 10);
            end
        end
    end
    output("Selected agent not found");
    return nil;
end

--v function(index: number) --> CA_CHAR
function getCharFromSelectedForceAtIndex(index)
    output("A");
    local char = cm:get_campaign_ui_manager():get_char_selected();
    output("B");
    local cqi = string.sub(char, 15);
    --# assume cqi: CA_CQI
    local selectedLord = get_character_by_cqi(cqi);

    local charType = find_uicomponent(core:get_ui_root(), "character_details_panel", "background", "character_details_subpanel", "frame", "details", "info_list", "dy_type");
    local charTypeText = charType:GetStateText();
    if string.match(charTypeText, "Lord") then
        return selectedLord;
    end

    output("C");
    if not selectedLord:has_military_force() then
        return selectedLord;
    end
    local selectedMilForce = selectedLord:military_force();
    output("D");
    local character_list = selectedMilForce:character_list();
    output("E");
    output("num items: " .. character_list:num_items() .. " index " .. index);
    return character_list:item_at(index);
end

--v function() --> CA_CHAR
function calculateSelectedCharacter()
    local indexOfSelectedAgent = calculateIndexOfSelectedAgent();
    if not indexOfSelectedAgent then
        output("No index of selected agent");
        local char = cm:get_campaign_ui_manager():get_char_selected();
        local cqi = string.sub(char, 15);
        --# assume cqi: CA_CQI
        local selectedLord = get_character_by_cqi(cqi);
        output("Selected char: " .. tostring(selectedLord:cqi()));
        return selectedLord;
    end
    local selectedChar = getCharFromSelectedForceAtIndex(indexOfSelectedAgent);
    output("F");
    output(tostring(selectedChar));
    if not selectedChar then
        output("Failed to get selected char");
        return nil;
    end
    output("Selected char: " .. tostring(selectedChar:cqi()));
    return selectedChar;
end

--v function(callback: function(selectedChar: CA_CHAR))
function applyFunctionWhenCharSelected(callback)
    core:add_listener(
        "CustomLordsSkillHider",
        "PanelOpenedCampaign",
        function(context) 
            return context.string == "character_details_panel"; 
        end,
        function(context)
            local selectedChar = calculateSelectedCharacter();
            callback(selectedChar);
        end, 
        true
    );
    
    core:add_listener(
        "CustomLordButtonEnableCharacterChangeListener",
        "CharacterSelected",
        function()
            return true;
        end,
        function(context)
            cm:callback(
                function()
                    local selectedChar = calculateSelectedCharacter();
                    callback(selectedChar);
                end, 0, "asdasdsad"
            );
        end,
        true
    );
end

core:add_listener(
    "AddXpToChar",
    "ShortcutTriggered",
    function(context) return context.string == "camera_bookmark_view2"; end, --default F11
    function(context)
        cm:add_agent_experience(cm:get_campaign_ui_manager():get_char_selected(), 5000);
    end,
    true
);

-- core:add_listener(
--     "RankUpListener",
--     "CharacterRankUp",
--     function(context)
--         return true;
--     end,
--     function(context)
--         local char = context:character();
--         output("Char ranked up: " .. char:cqi());
--         if char:cqi() == 31 then
--             output("Correct char");
--             cm:force_add_skill(char_lookup_str(char), "wh2_main_skill_hef_noble_unique_combat");
--             cm:callback(
--                 function(context)
--                     cm:force_add_skill(char_lookup_str(char), "wh2_main_skill_hef_combat_valour_of_ages");
--                     cm:force_add_skill(char_lookup_str(char), "wh2_main_skill_hef_combat_valour_of_ages");
--                     cm:force_add_skill(char_lookup_str(char), "wh_main_skill_all_all_self_hard_to_hit");
--                 end, 0, "asdasd"
--             );
--         end
--     end,
--     true
-- );

--v function(list: vector<WHATEVER>, value: WHATEVER) --> boolean
function listContains(list, value)
    for i, listValue in ipairs(list) do
        if listValue == value then
            return true;
        end
    end
    return false;
end

--v function(list: vector<string>, toRemove: string)
function removeFromList(list, toRemove)
    for i, value in ipairs(list) do
        if value == toRemove then
            table.remove(list, i);
            return;
        end
    end
end

--v [NO_CHECK] function(t: WHATEVER, order: function(WHATEVER, WHATEVER, WHATEVER) --> boolean)
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

--v [NO_CHECK] function(list: vector<WHATEVER>, index: int, value: any)
function insertTableIndex(list, index, value)
    table.insert(list, index, value);
end