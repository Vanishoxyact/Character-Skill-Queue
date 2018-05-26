local SkillQueuer = {} --# assume SkillQueuer: SKILL_QUEUER
SkillQueuer.__index = SkillQueuer;
SkillQueuer.skillSelectedCallback = nil --: function(string)
SkillQueuer.defaultSkillCardState = {} --: map<CA_UIC, BUTTON_STATE>

--v function(func: function) --> any
function safeCall(func)
    output("safeCall start");
    local status, result = pcall(func)
    if not status then
        output(tostring(result))
    end
    output("safeCall end");
    return result;
end

--v function(self: SKILL_QUEUER) --> vector<CA_UIC>
function SkillQueuer.findSkillCards(self)
    local skillCards = {} --: vector<CA_UIC>
    local skillList = find_uicomponent(core:get_ui_root(), "character_details_panel", "background", "skills_subpanel", "listview", "list_clip", "list_box");
    if not skillList then
        output("No skill list");
    end
    for i=0, skillList:ChildCount()-1  do
        local skillChain = UIComponent(skillList:Find(i));
        local chain = find_uicomponent(skillChain, "chain");
        if chain then
            for j=0, chain:ChildCount()-1  do
                local skill = UIComponent(chain:Find(j));
                if string.match(skill:Id(), "module_") then
                    for k=0, skill:ChildCount()-1  do
                        local innerSkill = UIComponent(skill:Find(k));
                        local skillCard = find_uicomponent(innerSkill, "card");
                        table.insert(skillCards, skillCard);
                    end
                else
                    local skillCard = find_uicomponent(skill, "card");
                    table.insert(skillCards, skillCard);
                end
            end
        end
    end
    return skillCards;
end

--v function(self: SKILL_QUEUER)
function SkillQueuer.highightQueueableSkills(self)
    -- available, locked, hover
    output("highightQueueableSkills");
    safeCall(
        function()
            local skillCards = self:findSkillCards();
            for i, skillCard in ipairs(skillCards) do
                output("Current state: "  .. skillCard:Id() .. " " .. skillCard:CurrentState());
                self.defaultSkillCardState[skillCard] = skillCard:CurrentState();
                skillCard:SetState("available");
            end
        end
    );
end

--v function(self: SKILL_QUEUER)
function SkillQueuer.resetSkillHighlights(self)
    output("resetSkillHighlights");
    safeCall(
        function()
            for skillCard, state in pairs(self.defaultSkillCardState) do
                skillCard:SetState(state);
            end
        end
    );
end

--v function(skillSelectedCallback: function(string)) --> SKILL_QUEUER
function SkillQueuer.new(skillSelectedCallback)
    local sq = {};
    setmetatable(sq, SkillQueuer);
    --# assume sq: SKILL_QUEUER
    sq.skillSelectedCallback = skillSelectedCallback;
    sq.defaultSkillCardState = {};
    return sq;
end

return {
    new = SkillQueuer.new
}