_2_MND = class ({})
LinkLuaModifier( "_2_MND_modifier", "modifiers/_2_MND_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "_2_MND_modifier_stack", "modifiers/_2_MND_modifier_stack", LUA_MODIFIER_MOTION_NONE )

function _2_MND:GetIntrinsicModifierName()
	return "_2_MND_modifier"
end

function _2_MND:GetBehavior()
	if self:GetCurrentAbilityCharges() == 2 then
		return DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_PASSIVE
	else
		return DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function _2_MND:Spawn()
	self:SetCurrentAbilityCharges(1)

	self.stacks = 0
	self.percent = 0
	self.permanent = 0
	self.trained = 0
	self.basic_up = false
	self.min = 0
	self.max = 99
end

function _2_MND:OnOwnerSpawned()
	if self:GetCaster():IsIllusion() then return end
	local mods = self:GetCaster():FindAllModifiersByName("_2_MND_modifier_stack")
	for _,mod in pairs(mods) do
		mod:Destroy()
	end
	
	self.stacks = 0
	self.percent = 0
	self:CalculateAttributes(0, 0)
end

function _2_MND:OnHeroLevelUp()
	local caster = self:GetCaster()
	
	self:CheckLevelUp(false)
end

function _2_MND:CheckLevelUp(trained)
	local caster = self:GetCaster()
	if caster:IsIllusion() then return end

	if trained == true then
		self.trained = self.trained + 1
	end

	if self.trained < 4 then
		self:SetCurrentAbilityCharges(1)
		return
	end
	
	if self:GetLevel() < ((caster:GetLevel() + 1) * 2) then
		self:SetCurrentAbilityCharges(2)
	else
		self:SetCurrentAbilityCharges(1)
	end
end

function _2_MND:OnUpgrade()
	local caster = self:GetCaster()

	if caster:IsIllusion() then
		self:CalculateAttributes(0, 0)
		return
	end

	if self.basic_up == true then
		self.basic_up = false
		self:CheckLevelUp(false)
		self:CalculateAttributes(0, 0)
		return
	end
	
	local int = caster:FindAbilityByName("_1_INT")
	local con = caster:FindAbilityByName("_1_CON")
	if int ~= nil then int:AddFraction(1) end
	if con ~= nil then con:AddFraction(1) end

	self:CheckLevelUp(false)
	self:CalculateAttributes(0, 0)
end

function _2_MND:BonusPermanent(value)
	self.permanent = self.permanent + value
	self:CalculateAttributes(0, 0)
end

function _2_MND:BonusPts(caster, inflictor, stacks, percent, duration)
	local target = self:GetCaster()

	if IsServer() then
		target:AddNewModifier(caster, inflictor, "_2_MND_modifier_stack", {
			duration = duration, stacks = stacks, percent = percent
		})
	end
end

function _2_MND:CalculateAttributes(stacks, percent)
	self.stacks = self.stacks + stacks
	self.percent = self.percent + percent

	local base = self:GetLevel() + self.stacks + self.permanent
	if base < 0 then base = 0 end
	local perc = base * self.percent * 0.01
	local total = base + math.floor(perc)
	if total > self.max then total = self.max end
	if total < self.min then total = self.min end

	if IsServer() then
		local mod = self:GetCaster():FindModifierByName("_2_MND_modifier")
		if mod then mod:SetStackCount(total) end
	end
end

function _2_MND:EnableBasicUpgrade()
	self.basic_up = true
end

function _2_MND:SetBounds(min, max)
	self.min = min
	self.max = max
	self:CalculateAttributes(0, 0)
end