local SkillQueueManager = {} --# assume SkillQueueManager: SKILL_QUEUE_MANAGER
SkillQueueManager.__index = SkillQueueManager;
SkillQueueManager.characterSkillQueues = {} --: map<CA_CQI, CHARACTER_SKILL_QUEUE>
SkillQueueManager.characterRanks = {} --: map<CA_CQI, integer>

--v function(self: SKILL_QUEUE_MANAGER, character: CA_CHAR, skill: string, successCallback: function())
function SkillQueueManager.allocateSkill(self, character, skill, successCallback)
    local skillAllocated = false;
    cm:callback(
        function()
            core:remove_listener("SkillAllocationDetector");
            if not skillAllocated then
                output("Failed to allocate skill: " .. skill);
            else
                output("Skill allocated");
                self.characterSkillQueues[character:cqi()]:skilledInto(skill);
                successCallback();
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

--# assume SKILL_QUEUE_MANAGER.processCharRankedUp: function(self: SKILL_QUEUE_MANAGER, character: CA_CHAR, ranks: integer)
--v function(self: SKILL_QUEUE_MANAGER, character: CA_CHAR, ranks: integer)
function SkillQueueManager.processCharRankedUp(self, character, ranks)
    output("Char ranked up: " .. tonumber(character:cqi()));
    if ranks == 0 then
        return;
    end
    local characterSkillQueue = self.characterSkillQueues[character:cqi()];
    if not characterSkillQueue then
        return;
    end
    local nextSkill = characterSkillQueue:getNextSkill();
    if not nextSkill then
        return;
    end
    self:allocateSkill(
        character, nextSkill,
        function()
            self:processCharRankedUp(character, ranks - 1);
        end
    );
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
            local rankDiff = rankedUpChar:rank() - self.characterRanks[rankedUpChar:cqi()];
            output("char rank diff : " .. rankDiff);
            self.characterRanks[rankedUpChar:cqi()] = rankedUpChar:rank();
            self:processCharRankedUp(rankedUpChar, rankDiff);
        end,
        true
    );
end

--v function(self: SKILL_QUEUE_MANAGER)
function SkillQueueManager.calculateCharacterRanks(self)
    local currentFaction = get_faction(cm:get_local_faction());
    local characters = currentFaction:character_list();
    for i = 0, characters:num_items() - 1 do
        local currentCharacter = characters:item_at(i);
        self.characterRanks[currentCharacter:cqi()] = currentCharacter:rank();
    end
end

--v function() --> SKILL_QUEUE_MANAGER
function SkillQueueManager.new()
    local sqm = {};
    setmetatable(sqm, SkillQueueManager);
    --# assume sqm: SKILL_QUEUE_MANAGER
    sqm:registerForCharRankUp();
    sqm:calculateCharacterRanks();
    return sqm
end

return {
    new = SkillQueueManager.new
}