local SkillQueueManager = {} --# assume SkillQueueManager: SKILL_QUEUE_MANAGER
SkillQueueManager.__index = SkillQueueManager;
SkillQueueManager.characterSkillQueues = {} --: map<CA_CQI, CHARACTER_SKILL_QUEUE>

--v function(self: SKILL_QUEUE_MANAGER, character: CA_CHAR, skill: string)
function SkillQueueManager.allocateSkill(self, character, skill)
    local skillAllocated = false;
    cm:callback(
        function()
            core:remove_listener("SkillAllocationDetector");
            if not skillAllocated then
                output("Failed to allocate skill: " .. skill);
            else
                output("Skill allocated");
                self.characterSkillQueues[character:cqi()]:skilledInto(skill);
            end
        end, 0, "SkillAllocationCallback"
    );
    core:add_listener(
        "SkillAllocationDetector",
        "CharacterSkillPointAllocated",
        function(context)
            return (context:character() == character) and (context:skill_point_spent_on() == skill);
        end,
        function(context)
            skillAllocated = true;
        end,
        true
    );
    cm:force_add_skill("character_cqi:" .. tonumber(character:cqi()), skill);
end

--v function(self: SKILL_QUEUE_MANAGER, character: CA_CHAR)
function SkillQueueManager.processCharRankedUp(self, character)
    output("Char ranked up: " .. tonumber(character:cqi()));
    local characterSkillQueue = self.characterSkillQueues[character:cqi()];
    if not characterSkillQueue then
        return;
    end
    local nextSkill = characterSkillQueue:getNextSkill();
    if not nextSkill then
        return;
    end
    self:allocateSkill(character, nextSkill);
end

--v function(self: SKILL_QUEUE_MANAGER)
function SkillQueueManager.registerForCharRankUp(self)
    core:add_listener(
        "RankUpListener",
        "CharacterRankUp",
        function(context)
            return true;
        end,
        function(context)
            local rankedUpChar = context:character();
            self:processCharRankedUp(rankedUpChar);
        end,
        true
    );
end

--v function() --> SKILL_QUEUE_MANAGER
function SkillQueueManager.new()
    local sqm = {};
    setmetatable(sqm, SkillQueueManager);
    --# assume sqm: SKILL_QUEUE_MANAGER
    sqm:registerForCharRankUp();
    return sqm
end

return {
    new = SkillQueueManager.new
}