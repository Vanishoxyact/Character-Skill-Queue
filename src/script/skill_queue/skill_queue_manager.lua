local SkillQueueModel = my_load_mod_script("skill_queue_model");
local SkillQueueManager = {} --# assume SkillQueueManager: SKILL_QUEUE_MANAGER
SkillQueueManager.__index = SkillQueueManager;
SkillQueueManager.characterRanks = {} --: map<CA_CQI, integer>
SkillQueueManager.model = nil --: SKILL_QUEUE_MODEL

--v function(self: SKILL_QUEUE_MANAGER, character: CA_CHAR, skill: string, successCallback: function())
function SkillQueueManager.allocateSkill(self, character, skill, successCallback)
    local skillAllocated = false;
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
    cm:callback(
          function()
              core:remove_listener("SkillAllocationDetector");
              if not skillAllocated then
                  out("Failed to allocate skill: " .. skill);
              else
                  out("Skill allocated");
                  self.model:getSkillQueueForCharacter(character):skilledInto(skill);
                  local ancillaryFromSkillTable = SKILL_QUEUE_TABLES["character_skill_level_to_ancillaries_junctions_tables"][skill];
                  if ancillaryFromSkillTable then
                      local ancillary = ancillaryFromSkillTable["granted_ancillary"]
                      out("force add ancillary from skill:" .. ancillary);
                      cm:force_add_ancillary(character, ancillary, true, false)
                  end
                  successCallback();
              end
          end, 0.5, "SkillAllocationCallback"
    );
end

--# assume SKILL_QUEUE_MANAGER.processCharRankedUp: function(self: SKILL_QUEUE_MANAGER, character: CA_CHAR, ranks: integer)
--v function(self: SKILL_QUEUE_MANAGER, character: CA_CHAR, ranks: integer)
function SkillQueueManager.processCharRankedUp(self, character, ranks)
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
            self.characterRanks[rankedUpChar:cqi()] = rankedUpChar:rank();
            if VANISH_SKILL_POINT_MULTIPLIER then
                rankDiff = rankDiff * VANISH_SKILL_POINT_MULTIPLIER;
            end
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