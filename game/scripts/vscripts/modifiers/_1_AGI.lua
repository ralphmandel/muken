_1_AGI = class ({})
LinkLuaModifier( "_1_AGI_modifier", "modifiers/_1_AGI_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "_1_AGI_modifier_stack", "modifiers/_1_AGI_modifier_stack", LUA_MODIFIER_MOTION_NONE )

function _1_AGI:GetIntrinsicModifierName()
	return "_1_AGI_modifier"
end

function _1_AGI:OnUpgrade()
	self:CalcBase()
end

function _1_AGI:SetBasePts(base)
	self.base = base
	self:CalcBase()
end

function _1_AGI:CalcBase()
	local caster = self:GetCaster()
	
	local mod = caster:FindModifierByName("_1_AGI_modifier")
	if mod then mod:Base_AGI(self.base) end
	self:CalculateAttributes(0, 0)
end

function _1_AGI:AddFraction(value)
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

function _1_AGI:Spawn()
	self.stacks = 0
	self.percent = 0
	self.permanent = 0
	self.base = 0
	self.fraction = 0
	self.min = 0
	self.max = 99
end

function _1_AGI:OnOwnerSpawned()
	if self:GetCaster():IsIllusion() then return end
	local mods = self:GetCaster():FindAllModifiersByName("_1_AGI_modifier_stack")
	for _,mod in pairs(mods) do
		mod:Destroy()
	end
	
	self.stacks = 0
	self.percent = 0
	self:CalculateAttributes(0, 0)
end

function _1_AGI:BonusPermanent(value)
	self.permanent = self.permanent + value
	self:CalculateAttributes(0, 0)
end

function _1_AGI:BonusPts(caster, inflictor, stacks, percent, duration)
	local target = self:GetCaster()

	if IsServer() then
		target:AddNewModifier(caster, inflictor, "_1_AGI_modifier_stack", {
			duration = duration, stacks = stacks, percent = percent
		})
	end
end

function _1_AGI:CalculateAttributes(stacks, percent)
	self.stacks = self.stacks + stacks
	self.percent = self.percent + percent

	local base = self:GetLevel() + self.stacks + self.permanent
	if base < 0 then base = 0 end
	local perc = base * self.percent * 0.01
	local total = base + math.floor(perc)
	if total > self.max then total = self.max end
	if total < self.min then total = self.min end

	if IsServer() then
		local mod = self:GetCaster():FindModifierByName("_1_AGI_modifier")
		if mod then mod:SetStackCount(total) end
	end

	local player = self:GetCaster():GetPlayerOwner()
	if (not player) then return end
	
	CustomGameEventManager:Send_ServerToPlayer(player, "stats_state_from_server", {
		stat = "AGI",
		base = self:GetLevel() + self.permanent,
		bonus = self.stacks,
		total = total,
	})
end

function _1_AGI:SetBounds(min, max)
	self.min = min
	self.max = max
	self:CalculateAttributes(0, 0)
end