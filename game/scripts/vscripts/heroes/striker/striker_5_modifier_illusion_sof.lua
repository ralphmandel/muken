striker_5_modifier_illusion_sof = class({})

function striker_5_modifier_illusion_sof:IsHidden()
	return false
end

function striker_5_modifier_illusion_sof:IsPurgable()
	return false
end

function striker_5_modifier_illusion_sof:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_5_modifier_illusion_sof:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.swap = self.ability:GetSpecialValueFor("swap")
	self:SetHammer(2, true, "no_hammer")
end

function striker_5_modifier_illusion_sof:OnRefresh(kv)
end

function striker_5_modifier_illusion_sof:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_5_modifier_illusion_sof:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function striker_5_modifier_illusion_sof:GetModifierDamageOutgoing_Percentage(keys)
	return -self.swap
end

function striker_5_modifier_illusion_sof:GetModifierAttackSpeedPercentage(keys)
	return self.swap
end

function striker_5_modifier_illusion_sof:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	local min_dmg = self.ability:GetAbilityDamage() - 2
	local max_dmg = self.ability:GetAbilityDamage() + 2

	ApplyDamage({
		victim = keys.target, attacker = self.caster,
		damage = RandomInt(min_dmg, max_dmg),
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	})
end

-- UTILS -----------------------------------------------------------

function striker_5_modifier_illusion_sof:SetHammer(iMode, bHide, activity)
	local sonicblow = self.parent:FindAbilityByName("striker_1__blow")
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	local base_hero_mod = self.parent:FindModifierByName("base_hero_mod")


	if sonicblow and base_hero_mod and cosmetics then
		sonicblow:CheckAbilityCharges(iMode)
		cosmetics:HideCosmetic("models/items/dawnbreaker/first_light_weapon/first_light_weapon.vmdl", bHide)
		base_hero_mod:ChangeActivity(activity)

		if bHide then
			base_hero_mod:ChangeSounds("Hero_Marci.Flurry.PreAttack", nil, "Hero_Marci.Flurry.Attack")
		else
			base_hero_mod:LoadSounds()
		end
	end
end

-- EFFECTS -----------------------------------------------------------

function striker_5_modifier_illusion_sof:GetEffectName()
	return "particles/striker/ein_sof/striker_ein_sof_illusion.vpcf"
end

function striker_5_modifier_illusion_sof:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end