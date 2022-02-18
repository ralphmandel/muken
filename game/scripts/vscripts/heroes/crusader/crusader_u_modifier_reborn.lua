crusader_u_modifier_reborn = class({})

function crusader_u_modifier_reborn:IsHidden()
	return false
end

function crusader_u_modifier_reborn:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function crusader_u_modifier_reborn:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.as = self.ability:GetSpecialValueFor("as")
	self.ms = self.ability:GetSpecialValueFor("ms")
	self.parent:Purge(false, true, false, true, false)

	-- UP 4.3
	if self.ability:GetRank(3) then
		self.ability:AddBonus("_1_AGI", self.parent, 20, 0, nil)
	end

	if IsServer() then
		self.parent:EmitSound("Hero_SkeletonKing.Reincarnate.Ghost")
		self:StartIntervalThink(0.1)
	end
end

function crusader_u_modifier_reborn:OnRefresh(kv)
end

function crusader_u_modifier_reborn:OnRemoved(kv)
	self.ability:RemoveBonus("_1_AGI", self.parent)
	if self.parent:IsAlive() then self.parent:Kill(self.ability, self.attacker) end
end

-----------------------------------------------------------

function crusader_u_modifier_reborn:CheckState()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}

	return state
end

function crusader_u_modifier_reborn:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function crusader_u_modifier_reborn:GetMinHealth()
    return 1
end

function crusader_u_modifier_reborn:GetModifierAttackSpeedPercentage()
	if self.parent:IsHero() == false then return self.as end
	return 0
end

function crusader_u_modifier_reborn:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function crusader_u_modifier_reborn:OnTakeDamage(keys)
    if keys.unit ~= self.parent then return end
	self.attacker = keys.attacker
end

function crusader_u_modifier_reborn:OnIntervalThink()
	if self.parent:HasModifier("crusader_u_modifier_aura_effect") == false then
		self:Destroy()
		self:StartIntervalThink(-1)
	end
end

-----------------------------------------------------------

function crusader_u_modifier_reborn:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf"
end

function crusader_u_modifier_reborn:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function crusader_u_modifier_reborn:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function crusader_u_modifier_reborn:StatusEffectPriority()
	return 99999999
end