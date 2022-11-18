fountain_modifier = class({})

function fountain_modifier:IsHidden()
	return false
end

function fountain_modifier:IsPurgable()
    return false
end

function fountain_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then
		self:PlayEfxStart()
	end
end

function fountain_modifier:OnRefresh( kv )
end

function fountain_modifier:OnRemoved()
end

function fountain_modifier:CheckState()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_CANNOT_MISS] = true
	}

	return state
end

function fountain_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BASE_OVERRIDE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end

function fountain_modifier:GetModifierAttackSpeedBaseOverride(keys)
	return 200
end

function fountain_modifier:OnAttack(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound("dota_fountain.Attack") end
end

function fountain_modifier:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then keys.target:EmitSound("dota_fountain.ProjectileImpact") end
end

function fountain_modifier:GetAttackSound(keys)
    return ""
end

--------------------------------------------------------------------------------------------------------------------------

function fountain_modifier:IsAura()
	return true
end

function fountain_modifier:GetModifierAura()
	return "fountain_modifier_aura_effect"
end

function fountain_modifier:GetAuraRadius()
	return 400
end

function fountain_modifier:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function fountain_modifier:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function fountain_modifier:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function fountain_modifier:GetAuraEntityReject(hEntity)
	if hEntity == self:GetCaster() then return true end
	return false
end

--------------------------------------------------------------------------------------------------------------------------

function fountain_modifier:PlayEfxStart()
	local string = nil
	if self.parent:GetTeamNumber() == DOTA_TEAM_CUSTOM_1 then
		string = "particles/econ/events/ti7/fountain_regen_ti7_lvl3.vpcf"
	elseif self.parent:GetTeamNumber() == DOTA_TEAM_CUSTOM_2 then
		string = "particles/econ/events/fall_2022/regen/fountain_regen_fall2022_lvl3.vpcf"
	elseif self.parent:GetTeamNumber() == DOTA_TEAM_CUSTOM_3 then
		string = "particles/econ/events/fall_major_2016/radiant_fountain_regen_fm06_lvl3.vpcf"
	elseif self.parent:GetTeamNumber() == DOTA_TEAM_CUSTOM_4 then
		string = "particles/econ/events/spring_2021/fountain_regen_spring_2021_lvl3.vpcf"
	end

	if string == nil then return end

	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)

	local string_2 = "particles/radiant_fx/radiant_fountain_ambient.vpcf"
	local efx_2 = ParticleManager:CreateParticle(string_2, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(efx_2, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControlEnt(efx_2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_fx", Vector(0,0,0), true)
	self:AddParticle(efx_2, false, false, -1, false, false)
end