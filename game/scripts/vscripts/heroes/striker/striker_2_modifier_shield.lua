striker_2_modifier_shield = class({})

function striker_2_modifier_shield:IsHidden()
	return false
end

function striker_2_modifier_shield:IsPurgable()
	return true
end

function striker_2_modifier_shield:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_2_modifier_shield:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.magic_immunity = false

	local hits = self.ability:GetSpecialValueFor("hits")
	self.chance_hero = self.ability:GetSpecialValueFor("chance_hero")
	self.chance = self.ability:GetSpecialValueFor("chance")

	-- UP 2.11
	if self.ability:GetRank(11) then
		self.ability:AddBonus("_2_DEF", self.parent, 25, 0, nil)
	end

	-- UP 2.21
	if self.ability:GetRank(21) then
		self:PlayEfxKnives()
	end

	-- UP 2.31
	if self.ability:GetRank(31) then
		self.parent:AddNewModifier(self.caster, self.ability, "striker_2_modifier_burn_aura", {})
	end

	-- UP 2.41
	if self.ability:GetRank(41) then
		self.magic_immunity = true
		self:PlayEfxBKB()
	end

	if IsServer() then
		self:SetStackCount(hits)
		self:PlayEfxStart()
	end
end

function striker_2_modifier_shield:OnRefresh(kv)
	local hits = self.ability:GetSpecialValueFor("hits")
	self.chance_hero = self.ability:GetSpecialValueFor("chance_hero")
	self.chance = self.ability:GetSpecialValueFor("chance")

	-- UP 2.11
	if self.ability:GetRank(11) then
		self.ability:RemoveBonus("_2_DEF", self.parent)
		self.ability:AddBonus("_2_DEF", self.parent, 25, 0, nil)
	end

	-- UP 2.21
	if self.ability:GetRank(21) then
		self:PlayEfxKnives()
	end

	-- UP 2.31
	if self.ability:GetRank(31) then
		self.parent:AddNewModifier(self.caster, self.ability, "striker_2_modifier_burn_aura", {})
	end

	-- UP 2.41
	if self.ability:GetRank(41) then
		self.magic_immunity = true
		self:PlayEfxBKB()
	end
	
	if IsServer() then
        self:SetStackCount(hits)
        self:PlayEfxStart()
    end
end

function striker_2_modifier_shield:OnRemoved()
	if self.shield_particle then ParticleManager:DestroyParticle(self.shield_particle, false) end
	if self.bkb_particle then ParticleManager:DestroyParticle(self.bkb_particle, false) end
	if self.knives_particle then ParticleManager:DestroyParticle(self.knives_particle, false) end
	if IsServer() then self.parent:EmitSound("Hero_Medusa.ManaShield.Off") end

	self.ability:RemoveBonus("_2_DEF", self.parent)
	self.parent:RemoveModifierByNameAndCaster("striker_2_modifier_burn_aura", self.caster)
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_2_modifier_shield:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = self.magic_immunity
	}

	return state
end

function striker_2_modifier_shield:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
	}

	return funcs
end

function striker_2_modifier_shield:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	self:DecrementLayer(keys.attacker)
end

function striker_2_modifier_shield:GetModifierPhysical_ConstantBlock(keys)
    if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return end

	-- UP 2.21
	if self.ability:GetRank(21) then
		self:ApplyCounter(keys.attacker, keys.damage_flags, keys.damage)
	end

    self:PlayEfxBlocked(keys.damage)

	if self:GetStackCount() < 1 then
		self:Destroy()
		return keys.damage
	end

    return keys.damage
end

-- UTILS -----------------------------------------------------------

function striker_2_modifier_shield:DecrementLayer(attacker)
	local chance = self.chance_hero

	if attacker:IsIllusion()
	or attacker:IsHero() == false then
		chance = self.chance
	end
	
	if RandomFloat(1, 100) <= chance then
		self:DecrementStackCount()
	end
end

function striker_2_modifier_shield:ApplyCounter(attacker, damage_flags, damage)
	if attacker == nil then return end
	local base_stats = attacker:FindAbilityByName("base_stats")
	if base_stats == nil then return end
	if base_stats.has_crit == false then return end

	local damageTable = {
		victim = attacker,
		attacker = self.caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = self.ability,
		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
	}

	if damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then	
		ApplyDamage(damageTable)

		if attacker:IsAlive() then
			attacker:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
				duration = self.ability:CalcStatus(1, self.caster, attacker)
			})
		end
	end
end

-- EFFECTS -----------------------------------------------------------

function striker_2_modifier_shield:PlayEfxStart()
    if self.shield_particle then ParticleManager:DestroyParticle(self.shield_particle, false) end
	self.shield_particle = ParticleManager:CreateParticle("particles/econ/items/lanaya/ta_ti9_immortal_shoulders/ta_ti9_refraction.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.shield_particle, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.shield_particle, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.shield_particle, 5, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	self:AddParticle(self.shield_particle, false, false, -1, true, false)

    if IsServer() then self.parent:EmitSound("Hero_TemplarAssassin.Refraction") end
end

function striker_2_modifier_shield:PlayEfxBlocked(damage)
	local particle_cast = "particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(damage, 0, 0 ))
	ParticleManager:ReleaseParticleIndex(effect_cast)

    if IsServer() then self.parent:EmitSound("Hero_Striker.Shield.Block") end
end

function striker_2_modifier_shield:PlayEfxBKB()
	if self.bkb_particle then ParticleManager:DestroyParticle(self.bkb_particle, false) end
	self.bkb_particle = ParticleManager:CreateParticle("particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.bkb_particle, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	self:AddParticle(self.bkb_particle, false, false, -1, true, false)
end

function striker_2_modifier_shield:PlayEfxKnives()
	if self.knives_particle then ParticleManager:DestroyParticle(self.knives_particle, false) end
	self.knives_particle = ParticleManager:CreateParticle("particles/econ/items/spectre/spectre_arcana/spectre_arcana_radiance_owner_body.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.knives_particle, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.knives_particle, 1, self.parent:GetOrigin())
	self:AddParticle(self.knives_particle, false, false, -1, true, false)
end