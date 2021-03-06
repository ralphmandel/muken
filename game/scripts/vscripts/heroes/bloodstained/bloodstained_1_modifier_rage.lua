bloodstained_1_modifier_rage = class({})

function bloodstained_1_modifier_rage:IsHidden()
    return false
end

function bloodstained_1_modifier_rage:IsPurgable()
    return true
end

---------------------------------------------------------------------------------------------------

function bloodstained_1_modifier_rage:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.health = self.parent:GetHealth()
	self.stack = 0
	self.incoming = 0
	self.min_health = 0
	self.magic_immunity = false

	self.gain = self.ability:GetSpecialValueFor("gain")
	local consume = self.ability:GetSpecialValueFor("consume") * 0.01
	self.ability:RemoveBonus("_1_STR", self.parent)

	-- UP 1.22
	if self.ability:GetRank(22) then
		consume = consume + 10
		self.gain = 0.6
	end

	-- UP 1.31
	if self.ability:GetRank(31) then
		local radius = self.ability:GetCastRange(self.caster:GetOrigin(), nil)
		self:PlayEfxBerserk(radius)

		self.units = FindUnitsInRadius(
			self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			0, 2, false
		)

		for _,unit in pairs(self.units) do
			unit:SetForceAttackTarget(self.parent)
			unit:MoveToTargetToAttack(self.parent)
			unit:AddNewModifier(self.caster, self.ability, "bloodstained_1_modifier_berserk", {})
		end
	end

	-- UP 1.41
	if self.ability:GetRank(41) then
		self.parent:Purge(false, true, false, false, false)
		self.magic_immunity = true
		self:PlayEfxBKB()
	end

	-- UP 1.42
	if self.ability:GetRank(42) then
		self.min_health = 1
	end

	if IsServer() then
		self:SetStackCount(self.stack)
		self:PlayEfxStart()
	end

	local iDesiredHealthValue = self.parent:GetHealth() - (self.parent:GetHealth() * consume)
	self.parent:ModifyHealth(iDesiredHealthValue, self.ability, false, 0)
	self:ApplyGain()

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "bloodstained_1_modifier_rage_status_efx", true) end
end

function bloodstained_1_modifier_rage:OnRefresh( kv )
	self.health = self.parent:GetHealth()
	self.stack = 0

    self.gain = self.ability:GetSpecialValueFor("gain")
	local consume = self.ability:GetSpecialValueFor("consume") * 0.01
	self.ability:RemoveBonus("_1_STR", self.parent)

	-- UP 1.22
	if self.ability:GetRank(22) then
		consume = consume + 10
		self.gain = 0.6
	end

	-- UP 1.41
	if self.ability:GetRank(41) then
		self.parent:Purge(false, true, false, false, false)
		self.magic_immunity = true
		self:PlayEfxBKB()
	end

	-- UP 1.42
	if self.ability:GetRank(42) then
		self.min_health = 1
	end

	if IsServer() then
		self:SetStackCount(self.stack)
		self:PlayEfxStart()
	end

	local iDesiredHealthValue = self.parent:GetHealth() - (self.parent:GetHealth() * consume)
	self.parent:ModifyHealth(iDesiredHealthValue, self.ability, false, 0)
	self:ApplyGain()
end

function bloodstained_1_modifier_rage:OnRemoved( kv )
	if IsServer() then self.parent:StopSound("Bloodstained.rage") end
	if self.efx_bkb then ParticleManager:DestroyParticle(self.efx_bkb, false) end
	
	local pos_time = self.ability:GetSpecialValueFor("pos_time")
	self.ability:RemoveBonus("_1_STR", self.parent)
	if self:GetStackCount() > 0 then self.ability:AddBonus("_1_STR", self.parent, self:GetStackCount(), 0, pos_time) end

	self.ability:SetActivated(true)
    self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))

	if self.units then
		for _,unit in pairs(self.units) do
			if IsValidEntity(unit) then
				unit:RemoveModifierByNameAndCaster("bloodstained_1_modifier_berserk", self.caster)
			end
		end
	end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "bloodstained_1_modifier_rage_status_efx", false) end
end
---------------------------------------------------------------------------------------------------

function bloodstained_1_modifier_rage:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = self.magic_immunity,
	}

	return state
end


function bloodstained_1_modifier_rage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_HERO_KILLED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}

	return funcs
end

function bloodstained_1_modifier_rage:GetMinHealth()
    return self.min_health
end

function bloodstained_1_modifier_rage:OnAttackLanded(keys)
    if keys.attacker ~= self.parent then return end
	if keys.attacker:IsIllusion() then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	-- UP 1.21
	if self.ability:GetRank(21) then
		local cleaveatk = DoCleaveAttack(
			self.parent, keys.target, self.ability, keys.damage, 100, 400, 500,
			"particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength_crit.vpcf"
		)
	end
end

function bloodstained_1_modifier_rage:OnHeroKilled(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return	end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	-- UP 1.42
	if self.ability:GetRank(42) then
		local add_time = self:GetRemainingTime() + (self.ability:GetSpecialValueFor("duration") * 0.5)
		self:SetDuration(self.ability:CalcStatus(add_time, self.caster, self.parent), true)
	end
end

function bloodstained_1_modifier_rage:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	self:ApplyGain()
end

function bloodstained_1_modifier_rage:GetModifierIncomingDamage_Percentage(keys)
	self.health = self.parent:GetHealth() + self.health

	if keys.attacker:IsBaseNPC() == false then return self.incoming end
	if keys.attacker == self.parent then return 0 end
    return self.incoming
end

function bloodstained_1_modifier_rage:ApplyGain()
	if self.parent:IsAlive() == false then return end
	local max_health = self.parent:GetMaxHealth()
	local mods = self.parent:FindAllModifiersByName("bloodstained_u_modifier_hp_bonus")
	for _,hp_mod in pairs(mods) do max_health = max_health - hp_mod:GetStackCount() end

	local damage_lost = self.health - self.parent:GetHealth()
	if damage_lost < 1 then return end

	local percent_lost = (damage_lost / max_health) * 100
	local bonus_str = math.floor(percent_lost / self.gain)

	self.health = damage_lost - (bonus_str * self.gain * max_health * 0.01)

	if bonus_str > 0 then
		self.stack = self.stack + bonus_str
		if IsServer() then
			self:SetStackCount(self.stack)
		end

		self.ability:RemoveBonus("_1_STR", self.parent)
		if self:GetStackCount() > 0 then self.ability:AddBonus("_1_STR", self.parent, self:GetStackCount(), 0, nil) end
	end
end

--------------------------------------------------------------------------------------------------

function bloodstained_1_modifier_rage:GetEffectName()
	return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_debuff.vpcf"
end

function bloodstained_1_modifier_rage:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function bloodstained_1_modifier_rage:GetStatusEffectName()
	return "particles/econ/items/lifestealer/lifestealer_immortal_backbone/status_effect_life_stealer_immortal_rage.vpcf"
end

function bloodstained_1_modifier_rage:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function bloodstained_1_modifier_rage:PlayEfxStart()
	if IsServer() then
		self.parent:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
		self.parent:EmitSound("Bloodstained.fury")
		self.parent:EmitSound("Bloodstained.rage")
	end
end

function bloodstained_1_modifier_rage:PlayEfxBKB()
	if self.efx_bkb then ParticleManager:DestroyParticle(self.efx_bkb, false) end

	local particle_cast = "particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/lifestealer_immortal_backbone_gold_rage.vpcf"
	self.efx_bkb = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.efx_bkb, 0, self.parent:GetOrigin())
	self:AddParticle(self.efx_bkb, false, false, -1, false, true)
end

function bloodstained_1_modifier_rage:PlayEfxBerserk(radius)
	local particle_cast = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_call.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(radius, radius, radius))
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end