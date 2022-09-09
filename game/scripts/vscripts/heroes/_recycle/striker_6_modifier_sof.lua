striker_6_modifier_sof = class({})

function striker_6_modifier_sof:IsHidden()
	return false
end

function striker_6_modifier_sof:IsPurgable()
	return false
end

function striker_6_modifier_sof:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_6_modifier_sof:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.ability.damage_taken = 0

	self.swap = self.ability:GetSpecialValueFor("swap")
	self.sof_duration = self.ability:GetSpecialValueFor("sof_duration")
	self:SetHammer(2, true, "no_hammer")

	if IsServer() then
		self:StartIntervalThink(0.1)
		self.parent:EmitSound("Hero_Striker.Sof.Start")
		self.ability:EndCooldown()
		self.ability:SetActivated(false)
	end
end

function striker_6_modifier_sof:OnRefresh(kv)
	self.swap = self.ability:GetSpecialValueFor("swap")
	self.sof_duration = self.ability:GetSpecialValueFor("sof_duration")

	if IsServer() then self.parent:EmitSound("Hero_Striker.Sof.Start") end
end

function striker_6_modifier_sof:OnRemoved()
	self.parent:RemoveModifierByNameAndCaster("striker_6_modifier_sof_effect", self.caster)

	if self.parent:IsAlive() then
		self.parent:AddNewModifier(self.caster, self.ability, "striker_6_modifier_return", {duration = 5})
	else
		if self.ability.autocast == false then
			self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
		end

		self.ability:SetActivated(true)
		self.ability:ResetHammer()
		self:SetHammer(1, false, "")
	end

	if IsServer() then self.parent:EmitSound("Hero_Striker.Sof.End") end
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_6_modifier_sof:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function striker_6_modifier_sof:GetModifierDamageOutgoing_Percentage(keys)
	return -self.swap
end

function striker_6_modifier_sof:GetModifierAttackSpeedPercentage(keys)
	return self.swap
end

function striker_6_modifier_sof:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end

	-- UP 6.32
	if self.ability:GetRank(32) then
		ApplyDamage({
			victim = keys.target, attacker = self.caster,
			damage = RandomInt(10, 15), damage_type = DAMAGE_TYPE_PURE,
			ability = self.ability
		})
	end
end

function striker_6_modifier_sof:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end

	self.ability.damage_taken = self.ability.damage_taken + keys.damage
end

function striker_6_modifier_sof:OnIntervalThink()
	if self.parent:IsAttacking() then
		self:SetDuration(self:GetRemainingTime() - 0.1, false)
		self.parent:AddNewModifier(self.caster, self.ability, "striker_6_modifier_sof_effect", {
			duration = self.sof_duration
		})
	end

	if IsServer() then self:StartIntervalThink(0.1) end
end

-- UTILS -----------------------------------------------------------

function striker_6_modifier_sof:SetHammer(iMode, bHide, activity)
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

function striker_6_modifier_sof:GetEffectName()
	return "particles/striker/ein_sof/striker_ein_sof_buff.vpcf"
end

function striker_6_modifier_sof:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end