druid_3_modifier_totem = class({})

function druid_3_modifier_totem:IsHidden()
	return false
end

function druid_3_modifier_totem:IsPurgable()
	return false
end

function druid_3_modifier_totem:IsAura()
	return true
end

function druid_3_modifier_totem:GetModifierAura()
	return "druid_3_modifier_totem_effect"
end

function druid_3_modifier_totem:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function druid_3_modifier_totem:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function druid_3_modifier_totem:GetAuraRadius()
	return self:GetAbility():GetAOERadius()
end

--------------------------------------------------------------------------------

function druid_3_modifier_totem:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.min_health = self.parent:GetMaxHealth()
	if IsServer() then self:PlayEfxStart() end
end

function druid_3_modifier_totem:OnRefresh(kv)
end

function druid_3_modifier_totem:OnRemoved()
	if IsValidEntity(self.parent) then
		if self.parent:IsAlive() then
			self.parent:Kill(self.ability, nil)
		end
	end
end

--------------------------------------------------------------------------------

function druid_3_modifier_totem:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MIN_HEALTH
	}

	return funcs
end

function druid_3_modifier_totem:GetVisualZDelta(keys)
	return 100
end

function druid_3_modifier_totem:GetDisableHealing(keys)
	return 1
end

function druid_3_modifier_totem:GetMinHealth(keys)
	return self.min_health
end

function druid_3_modifier_totem:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	self.min_health = self.min_health - 1
end

--------------------------------------------------------------------------------

function druid_3_modifier_totem:PlayEfxStart()
	local string = "particles/druid/druid_skill3_totem.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	--ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(self.ability:GetAOERadius(), 0, 0))
	self:AddParticle(effect_cast, false, false, -1, false, false)
end