bald_u_modifier_vitality = class({})

function bald_u_modifier_vitality:IsHidden() return false end
function bald_u_modifier_vitality:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_u_modifier_vitality:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.con = self.ability:GetSpecialValueFor("con")
	self.regen = self.ability:GetSpecialValueFor("regen_out")
	self.delay = 0

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bald_u_modifier_vitality_status_efx", true) end

	if IsServer() then
		self:SetStackCount(self.con)
		self:StartIntervalThink(1)
		self:PlayEfxStart()
	end
end

function bald_u_modifier_vitality:OnRefresh(kv)
	self.con = self.ability:GetSpecialValueFor("con")
	self.regen = self.ability:GetSpecialValueFor("regen_out")
	self.delay = 0

	if IsServer() then
		self:SetStackCount(self.con)
		self:StartIntervalThink(1)
		self:PlayEfxStart()
	end
end

function bald_u_modifier_vitality:OnRemoved()
	self.ability:RemoveBonus("_1_CON", self.parent)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bald_u_modifier_vitality_status_efx", false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_u_modifier_vitality:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACKED
	}

	return funcs
end

function bald_u_modifier_vitality:GetModifierConstantHealthRegen(keys)
	return self:GetParent():GetMaxHealth() * self.regen * 0.01
end

function bald_u_modifier_vitality:OnTakeDamage(keys)
	if keys.unit == self.parent then
		self.delay = self.ability:GetSpecialValueFor("delay")
		self.regen = self.ability:GetSpecialValueFor("regen_in")

		if self.effect_cast then
			ParticleManager:SetParticleControl(self.effect_cast, 15, Vector(self.regen * 10, 0, 0))
		end
	end

	if keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
		self:ApplyLifesteal(keys)
	end
end

function bald_u_modifier_vitality:OnAttacked(keys)
	self:ApplyLifesteal(keys)
end

function bald_u_modifier_vitality:OnIntervalThink()
	if self.delay > 0 then
		self.regen = self.ability:GetSpecialValueFor("regen_in")
		self.delay = self.delay - 1
		self.con = self.con - 0.5
	else
		self.regen = self.ability:GetSpecialValueFor("regen_out")
		self.con = self.con - 1
	end

	if self.effect_cast then ParticleManager:SetParticleControl(self.effect_cast, 15, Vector(self.regen * 10, 0, 0)) end

	if IsServer() then
		self:SetStackCount(math.ceil(self.con))
		self:StartIntervalThink(1)
	end
end

function bald_u_modifier_vitality:OnStackCountChanged(old)
	self.ability:RemoveBonus("_1_CON", self.parent)

	if self:GetStackCount() > 0 then
		self.ability:AddBonus("_1_CON", self.parent, self:GetStackCount(), 0, nil)
	else
		self:Destroy()
		return
	end

	if old > self:GetStackCount() then
		if IsServer() then self.parent:EmitSound("Hero_OgreMagi.Bloodlust.Target.FP") end
	end
end

-- UTILS -----------------------------------------------------------

function bald_u_modifier_vitality:ApplyLifesteal(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end

	local lifesteal = keys.original_damage * self.ability:GetSpecialValueFor("lifesteal") * 0.01
	
	if lifesteal > 0 then
		keys.attacker:Heal(lifesteal, self.ability)
		self:PlayEfxLifesteal(keys.attacker)
	end
end

-- EFFECTS -----------------------------------------------------------

function bald_u_modifier_vitality:GetStatusEffectName()
    return "particles/bald/bald_vitality/bald_vitality_status_efx.vpcf"
end

function bald_u_modifier_vitality:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function bald_u_modifier_vitality:PlayEfxStart()
	local particle_cast = "particles/bald/bald_vitality/bald_vitality_buff.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(self.effect_cast, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(1,0,0), true)
	ParticleManager:SetParticleControl(self.effect_cast, 15, Vector(self.regen * 10, 0, 0))
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_OgreMagi.Bloodlust.Target") end
end

function bald_u_modifier_vitality:PlayEfxLifesteal(attacker)
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControl(effect_cast, 1, attacker:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end