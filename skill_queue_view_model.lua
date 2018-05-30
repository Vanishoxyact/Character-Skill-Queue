local QueuedSkill = require("queued_skill");
local SkillQueueViewModel = {} --# assume SkillQueueViewModel: SKILL_QUEUE_VIEW_MODEL
SkillQueueViewModel.__index = SkillQueueViewModel;
SkillQueueViewModel.skillQueueWidth = 320;

SkillQueueViewModel.eventManager = nil --: EVENT_MANAGER
SkillQueueViewModel.skillListWidth = nil --: number
SkillQueueViewModel.queueExpanded = false --: boolean
SkillQueueViewModel.characterSkillQueue = nil --: CHARACTER_SKILL_QUEUE
SkillQueueViewModel.queuedSkills = {} --: vector<QUEUED_SKILL>
SkillQueueViewModel.queuedSkillsTotal = 0 --: int
SkillQueueViewModel.skillCards = {} --: map<string, CA_UIC>
SkillQueueViewModel.initialSkillLevel = {} --: map<string, int>
SkillQueueViewModel.maxSkillLevel = {} --: map<string, int>

--v function(self: SKILL_QUEUE_VIEW_MODEL, eventType: SKILL_QUEUE_EVENT, callback: function())
function SkillQueueViewModel.RegisterForEvent(self, eventType, callback)
    self.eventManager:RegisterForEvent(eventType, callback);
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, expanded: boolean)
function SkillQueueViewModel.setQueueExpanded(self, expanded)
    self.queueExpanded = expanded;
    self.eventManager:NotifyEvent("QUEUE_EXPANDED_CHANGE");
end

--v function(self: SKILL_QUEUE_VIEW_MODEL)
function SkillQueueViewModel.setupSkillListWidth(self)
    local skillList = find_uicomponent(core:get_ui_root(), "character_details_panel", "background", "skills_subpanel", "listview");
    local w, h = skillList:Dimensions();
    self.skillListWidth = w;
end

--v function(self: SKILL_QUEUE_VIEW_MODEL)
function SkillQueueViewModel.findSkillCards(self)
    output("findSkillCards");
    local skillCards = self.skillCards;
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
                        skillCards[innerSkill:Id()] = skillCard;
                    end
                else
                    local skillCard = find_uicomponent(skill, "card");
                    skillCards[skill:Id()] = skillCard;
                end
            end
        end
    end
end

--v function(self: SKILL_QUEUE_VIEW_MODEL)
function SkillQueueViewModel.detectAllSkillLevels(self)
    output("detectAllSkillLevels");
    for skill, skillCard in pairs(self.skillCards) do
        local skillLevelParent = find_uicomponent(skillCard, "level_parent");
        local level1 = find_uicomponent(skillLevelParent, "level1");
        local currentLevel = 0;
        local maxLevel = 0;
        -- active, inactive, locked
        local activeSkill = "active";
        if level1:Visible() then
            maxLevel = 1;
            if level1:CurrentState() == activeSkill then
                currentLevel = 1;
            end
        end
        local level2 = find_uicomponent(skillLevelParent, "level2");
        if level2:Visible() then
            maxLevel = 2;
            if level2:CurrentState() == activeSkill then
                currentLevel = 2;
            end
        end
        local level3 = find_uicomponent(skillLevelParent, "level3");
        if level3:Visible() then
            maxLevel = 3;
            if level3:CurrentState() == activeSkill then
                currentLevel = 3;
            end
        end
        self.initialSkillLevel[skill] = currentLevel;
        self.maxSkillLevel[skill] = maxLevel;
    end
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, characterSkillQueue: CHARACTER_SKILL_QUEUE, skill: string, index: int?) --> int
function SkillQueueViewModel.calculateSkillRank(self, characterSkillQueue, skill, index)
    local initialRank = self.initialSkillLevel[skill] or 0;
    local skillRank = initialRank;
    local queuedSkills = characterSkillQueue:getAllSkills();
    for i, queuedSkill in ipairs(queuedSkills) do
        if index then
            local resolvedIndex = index --: int
            if i > resolvedIndex then
                break
            end
        end
        if queuedSkill == skill then
            skillRank = skillRank + 1;
        end
    end
    return skillRank;
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, skill: string, characterSkillQueue: CHARACTER_SKILL_QUEUE) --> QUEUED_SKILL
function SkillQueueViewModel.createQueuedSkill(self, skill, characterSkillQueue)
    self.queuedSkillsTotal = self.queuedSkillsTotal + 1;
    local queuedSkill = QueuedSkill.new(skill);
    queuedSkill.id = self.queuedSkillsTotal;
    local i = #self.queuedSkills + 1;
    local charCurrentRank = get_character_by_cqi(characterSkillQueue.characterCqi):rank();
    queuedSkill.skillRank = self:calculateSkillRank(characterSkillQueue, skill, i);
    queuedSkill.index = i;
    queuedSkill.charRank = charCurrentRank + i;
    return queuedSkill;
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, characterSkillQueue: CHARACTER_SKILL_QUEUE)
function SkillQueueViewModel.createQueuedSkills(self, characterSkillQueue)
    local queuedSkills = characterSkillQueue:getAllSkills();
    for i, skill in ipairs(queuedSkills) do
        local queuedSkill = self:createQueuedSkill(skill, characterSkillQueue);
        table.insert(self.queuedSkills, queuedSkill);
    end
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, queuedSkill: QUEUED_SKILL, increase: boolean)
function SkillQueueViewModel.changeIndexOfQueuedSkill(self, queuedSkill, increase)
    if increase then
        queuedSkill:setIndex(queuedSkill.index + 1);
        queuedSkill:setCharRank(queuedSkill.charRank + 1);
    else
        queuedSkill:setIndex(queuedSkill.index - 1);
        queuedSkill:setCharRank(queuedSkill.charRank - 1);
    end
    queuedSkill:setSkillRank(self:calculateSkillRank(self.characterSkillQueue, queuedSkill.skill, queuedSkill.index));
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, skillIndex: int)
function SkillQueueViewModel.moveQueuedSkillUp(self, skillIndex)
    output("Moving skill up with index: " .. skillIndex);
    if skillIndex == 1 then
        return;
    end
    self.characterSkillQueue:moveSkillUp(skillIndex);
    for i, queuedSkill in ipairs(self.queuedSkills) do
        if i == skillIndex - 1 then
            self:changeIndexOfQueuedSkill(queuedSkill, true);
        end
        if i == skillIndex  then
            self:changeIndexOfQueuedSkill(queuedSkill, false);
        end
    end
    local queuedSkills = self.queuedSkills;
    local itemAtIndex = queuedSkills[skillIndex];
    table.remove(queuedSkills, skillIndex);
    insertTableIndex(queuedSkills, skillIndex - 1, itemAtIndex);
    self.eventManager:NotifyEvent("SKILL_QUEUE_UPDATED");
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, skillIndex: int)
function SkillQueueViewModel.moveQueuedSkillDown(self, skillIndex)
    if skillIndex == #self.queuedSkills then
        return;
    end
    self.characterSkillQueue:moveSkillDown(skillIndex);
    for i, queuedSkill in ipairs(self.queuedSkills) do
        if i == skillIndex + 1 then
            self:changeIndexOfQueuedSkill(queuedSkill, false);
        end
        if i == skillIndex then
            self:changeIndexOfQueuedSkill(queuedSkill, true);
        end
    end
    local queuedSkills = self.queuedSkills;
    local itemAtIndex = queuedSkills[skillIndex];
    table.remove(queuedSkills, skillIndex);
    insertTableIndex(queuedSkills, skillIndex + 1, itemAtIndex);
    self.eventManager:NotifyEvent("SKILL_QUEUE_UPDATED");
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, skillIndex: int)
function SkillQueueViewModel.removeQueuedSkill(self, skillIndex)
    self.characterSkillQueue:removeSkill(skillIndex);
    table.remove(self.queuedSkills, skillIndex);
    for i, queuedSkill in ipairs(self.queuedSkills) do
        if i >= skillIndex then
            self:changeIndexOfQueuedSkill(queuedSkill, false);
        end
    end
    self.eventManager:NotifyEvent("SKILL_QUEUE_UPDATED");
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, skill: string)
function SkillQueueViewModel.queueSkill(self, skill)
    local currentSkillLevel = self:calculateSkillRank(self.characterSkillQueue, skill);
    if currentSkillLevel >= self.maxSkillLevel[skill] then
        output("Skill already at max level: " .. skill);
        return;
    end
    output("Skill queued: " .. skill);
    self.characterSkillQueue:addSkillToQueue(skill);
    local queuedSkill = self:createQueuedSkill(skill, self.characterSkillQueue);
    table.insert(self.queuedSkills, queuedSkill);
    self.eventManager:NotifyEvent("SKILL_QUEUE_UPDATED");
end

--v function(self: SKILL_QUEUE_VIEW_MODEL, skill: string, rank: int) --> CA_UIC
function SkillQueueViewModel.getUicForSkillRank(self, skill, rank)
    local skillCard = self.skillCards[skill];
    local skillLevelParent = find_uicomponent(skillCard, "level_parent");
    return find_uicomponent(skillLevelParent, "level" .. rank);
end

--v function(characterSkillQueue: CHARACTER_SKILL_QUEUE) --> SKILL_QUEUE_VIEW_MODEL
function SkillQueueViewModel.new(characterSkillQueue)
    local sqvm = {};
    setmetatable(sqvm, SkillQueueViewModel);
    --# assume sqvm: SKILL_QUEUE_VIEW_MODEL
    sqvm.eventManager = EventManager.new();
    sqvm.skillListWidth = nil
    sqvm.queueExpanded = false;
    sqvm.characterSkillQueue = characterSkillQueue;
    sqvm.queuedSkills = {};
    sqvm.currentSkillLevel = {};
    sqvm.queuedSkillsTotal = 0;
    sqvm.skillCards = {};
    sqvm.initialSkillLevel = {};
    sqvm.maxSkillLevel = {};

    sqvm:setupSkillListWidth();
    sqvm:findSkillCards();
    sqvm:detectAllSkillLevels();
    sqvm:createQueuedSkills(characterSkillQueue);
    return sqvm;
end

return {
    new = SkillQueueViewModel.new
}