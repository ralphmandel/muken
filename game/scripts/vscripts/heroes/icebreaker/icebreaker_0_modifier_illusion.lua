icebreaker_0_modifier_illusion = class({})

--------------------------------------------------------------------------------

function icebreaker_0_modifier_illusion:IsHidden()
	return true
end

function icebreaker_0_modifier_illusion:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function icebreaker_0_modifier_illusion:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.stop = false
	self.min_health = 1

	self:StartIntervalThink(0.1)
end

function icebreaker_0_modifier_illusion:OnRefresh( kv )
end

function icebreaker_0_modifier_illusion:OnDestroy( kv )
end

--------------------------------------------------------------------------------

function icebreaker_0_modifier_illusion:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function icebreaker_0_modifier_illusion:CheckState()
	local state = {
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
	}

	return state
end

function icebreaker_0_modifier_illusion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	
	return funcs
end

function icebreaker_0_modifier_illusion:GetMinHealth()
	return self.min_health
end

function icebreaker_0_modifier_illusion:GetModifierMoveSpeedBonus_Percentage()
	return 50
end


function icebreaker_0_modifier_illusion:GetModifierFixedAttackRate()
	return 1.5
end

function icebreaker_0_modifier_illusion:GetModifierBaseAttackTimeConstant()
    return 1
end

function icebreaker_0_modifier_illusion:OnAttackLanded(keys)
	if keys.target == self.parent then
		self.min_health = 0
		self.parent:ForceKill(false)
		return
	end

	if keys.attacker == self.parent then
		if keys.target:IsMagicImmune() then return end

		local ability_slow = self.caster:FindAbilityByName("icebreaker_0__slow")
		if ability_slow then
			if ability_slow:IsTrained() then
				ability_slow:AddSlow(keys.target, self.ability)
			end
		end
	end
end

function icebreaker_0_modifier_illusion:OnIntervalThink()
	local found = false
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		1000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		128,	-- int, flag filter
		1,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		if enemy:HasModifier("icebreaker_0_modifier_slow") and found == false then
			self.parent:Interrupt()
			self.parent:SetForceAttackTarget(enemy)
			self.parent:MoveToTargetToAttack(enemy)
			self.stop = false
			found = true
		end
	end

	if found == false and self.stop == false then
		self.parent:SetForceAttackTarget(nil)
		self.parent:Stop()
		self.parent:Hold()
		self.stop = true
	end
end

------------------------------------------------------------------------------------

function icebreaker_0_modifier_illusion:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_radiant.vpcf"
end

function icebreaker_0_modifier_illusion:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function icebreaker_0_modifier_illusion:PlayEffects()

	local particle_cast = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ambient.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )

	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self.parent,
		PATTACH_ABSORIGIN_FOLLOW,
		"",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end