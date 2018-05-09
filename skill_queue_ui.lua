core:add_listener(
    "CustomLordsSkillasdasdHidersdfsdfsd",
    "PanelOpenedCampaign",
    function(context)
        return context.string == "character_details_panel"; 
    end,
    function(context)
        local skillList = find_uicomponent(core:get_ui_root(), "character_details_panel", "background", "skills_subpanel", "listview");
        skillList:SetCanResizeHeight(true);
        skillList:SetCanResizeWidth(true);
        local w, h = skillList:Dimensions();
        skillList:Resize(w-200, h);
    end, 
    true
);
