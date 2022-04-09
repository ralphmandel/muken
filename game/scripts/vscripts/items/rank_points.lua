rank_points = class({})

function rank_points:IsHidden()
	return true
end

function rank_points:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function rank_points:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	if self.parent:IsIllusion() then return end

	self.gold_init = 25
	self.gold_mult = 5

	self.level = 0
	self.max_level = 33
	
	if IsServer() then
		self:SetStackCount(0)
	end

	self:StartIntervalThink(0.1)
end

function rank_points:OnRefresh( kv )
end

function rank_points:OnRemoved()
end

--------------------------------------------------------------------------------

function rank_points:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function rank_points:OnTakeDamage(keys)
	if self.parent:IsIllusion() then return end
	if keys.unit ~= self.parent then return end
	self.ability:StartCooldown(5)
end

function rank_points:OnIntervalThink()
	if self.parent:IsIllusion() then return end
	
	self:CheckPoints()
end

function rank_points:GetNextGoldState()
	if self.parent:IsIllusion() then return end
	if self.level >= self.max_level then
		local player = self.parent:GetPlayerOwner()
		if (not player) then
			return
		end
		CustomGameEventManager:Send_ServerToPlayer(player, "next_up_from_server", { points = 0 })
	else
		self.parent:RemoveModifierByName("gold_next_level")
		self.parent:AddNewModifier(self.caster, self.ability, "gold_next_level", {})
	end
end

function rank_points:CheckPoints()
	if self.parent:IsIllusion() then return end
	if self.level < self.max_level then
		local mod = self.parent:FindModifierByName("gold_next_level")
		if mod == nil then
			self.parent:AddNewModifier(self.caster, self.ability, "gold_next_level", {})
		end
	else
		return
	end

	local next_gold = self.gold_init + (self.gold_mult * self.level)

	if self.parent:GetGold() >= next_gold then
		local new_gold = self.parent:GetGold() - next_gold
		self.parent:SetGold(0, true)
		self.parent:SetGold(new_gold, false)

		self.level = self.level + 1
		self:IncrementStackCount()
		self:CheckPoints()
	end
end

function rank_points:GetRankLevel()
	return self.level
end

function rank_points:OnStackCountChanged(old)
	if self.parent:IsIllusion() then return end
	if self:GetStackCount() == old then return end
	if self:GetStackCount() <= 0 then return end
	local player = self.parent:GetPlayerOwner()
    if (not player) then
        return
    end
	CustomGameEventManager:Send_ServerToPlayer(player, "rankup_state_from_server", {})
end