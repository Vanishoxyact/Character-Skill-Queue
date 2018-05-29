local SkillValidator = {} --# assume SkillValidator: SKILL_VALIDATOR
SkillValidator.__index = SkillValidator;
SkillValidator.viewModel = nil --: SKILL_QUEUE_VIEW_MODEL

--v function(self: SKILL_VALIDATOR, skill: string) --> boolean
function SkillValidator.canUnlockSkill(self, skill)
    local questSkill = string.match(skill, "_quest");
    if questSkill then
        return false;
    end
    return true;
end

--v function(viewModel: SKILL_QUEUE_VIEW_MODEL) --> SKILL_VALIDATOR
function SkillValidator.new(viewModel)
    local sv = {};
    setmetatable(sv, SkillValidator);
    --# assume sv: SKILL_VALIDATOR
    sv.viewModel = viewModel;
    return sv;
end

return {
    new = SkillValidator.new
}