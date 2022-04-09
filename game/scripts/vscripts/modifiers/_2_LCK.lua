_2_LCK = class ({})
LinkLuaModifier( "_2_LCK_modifier", "modifiers/_2_LCK_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "_2_LCK_modifier_stack", "modifiers/_2_LCK_modifier_stack", LUA_MODIFIER_MOTION_NONE )

function _2_LCK:GetIntrinsicModifierName()
	return "_2_LCK_modifier"
end

function _2_LCK:GetBehavior()
	if self:GetCurrentAbilityCharges() == 2 then
		return DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_PASSIVE
	else
		return DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function _2_LCK:Spawn()
	self:SetCurrentAbilityCharges(1)

	self.stacks = 0
	self.percent = 0
	self.permanent = 0
	self.trained = 0
	self.basic_up = false
	self.min = 0
	self.max = 99
	self.spend = 0
end

function _2_LCK:OnOwnerSpawned()
	if self:GetCaster():IsIllusion() then return end
	local mods = self:GetCaster():FindAllModifiersByName("_2_LCK_modifier_stack")
	for _,mod in pairs(mods) do
		mod:Destroy()
	end
	
	self.stacks = 0
	self.percent = 0
	self:CalculateAttributes(0, 0)
end

function _2_LCK:OnHeroLevelUp()
	local caster = self:GetCaster()
	
	self:CheckLevelUp(false)
end

function _2_LCK:CheckLevelUp(trained)
	local caster = self:GetCaster()
	if caster:IsIllusion() then return end

	if trained == true then
		self.trained = self.trained + 1
	end

	if self.trained < 4 then
		self:SetCurrentAbilityCharges(1)
		return
	end
	
	if self.spend < 40 then
		self:SetCurrentAbilityCharges(2)
	else
		self:SetCurrentAbilityCharges(1)
	end
end

function _2_LCK:OnUpgrade()
	local caster = self:GetCaster()

	if caster:IsIllusion() then
		self:CalculateAttributes(0, 0)
		return
	end

	if self.basic_up == false then
		local str = caster:FindAbilityByName("_1_STR")
		local agi = caster:FindAbilityByName("_1_AGI")
		if str ~= nil then str:AddFraction(1) end
		if agi ~= nil then agi:AddFraction(1) end

		self.spend = self.spend + 1
	end

	self.basic_up = false
	self:CheckLevelUp(false)
	self:CalculateAttributes(0, 0)
end

function _2_LCK:BonusPermanent(value)
	self.permanent = self.permanent + value
	self:CalculateAttributes(0, 0)
end

function _2_LCK:BonusPts(caster, inflictor, stacks, percent, duration)
	local target = self:GetCaster()

	if IsServer() then
		target:AddNewModifier(caster, inflictor, "_2_LCK_modifier_stack", {
			duration = duration, stacks = stacks, percent = percent
		})
	end
end

function _2_LCK:CalculateAttributes(stacks, percent)
	self.stacks = self.stacks + stacks
	self.percent = self.percent + percent

	local base = self:GetLevel() + self.stacks + self.permanent
	if base < 0 then base = 0 end
	local perc = base * self.percent * 0.01
	local total = base + math.floor(perc)
	if total > self.max then total = self.max end
	if total < self.min then total = self.min end

	if IsServer() then
		local mod = self:GetCaster():FindModifierByName("_2_LCK_modifier")
		if mod then mod:SetStackCount(total) end
	end
end

function _2_LCK:EnableBasicUpgrade()
	self.basic_up = true
end

function _2_LCK:SetBounds(min, max)
	self.min = min
	self.max = max
	self:CalculateAttributes(0, 0)
end