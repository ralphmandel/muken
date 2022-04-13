dasdingo_x1_modifier_tribal = class({})

function dasdingo_x1_modifier_tribal:IsHidden()
	return false
end

function dasdingo_x1_modifier_tribal:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function dasdingo_x1_modifier_tribal:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local int = self.caster:FindModifierByName("_1_INT_modifier")
	if int then self.parent:CreatureLevelUp(int:GetStackCount()) end

	self.parent:StartGesture(ACT_IDLE)
	self:PlayEfxRegen()
end

function dasdingo_x1_modifier_tribal:OnRefresh( kv )
end

function dasdingo_x1_modifier_tribal:OnRemoved()
	if IsValidEntity(self.parent) then
		if self.parent:IsAlive() then
			self.parent:Kill(self.ability, nil)
		end
	end
end

--------------------------------------------------------------------------------

function dasdingo_x1_modifier_tribal:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}

	return state
end

function dasdingo_x1_modifier_tribal:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_EVENT_ON_HEAL_RECEIVED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}
	return funcs
end

function dasdingo_x1_modifier_tribal:GetModifierDamageOutgoing_Percentage()
	return -40
end

function dasdingo_x1_modifier_tribal:GetModifierProcAttack_Feedback(keys)
	if self.parent:PassivesDisabled() then return end

	CreateModifierThinker(
		self.parent,
		self.ability,
		"dasdingo_x1_modifier_bounce",
		{  },
		keys.target:GetOrigin(),
		self.parent:GetTeamNumber(),
		false
	)
end

function dasdingo_x1_modifier_tribal:GetModifierAttackSpeedPercentage()
	return 100
end

function dasdingo_x1_modifier_tribal:OnAttack(keys)
	if keys.attacker == self.parent then
		if self.ability.sound == nil then
			if IsServer() then self.parent:EmitSound("Hero_WitchDoctor_Ward.Attack") end
		end
	end
end

function dasdingo_x1_modifier_tribal:OnAttackLanded(keys)
	if keys.attacker == self.parent then
		if IsServer() then self.parent:EmitSound("Hero_WitchDoctor_Ward.ProjectileImpact") end
	end
end

function dasdingo_x1_modifier_tribal:GetModifierHealAmplify_PercentageTarget(keys)
	return -50
end

function dasdingo_x1_modifier_tribal:OnHealReceived(keys)
    if keys.unit ~= self.parent then return end
    if keys.inflictor == nil then return end
    if keys.gain < 1 then return end

    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, keys.unit, keys.gain, keys.unit)
end

function dasdingo_x1_modifier_tribal:OnTakeDamage(keys)
    if keys.unit ~= self.parent then return end
    if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then return end

    local efx = nil
    --if keys.damage_type == DAMAGE_TYPE_PHYSICAL then efx = OVERHEAD_ALERT_DAMAGE end
    if keys.damage_type == DAMAGE_TYPE_MAGICAL then efx = OVERHEAD_ALERT_BONUS_SPELL_DAMAGE end
    if keys.damage_type == DAMAGE_TYPE_PURE then self:PopupCustom(math.floor(keys.damage), Vector(255, 225, 175)) end

    if keys.inflictor ~= nil then
        if keys.inflictor == "shadow_1__weapon"
        or keys.inflictor == "shadow_2__smoke" then
            efx = OVERHEAD_ALERT_BONUS_POISON_DAMAGE
        end
    end

    if efx == nil then return end
    SendOverheadEventMessage(nil, efx, self.parent, keys.damage, self.parent)
end

function dasdingo_x1_modifier_tribal:PopupCustom(damage, color)
	local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent) -- target:GetOwner()
    local digits = 1
	if damage < 10 then digits = 1 end
    if damage > 9 and damage < 100 then digits = 2 end
    if damage > 99 and damage < 1000 then digits = 3 end
    if damage > 999 then digits = 4 end

    ParticleManager:SetParticleControl(pidx, 1, Vector(0, damage, 6))
    ParticleManager:SetParticleControl(pidx, 2, Vector(3, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end

function dasdingo_x1_modifier_tribal:GetAttackSound(keys)
    return ""
end

--------------------------------------------------------------------------------

function dasdingo_x1_modifier_tribal:GetEffectName()
	return "particles/econ/items/witch_doctor/wd_2021_cache/wd_2021_cache_death_ward.vpcf"
end

function dasdingo_x1_modifier_tribal:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function dasdingo_x1_modifier_tribal:PlayEfxRegen()
	local string = "particles/econ/items/juggernaut/jugg_fortunes_tout/jugg_healling_ward_fortunes_tout_hero_heal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 2, self.parent:GetOrigin())
	self:AddParticle(effect_cast, false, false, -1, false, false)
end