gold_next_level = class({})

function gold_next_level:IsHidden()
	return true
end

function gold_next_level:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function gold_next_level:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.gold_init = 25
	self.gold_mult = 5
	self.max_level = 30
	
	if IsServer() then
		self:SetStackCount(0)
		self:StartIntervalThink(FrameTime())
	end
end

function gold_next_level:OnRefresh( kv )
end

function gold_next_level:OnRemoved()
	local player = self.parent:GetPlayerOwner()
	if (not player) then
		return
	end
	CustomGameEventManager:Send_ServerToPlayer(player, "next_up_from_server", { points = self:GetStackCount() })
end

--------------------------------------------------------------------------------

function gold_next_level:OnIntervalThink()
	if self.parent:IsIllusion() then return end
	local mod = self.parent:FindModifierByName("rank_points")
	
	if mod then
		local level = mod:GetRankLevel()

		if level == self.max_level then
			self:SetStackCount(0)
			self:Destroy()
			self:StartIntervalThink(FrameTime())
			return
		end

		local next_gold = self.gold_init + (self.gold_mult * level)

		if self.parent:GetGold() < next_gold then
			local stack = next_gold - self.parent:GetGold()
			self:SetStackCount(stack)
		end
	end
	
	self:StartIntervalThink(FrameTime())
end

function gold_next_level:OnStackCountChanged(old)
	if self:GetStackCount() == old then return end
	local player = self.parent:GetPlayerOwner()
    if (not player) then
        return
    end
    CustomGameEventManager:Send_ServerToPlayer(player, "next_up_from_server", { points = self:GetStackCount() })
end