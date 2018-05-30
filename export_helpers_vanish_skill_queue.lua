require("skill_queue");
-- No idea why this is needed
_G.get_faction = get_faction;
_G.get_character_by_cqi = get_character_by_cqi;
_G.GetTableSaveState = GetTableSaveState;

output("skill queue required");
-- General
--module(..., package.seeall)
--_G.main_env = getfenv(1) -- Probably not needed in most places