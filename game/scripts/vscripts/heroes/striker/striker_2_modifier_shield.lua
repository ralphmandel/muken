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

	local hits = self.ability:GetSpecialValueFor("hits")
	self.chance_hero = self.ability:GetSpecialValueFor("chance_hero")
	self.chance = self.ability:GetSpecialValueFor("chance")

	if IsServer() then
		self:SetStackCount(hits)
		self:PlayEfxStart()
	end
end

function striker_2_modifier_shield:OnRefresh(kv)
	local hits = self.ability:GetSpecialValueFor("hits")
	self.chance_hero = self.ability:GetSpecialValueFor("chance_hero")
	self.chance = self.ability:GetSpecialValueFor("chance")
	
	if IsServer() then
        self:SetStackCount(hits)
        self:PlayEfxStart()
    end
end

function striker_2_modifier_shield:OnRemoved()
	if self.shield_particle ~= nil then ParticleManager:DestroyParticle(self.shield_particle, false) end
	if IsServer() then self.parent:EmitSound("Hero_Medusa.ManaShield.Off") end
end

-- API FUNCTIONS -----------------------------------------------------------

-- function striker_2_modifier_shield:CheckState()
-- 	local state = {
-- 		[MODIFIER_STATE_MAGIC_IMMUNE] = true
-- 	}

-- 	return state
-- end

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

-- EFFECTS -----------------------------------------------------------

function striker_2_modifier_shield:PlayEfxStart()
    if self.shield_particle ~= nil then ParticleManager:DestroyParticle(self.shield_particle, false) end
	self.shield_particle = ParticleManager:CreateParticle("particles/econ/items/lanaya/ta_ti9_immortal_shoulders/ta_ti9_refraction.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.shield_particle, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.shield_particle, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.shield_particle, 5, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	self:AddParticle(self.shield_particle, false, false, -1, true, false)

    if IsServer() then self.parent:EmitSound("Hero_TemplarAssassin.Refraction") end
end

function striker_2_modifier_shield:PlayEfxBlocked(damage)
    --local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_blocked.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

	local particle_cast = "particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(damage, 0, 0 ))
	ParticleManager:ReleaseParticleIndex(effect_cast)

    if IsServer() then self.parent:EmitSound("Hero_Striker.Shield.Block") end
end