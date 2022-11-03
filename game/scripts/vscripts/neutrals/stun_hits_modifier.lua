stun_hits_modifier = class({})

function stun_hits_modifier:IsHidden()
	return false
end

function stun_hits_modifier:IsPurgable()
    return false
end

function stun_hits_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.stun_duration = self.ability:GetSpecialValueFor("stun_duration")
	self.stun_crit = self.ability:GetSpecialValueFor("stun_crit")
	self.hits_max = self.ability:GetSpecialValueFor("hits")
	self.hits = 0
	self.record = false
end

function stun_hits_modifier:OnRefresh( kv )
end

function stun_hits_modifier:OnRemoved()
end

--------------------------------------------------------------------------------------------------------------------------

function stun_hits_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
	}

	return funcs
end

function stun_hits_modifier:GetModifierProcAttack_Feedback(keys)
	if (not self.parent:PassivesDisabled()) then
		if self:CheckStun() then
			self:PrepareCrit()
			self.record = true
			return
		end
	end
	if self.record then
		self.record = false
		keys.target:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
			duration = self.ability:CalcStatus(self.stun_duration, self.caster, keys.target)
		})
	end
end

function stun_hits_modifier:CheckStun()
	self.hits = self.hits + 1

	if self.hits >= self.hits_max then
		self.hits = 0
		return true
	end

	return false
end

function stun_hits_modifier:PrepareCrit()
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats == nil then return end

	base_stats:SetForceCritHit(self.stun_crit)
end

--------------------------------------------------------------------------------

function stun_hits_modifier:PlayEffects(target)
	if IsServer() then target:EmitSound("DOTA_Item.Daedelus.Crit") end
end

--------------------------------------------------------------------------------

-- function stun_hits_modifier:GetModifierPreAttack_CriticalStrike(keys)
-- 	if (not self.parent:PassivesDisabled()) then
-- 		if self:CheckStun() then
-- 			self.record = keys.record
-- 			return self.stun_crit
-- 		end
-- 	end
-- end

-- function stun_hits_modifier:GetModifierProcAttack_Feedback( keys )
-- 	if self.record then
-- 		self.record = nil
-- 		keys.target:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
-- 			duration = self.ability:CalcStatus(self.stun_duration, self.caster, keys.target)
-- 		})
-- 		self:PlayEffects( keys.target )
-- 	end
-- end

-- function stun_hits_modifier:CheckStun()
-- 	self.hits = self.hits + 1

-- 	if self.hits >= self.hits_max then
-- 		self.hits = 0
-- 		return true
-- 	end

-- 	return false
-- end