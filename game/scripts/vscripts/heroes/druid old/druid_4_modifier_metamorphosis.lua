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
	return DOTA_UNIT_TARGET_HERO
end

function druid_4_modifier_metamorphosis:GetAuraRadius()
	return self:GetAbility():GetAOERadius()
end

function druid_4_modifier_metamorphosis:GetAuraEntityReject(hEntity)
	return hEntity:IsHero()
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_4_modifier_metamorphosis:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.same_target = nil
	self.stun = false
	local fear = false

	self.heal_power = self.ability:GetSpecialValueFor("heal_power")
	local con = self.ability:GetSpecialValueFor("con")

	-- UP 4.11
	if self.ability:GetRank(11) then
		self:ApplyFear()
		fear = true
	end

	AddBonus(self.ability, "_1_CON", self.parent, con, 0, nil)
	self:HideItens(true)

	local group = {[1] = "0", [2] = "1", [3] = "2"}
	self.parent:SetMaterialGroup(group[RandomInt(1, 3)])
	self.parent:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	self.parent:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

	if IsServer() then self:PlayEfxStart(fear) end
end

function druid_4_modifier_metamorphosis:OnRefresh(kv)
	local fear = false

	-- UP 4.11
	if self.ability:GetRank(11) then
		self:ApplyFear()
		fear = true
	end

	local group = {[1] = "0", [2] = "1", [3] = "2"}
	self.parent:SetMaterialGroup(group[RandomInt(1, 3)])
	self.parent:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

	if self.effect_aura then ParticleManager:DestroyParticle(self.effect_aura, true) end
	if IsServer() then self:PlayEfxStart(fear) end
end

function druid_4_modifier_metamorphosis:OnRemoved()
	if IsServer() then self:PlayEfxEnd() end

	RemoveBonus(self.ability, "_1_CON", self.parent)
	self:HideItens(false)

	self.parent:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_4_modifier_metamorphosis:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function druid_4_modifier_metamorphosis:GetModifierAttackRangeOverride()
    return 130
end

function druid_4_modifier_metamorphosis:GetModifierHealAmplify_PercentageTarget()
    return self.heal_power
end

function druid_4_modifier_metamorphosis:GetModifierHPRegenAmplify_Percentage(keys)
    return self.heal_power
end

function druid_4_modifier_metamorphosis:GetModifierModelChange()
	return "models/items/lone_druid/true_form/dark_wood_true_form/dark_wood_true_form.vmdl"
end

function druid_4_modifier_metamorphosis:OnIntervalThink()
	self.stun = false
	self:StartIntervalThink(-1)
end

function druid_4_modifier_metamorphosis:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

	if self.same_target ~= keys.target then
		self.parent:RemoveModifierByNameAndCaster("druid_4_modifier_strength", self.caster)
		self.same_target = keys.target
	end

	-- UP 4.12
	if self.ability:GetRank(12) then
		self.parent:AddNewModifier(self.caster, self.ability, "druid_4_modifier_strength", {
			duration = 5
		})
	end

	-- UP 4.22
	if self.ability:GetRank(22) and self.stun == false then
		self:StartIntervalThink(-1)
		self:StartIntervalThink(10)
		self.stun = true

		ApplyDamage({
			attacker = self.caster, victim = keys.target, ability = self.ability,
			damage = self.parent:GetMaxHealth() * 0.04, damage_type = DAMAGE_TYPE_PHYSICAL
		})

		keys.target:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
			duration = CalcStatus(2, self.caster, keys.target)
		})
	end
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

function druid_4_modifier_metamorphosis:ApplyFear()
	if IsServer() then self.parent:EmitSound("Hero_LoneDruid.SavageRoar.Cast") end
	
	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 350,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,unit in pairs(units) do		
		unit:AddNewModifier(self.caster, self.ability, "druid_4_modifier_fear", {
			duration = CalcStatus(4, self.caster, unit)
		})
	end
end

-- EFFECTS -----------------------------------------------------------

function druid_4_modifier_metamorphosis:PlayEfxStart(bFear)
	local string = "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	local string_2 = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
	local shake = ParticleManager:CreateParticle(string_2, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(shake, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(shake, 1, Vector(500, 0, 0))

	local string_3 = "particles/druid/druid_ult_passive.vpcf"
	self.effect_aura = ParticleManager:CreateParticle(string_3, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_aura, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_aura, 1, Vector(self.ability:GetAOERadius(), 0, 0))
	self:AddParticle(self.effect_aura, false, false, -1, false, false)

	if bFear then
		local string_4 = "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf"
		local particle2 = ParticleManager:CreateParticle(string_4, PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(particle2, 0, self.parent:GetOrigin())
		ParticleManager:ReleaseParticleIndex(particle2)		
	end

	if IsServer() then self.parent:EmitSound("Hero_Lycan.Shapeshift.Cast") end
end

function druid_4_modifier_metamorphosis:PlayEfxEnd()
	local string = "particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then self.parent:EmitSound("General.Illusion.Destroy") end
end