_1_STR = class ({})
LinkLuaModifier( "_1_STR_modifier", "modifiers/_1_STR_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "_1_STR_modifier_stack", "modifiers/_1_STR_modifier_stack", LUA_MODIFIER_MOTION_NONE )

function _1_STR:GetIntrinsicModifierName()
	return "_1_STR_modifier"
end

function _1_STR:OnUpgrade()
	self:CalcBase()
end

function _1_STR:SetBasePts(base)
	self.base = base
	self:CalcBase()
end

function _1_STR:CalcBase()
	local caster = self:GetCaster()

	local mod = caster:FindModifierByName("_1_STR_modifier")
	if mod then mod:Base_STR(self.base) end
	self:CalculateAttributes(0, 0)
end

function _1_STR:AddFraction(value)
	if self:GetCaster():IsIllusion() then return end
	self.fraction = self.fraction + value

	local lvlup = math.floor(self.fraction / 3)
	if lvlup > 0 then
		for x = 1, lvlup, 1 do
			self:UpgradeAbility(true)
		end
	end

	self.fraction = self.fraction % 3
end

function _1_STR:Spawn()
	self.stacks = 0
	self.percent = 0
	self.permanent = 0
	self.base = 0
	self.fraction = 0
	self.min = 0
	self.max = 99
end

function _1_STR:OnOwnerSpawned()
	if self:GetCaster():IsIllusion() then return end
	local mods = self:GetCaster():FindAllModifiersByName("_1_STR_modifier_stack")
	for _,mod in pairs(mods) do
		mod:Destroy()
	end
	
	self.stacks = 0
	self.percent = 0
	self:CalculateAttributes(0, 0)
end

function _1_STR:BonusPermanent(value)
	self.permanent = self.permanent + value
	self:CalculateAttributes(0, 0)
end

function _1_STR:BonusPts(caster, inflictor, stacks, percent, duration)
	local target = self:GetCaster()

	if IsServer() then
		target:AddNewModifier(caster, inflictor, "_1_STR_modifier_stack", {
			duration = duration, stacks = stacks, percent = percent
		})
	end
end

function _1_STR:CalculateAttributes(stacks, percent)
	self.stacks = self.stacks + stacks
	self.percent = self.percent + percent

	local base = self:GetLevel() + self.stacks + self.permanent
	if base < 0 then base = 0 end
	local perc = base * self.percent * 0.01
	local total = base + math.floor(perc)
	if total > self.max then total = self.max end
	if total < self.min then total = self.min end

	if IsServer() then
		local mod = self:GetCaster():FindModifierByName("_1_STR_modifier")
		if mod then mod:SetStackCount(total) end
	end
end

function _1_STR:SetBounds(min, max)
	self.min = min
	self.max = max
	self:CalculateAttributes(0, 0)
end