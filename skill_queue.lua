output("skill_queue");

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

core:add_listener(
    "CustomLordsSkillHider",
    "PanelOpenedCampaign",
    function(context) 
        return context.string == "character_details_panel"; 
    end,
    function(context)
        local indexOfSelectedAgent = calculateIndexOfSelectedAgent();
        if not indexOfSelectedAgent then
            output("No index of selected agent");
            local char = cm:get_campaign_ui_manager():get_char_selected();
            local cqi = string.sub(char, 15);
            --# assume cqi: CA_CQI
            local selectedLord = get_character_by_cqi(cqi);
            output("Selected char: " .. tostring(selectedLord:cqi()));
            return;
        end
        local selectedChar = getCharFromSelectedForceAtIndex(indexOfSelectedAgent);
        output("F");
        output(tostring(selectedChar));
        if not selectedChar then
            output("Failed to get selected char");
            return;
        end
        output("Selected char: " .. tostring(selectedChar:cqi()));
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
                local indexOfSelectedAgent = calculateIndexOfSelectedAgent();
                if not indexOfSelectedAgent then
                    output("No index of selected agent");
                    local char = cm:get_campaign_ui_manager():get_char_selected();
                    local cqi = string.sub(char, 15);
                    --# assume cqi: CA_CQI
                    local selectedLord = get_character_by_cqi(cqi);
                    output("Selected char: " .. tostring(selectedLord:cqi()));
                    return;
                end
                local selectedChar = getCharFromSelectedForceAtIndex(indexOfSelectedAgent);
                output("F");
                output(tostring(selectedChar));
                if not selectedChar then
                    output("Failed to get selected char");
                    return;
                end
                output("G");
                selectedChar:cqi();
                output("H");
                output("Selected char: " .. tostring(selectedChar:cqi()));
            end, 0, "asdasdsad"
        );
    end,
    true
);