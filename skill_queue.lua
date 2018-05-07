require("skill_queue_util");
CharacterSkillQueue = require("character_skill_queue");
SkillQueueManager = require("skill_queue_manager");

local skillQueueManager = SkillQueueManager.new();
local testCqi = 31;
--# assume testCqi: CA_CQI
local testQueue = CharacterSkillQueue.new(testCqi);
testQueue:addSkillToQueue("wh2_main_skill_hef_noble_unique_combat");
testQueue:addSkillToQueue("wh2_main_skill_hef_combat_valour_of_ages");
testQueue:addSkillToQueue("wh2_main_skill_hef_combat_valour_of_ages");
testQueue:addSkillToQueue("wh_main_skill_all_all_self_hard_to_hit");
skillQueueManager.characterSkillQueues[testCqi]  = testQueue;