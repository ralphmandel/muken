striker_6_modifier_return = class({})

function striker_6_modifier_return:IsHidden()
	return true
end

function striker_6_modifier_return:IsPurgable()
	return false
end

function striker_6_modifier_return:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_6_modifier_return:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.swap = self.ability:GetSpecialValueFor("swap")

	self:ReturnHammer()
end

function striker_6_modifier_return:OnRefresh(kv)
end

function striker_6_modifier_return:OnRemoved()
	if self.ability.autocast == false then
		self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	end

	self.ability:SetActivated(true)
	self.ability:ResetHammer()
	self:CheckHeal()
	self:SetHammer(1, false, "")
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_6_modifier_return:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}

	return funcs
end

function striker_6_modifier_return:GetModifierDamageOutgoing_Percentage(keys)
	return -self.swap
end

function striker_6_modifier_return:GetModifierAttackSpeedPercentage(keys)
	return self.swap
end

-- UTILS -----------------------------------------------------------

function striker_6_modifier_return:CheckHeal()
	local heal_return = self.ability:GetSpecialValueFor("heal_return")

	-- UP 6.41
	if self.ability:GetRank(41) then
		heal_return = heal_return + 15
	end

	local heal = self.ability.damage_taken * heal_return * 0.01
	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then heal = heal * base_stats:GetHealPower() end
    if heal >= 1 then self.parent:Heal(heal, self.ability) end
end

function striker_6_modifier_return:ReturnHammer()
	if self.ability.pfx_hammer_ground == nil then return end
	if self.ability.hammer_loc == nil then return end
	self.ability:StopEfxHammerGround()

	local info = {
		Target = self.caster,
		vSourceLoc = self.ability.hammer_loc,
		Ability = self.ability,	
		
		EffectName = "particles/econ/items/dawnbreaker/dawnbreaker_2022_cc/dawnbreaker_2022_cc_celestial_hammer_projectile_return.vpcf",
		iMoveSpeed = 1500,
		bDodgeable = false,
	}

	self.ability.hammer_return = ProjectileManager:CreateTrackingProjectile(info)
end

function striker_6_modifier_return:SetHammer(iMode, bHide, activity)
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