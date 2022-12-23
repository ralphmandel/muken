striker_5_modifier_return = class({})

function striker_5_modifier_return:IsHidden() return true end
function striker_5_modifier_return:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_5_modifier_return:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.swap = self.ability:GetSpecialValueFor("swap")
	self:ReturnHammer()
end

function striker_5_modifier_return:OnRefresh(kv)
end

function striker_5_modifier_return:OnRemoved()
	if self.ability.autocast == false then
		self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	end
	
	if self.ability.total_damage > 0 then
		if self.ability.total_damage > self.parent:GetHealth() then
			self.parent:Kill(self.ability, self.ability.last_attacker)
		else
			local hp = self.parent:GetHealth() - self.ability.total_damage
			self.parent:ModifyHealth(hp, self.ability, false, 0)
		end
	end

	self.ability:SetActivated(true)
	self.ability:ResetHammer()
	self:SetHammer(1, false, "")
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_5_modifier_return:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function striker_5_modifier_return:GetModifierDamageOutgoing_Percentage(keys)
	return -self.swap
end

function striker_5_modifier_return:GetModifierAttackSpeedPercentage(keys)
	return self.swap
end

function striker_5_modifier_return:GetModifierIncomingDamage_Percentage(keys)
	local incoming = self.ability:GetSpecialValueFor("special_damage_taken")

	if incoming < 0 then
		self.ability.last_attacker = keys.attacker
		self.ability.total_damage = self.ability.total_damage + keys.damage
	end
	
	return incoming
end

function striker_5_modifier_return:OnAttacked(keys)
	if keys.attacker ~= self.parent then return end
	local heal = keys.original_damage * self.ability:GetSpecialValueFor("special_lifesteal") * 0.01
	
	if heal > 0 then
		keys.attacker:Heal(heal, self.ability)
		self:PlayEfxLifesteal(keys.attacker)
	end
end

function striker_5_modifier_return:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	local min_dmg = self.ability:GetSpecialValueFor("damage_hit") * 0.8
	local max_dmg = self.ability:GetSpecialValueFor("damage_hit") * 1.2

	ApplyDamage({
		victim = keys.target, attacker = self.caster,
		damage = RandomInt(min_dmg, max_dmg),
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	})
end

-- UTILS -----------------------------------------------------------

function striker_5_modifier_return:ReturnHammer()
	if self.ability.pfx_hammer_ground == nil then return end
	if self.ability.hammer_loc == nil then return end
	self.ability:StopEfxHammerGround()

	local info = {
		Target = self.caster,
		vSourceLoc = self.ability.hammer_loc,
		Ability = self.ability,	
		
		EffectName = "particles/econ/items/dawnbreaker/dawnbreaker_judgement_of_light/dawnbreaker_judgement_of_light_hammer_return.vpcf",
		iMoveSpeed = 1500,
		bDodgeable = false,
	}

	self.ability.hammer_return = ProjectileManager:CreateTrackingProjectile(info)
end

function striker_5_modifier_return:SetHammer(iMode, bHide, activity)
	local sonicblow = self.parent:FindAbilityByName("striker_1__blow")
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	local base_hero_mod = self.parent:FindModifierByName("base_hero_mod")


	if sonicblow and base_hero_mod and cosmetics then
		cosmetics:HideCosmetic("models/items/dawnbreaker/judgment_of_light_weapon/judgment_of_light_weapon.vmdl", bHide)
		base_hero_mod:ChangeActivity(activity)

		if bHide then
			base_hero_mod:ChangeSounds("Hero_Ursa.PreAttack", nil, "Hero_Ursa.Attack")
		else
			base_hero_mod:LoadSounds()
		end
	end
end

-- EFFECTS -----------------------------------------------------------

function striker_5_modifier_return:GetEffectName()
	return "particles/striker/ein_sof/striker_ein_sof_buff.vpcf"
end

function striker_5_modifier_return:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function striker_5_modifier_return:PlayEfxLifesteal(attacker)
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControl(effect_cast, 1, attacker:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end