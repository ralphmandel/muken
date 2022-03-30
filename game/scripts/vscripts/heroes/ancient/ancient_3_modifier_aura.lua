ancient_3_modifier_aura = class({})

function ancient_3_modifier_aura:IsHidden()
	return false
end

function ancient_3_modifier_aura:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function ancient_3_modifier_aura:IsAura()
	return true
end

function ancient_3_modifier_aura:GetModifierAura()
	return "ancient_3_modifier_aura_effect"
end

function ancient_3_modifier_aura:GetAuraRadius()
	if self:GetAbility():GetCurrentAbilityCharges() == 0 then return self:GetAbility():GetSpecialValueFor("radius") end
	if self:GetAbility():GetCurrentAbilityCharges() == 1 then return self:GetAbility():GetSpecialValueFor("radius") end
	if self:GetAbility():GetCurrentAbilityCharges() % 2 == 0 then return self:GetAbility():GetSpecialValueFor("radius") * 1.4 end
end

function ancient_3_modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function ancient_3_modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

-----------------------------------------------------------

function ancient_3_modifier_aura:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local self_slow = self.ability:GetSpecialValueFor("self_slow")
	local intervals = self.ability:GetSpecialValueFor("intervals")

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = self_slow})

	self:StartIntervalThink(intervals)
	self:PlayEfxStart()
end

function ancient_3_modifier_aura:OnRefresh(kv)
end

function ancient_3_modifier_aura:OnRemoved(kv)
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-----------------------------------------------------------

function ancient_3_modifier_aura:OnIntervalThink()
	self:PlayEfxStart()
end

-----------------------------------------------------------

function ancient_3_modifier_aura:GetStatusEffectName()
	return "particles/status_fx/status_effect_statue.vpcf"
end

function ancient_3_modifier_aura:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function ancient_3_modifier_aura:PlayEfxStart()
	local particle_cast = "particles/ancient/ancient_aura.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

	if IsServer() then self.parent:EmitSound("Ancient.Aura.Layer") end
end