druid_4_modifier_metamorphosis = class({})

function druid_4_modifier_metamorphosis:IsHidden()
	return false
end

function druid_4_modifier_metamorphosis:IsPurgable()
	return false
end

function druid_4_modifier_metamorphosis:IsDebuff()
	return false
end

-- AURA -----------------------------------------------------------

function druid_4_modifier_metamorphosis:IsAura()
	return true
end

function druid_4_modifier_metamorphosis:GetModifierAura()
	return "druid_4_modifier_aura_effect"
end

function druid_4_modifier_metamorphosis:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function druid_4_modifier_metamorphosis:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP
end

function druid_4_modifier_metamorphosis:GetAuraRadius()
	return self:GetAbility():GetAOERadius()
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_4_modifier_metamorphosis:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.heal_power = self.ability:GetSpecialValueFor("heal_power")
	local con = self.ability:GetSpecialValueFor("con")

	self.ability:AddBonus("_1_CON", self.parent, con, 0, nil)
	self.ability:SetActivated(false)
	self.ability:EndCooldown()
	self:HideItens(true)

	if IsServer() then self:PlayEfxStart() end
end

function druid_4_modifier_metamorphosis:OnRefresh(kv)
end

function druid_4_modifier_metamorphosis:OnRemoved()
	if IsServer() then self:PlayEfxEnd() end

	self.ability:RemoveBonus("_1_CON", self.parent)
	self.ability:SetActivated(true)
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self:HideItens(false)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_4_modifier_metamorphosis:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function druid_4_modifier_metamorphosis:GetModifierHealAmplify_PercentageTarget()
    return self.heal_power
end

function druid_4_modifier_metamorphosis:GetModifierHPRegenAmplify_Percentage(keys)
    return self.heal_power
end

function druid_4_modifier_metamorphosis:GetModifierModelChange()
	return "models/items/lone_druid/true_form/form_of_the_atniw/form_of_the_atniw.vmdl"
end

-- UTILS -----------------------------------------------------------

function druid_4_modifier_metamorphosis:HideItens(bool)
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	local base_hero_mod = self.parent:FindModifierByName("base_hero_mod")
	if cosmetics == nil then return end
	if base_hero_mod == nil then return end

	for i = 1, #cosmetics.cosmetic, 1 do
		cosmetics:HideCosmetic(cosmetics.cosmetic[i]:GetModelName(), bool)
	end

	if bool then
		base_hero_mod:ChangeSounds("Hero_LoneDruid.TrueForm.PreAttack", nil, "Hero_LoneDruid.TrueForm.Attack")
	else
		base_hero_mod:LoadSounds()
	end

	local root = self.parent:FindAbilityByName("druid_1__root")
	if root then
		if root:IsTrained() then
			root:CheckAbilityCharges(1)	
		end
	end

	local totem = self.parent:FindAbilityByName("druid_3__totem")
	if totem then
		if totem:IsTrained() then
			totem:CheckAbilityCharges(1)	
		end
	end

	local entangled = self.parent:FindAbilityByName("druid_5__entangled")
	if entangled then
		if entangled:IsTrained() then
			entangled:CheckAbilityCharges(1)	
		end
	end

	local ult = self.parent:FindAbilityByName("druid_u__conversion")
	if ult then
		if ult:IsTrained() then
			ult:CheckAbilityCharges(1)	
		end
	end
end
-- EFFECTS -----------------------------------------------------------

function druid_4_modifier_metamorphosis:PlayEfxStart()
	local string = "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then self.parent:EmitSound("Hero_Lycan.Shapeshift.Cast") end
end

function druid_4_modifier_metamorphosis:PlayEfxEnd()
	local string = "particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then self.parent:EmitSound("General.Illusion.Destroy") end
end