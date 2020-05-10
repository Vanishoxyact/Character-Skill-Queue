local SkillQueueModel = my_load_mod_script("skill_queue_model");
local SkillQueueManager = {} --# assume SkillQueueManager: SKILL_QUEUE_MANAGER
SkillQueueManager.__index = SkillQueueManager;
SkillQueueManager.characterRanks = {} --: map<CA_CQI, integer>
SkillQueueManager.model = nil --: SKILL_QUEUE_MODEL

--v function(self: SKILL_QUEUE_MANAGER, character: CA_CHAR, skill: string, successCallback: function())
function SkillQueueManager.allocateSkill(self, character, skill, successCallback)
    local skillAllocated = false;
    cm:callback(
        function()
            core:remove_listener("SkillAllocationDetector");
            if not skillAllocated then
                out("Failed to allocate skill: " .. skill);
            else
                out("Skill allocated");
                self.model:getSkillQueueForCharacter(character):skilledInto(skill);
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
    out("adding skill");
    cm:force_add_skill("character_cqi:" .. tonumber(character:cqi()), skill);
    out("skill added");
end

--# assume SKILL_QUEUE_MANAGER.processCharRankedUp: function(self: SKILL_QUEUE_MANAGER, character: CA_CHAR, ranks: integer)
--v function(self: SKILL_QUEUE_MANAGER, character: CA_CHAR, ranks: integer)
function SkillQueueManager.processCharRankedUp(self, character, ranks)
    out("Char ranked up: " .. tonumber(character:cqi()));
    if ranks == 0 then
        return;
    end
    local characterSkillQueue = self.model:getSkillQueueForCharacter(character);
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
            out("char rank diff : " .. rankDiff);
            self.characterRanks[rankedUpChar:cqi()] = rankedUpChar:rank();
            self:processCharRankedUp(rankedUpChar, rankDiff);
        end,
        true
    );
end

--v function(self: SKILL_QUEUE_MANAGER)
function SkillQueueManager.registerForCharCreated(self)
    core:add_listener(
        "CharCreatedRankListener",
        "CharacterCreated",
        function(context)
            return true;
        end,
        function(context)
            local createdCharCqi = context:character():cqi();
            cm:callback(
                function()
                    local character = cm:get_character_by_cqi(createdCharCqi);
                    if character then
                        self.characterRanks[createdCharCqi] = character:rank();
                    end
                end, 0, "CharCreatedCallbackCallback"
            );
        end,
        true
    );
end

--v function(self: SKILL_QUEUE_MANAGER)
function SkillQueueManager.calculateCharacterRanks(self)
    local factionList = cm:model():world():faction_list();
    for i = 0, factionList:num_items() - 1 do
        local currentFaction = factionList:item_at(i);
        local characters = currentFaction:character_list();
        for j = 0, characters:num_items() - 1 do
            local currentCharacter = characters:item_at(j);
            self.characterRanks[currentCharacter:cqi()] = currentCharacter:rank();
        end
    end
end

--v function() --> SKILL_QUEUE_MANAGER
function SkillQueueManager.new()
    local sqm = {};
    setmetatable(sqm, SkillQueueManager);
    --# assume sqm: SKILL_QUEUE_MANAGER
    sqm.characterRanks = {};
    sqm.model = SkillQueueModel.new();
    sqm:registerForCharRankUp();
    sqm:calculateCharacterRanks();
    sqm:registerForCharCreated();
    return sqm;
end

return {
    new = SkillQueueManager.new
}