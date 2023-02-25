striker_2_modifier_shield = class({})

function striker_2_modifier_shield:IsHidden() return false end
function striker_2_modifier_shield:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_2_modifier_shield:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local hits = self.ability:GetSpecialValueFor("hits")
	if hits == 6 then self:PlayEfxKnives() end

	if self.ability:GetSpecialValueFor("special_burn_radius") > 0 then
		self.parent:AddNewModifier(self.parent, self.ability, "striker_2_modifier_burn_aura", {})
	end

	if self.ability:GetSpecialValueFor("special_spell_immunity") == 1 then
		self:PlayEfxBKB()
	end

	if IsServer() then
		self:SetStackCount(self.ability:GetSpecialValueFor("hits"))
		self:PlayEfxStart()
	end
end

function striker_2_modifier_shield:OnRefresh(kv)
	local hits = self.ability:GetSpecialValueFor("hits")
	if hits == 6 then self:PlayEfxKnives() end

	if self.ability:GetSpecialValueFor("special_burn_radius") > 0 then
		self.parent:AddNewModifier(self.parent, self.ability, "striker_2_modifier_burn_aura", {})
	end

	if self.ability:GetSpecialValueFor("special_spell_immunity") == 1 then
		self:PlayEfxBKB()
	end

	if IsServer() then
		self:SetStackCount(self.ability:GetSpecialValueFor("hits"))
		self:PlayEfxStart()
	end
end

function striker_2_modifier_shield:OnRemoved()
	if self.shield_particle then ParticleManager:DestroyParticle(self.shield_particle, false) end
	if self.bkb_particle then ParticleManager:DestroyParticle(self.bkb_particle, false) end
	if self.knives_particle then ParticleManager:DestroyParticle(self.knives_particle, false) end
	if IsServer() then self.parent:EmitSound("Hero_Medusa.ManaShield.Off") end

	RemoveBonus(self.ability, "_2_DEF", self.parent)

	local mod = self.parent:FindAllModifiersByName("striker_2_modifier_burn_aura")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_2_modifier_shield:CheckState()
	local state = {}

	if self:GetAbility():GetSpecialValueFor("special_spell_immunity") == 1 then
		table.insert(state, MODIFIER_STATE_MAGIC_IMMUNE, true)
	end

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
	self:DecrementStackCount()
end

function striker_2_modifier_shield:GetModifierPhysical_ConstantBlock(keys)
  if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return end

  self:PlayEfxBlocked(keys)
	self:ApplyCounter(keys)

	if self:GetStackCount() < 1 then
		self:Destroy()
		return keys.damage
	end

    return keys.damage
end

-- UTILS -----------------------------------------------------------

function striker_2_modifier_shield:ApplyCounter(keys)
	local return_percent = self.ability:GetSpecialValueFor("special_return")
	if return_percent == 0 then return end
	if keys.attacker == nil then return end

	local damageTable = {
		victim = keys.attacker,
		attacker = self.caster,
		damage = keys.damage * return_percent * 0.01,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = self.ability,
		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
	}

	if keys.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then	
		ApplyDamage(damageTable)
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

function striker_2_modifier_shield:PlayEfxBlocked(keys)
	local particle_cast = "particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(keys.damage, 0, 0 ))
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