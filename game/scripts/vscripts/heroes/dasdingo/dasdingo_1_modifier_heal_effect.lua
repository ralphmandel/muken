dasdingo_1_modifier_heal_effect = class({})

function dasdingo_1_modifier_heal_effect:IsHidden()
	return false
end

function dasdingo_1_modifier_heal_effect:IsPurgable()
	return false
end

function dasdingo_1_modifier_heal_effect:IsDebuff()
	if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		return true
	end

	return false
end

-----------------------------------------------------------

function dasdingo_1_modifier_heal_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.heal = self.ability:GetSpecialValueFor("heal")
	self.intervals = self.ability:GetSpecialValueFor("intervals") / 0.25
	self.count = 0
	self.regen = 0

	-- UP 1.2
	if self.ability:GetRank(2) then
		self.reset = 0
	end

	-- UP 1.6
	if self.ability:GetRank(6) then
		self.heal = self.heal + 5
		self.intervals = self.intervals - 1
	end

	if self.caster:GetTeamNumber() ~= self.parent:GetTeamNumber() then return end

	self:StartIntervalThink(0.25)
end

function dasdingo_1_modifier_heal_effect:OnRefresh(kv)
end

function dasdingo_1_modifier_heal_effect:OnRemoved(kv)
end

-----------------------------------------------------------

function dasdingo_1_modifier_heal_effect:DeclareFunctions()

    local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
    return funcs
end

function dasdingo_1_modifier_heal_effect:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	if RandomInt(1, 100) <= 30 then
		keys.target:AddNewModifier(self.caster, self.ability, "_modifier_root", {
			duration = self.ability:CalcStatus(1, self.caster, keys.target),
			effect = 4
		})
	end
end

function dasdingo_1_modifier_heal_effect:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	if self.reset == nil then return end

	self.reset = 0
	self.regen = 0

	if self.particle_regen then ParticleManager:DestroyParticle(self.particle_regen, false) end
end

function dasdingo_1_modifier_heal_effect:GetModifierConstantHealthRegen()
    return self.parent:GetMaxHealth() * self.regen
end

function dasdingo_1_modifier_heal_effect:OnIntervalThink()
	if self.reset then
		self.reset = self.reset + 1
		if self.reset > 11 then
			self.reset = 0
			self.regen = 0.05
			self:PlayEfxRegen()
		end
	end

	self.count = self.count + 1
	if self.count < self.intervals then return end
	self.count = 0

	local heal = 0
    local mnd = self.caster:FindModifierByName("_2_MND_modifier")
	if mnd then heal = self.heal * mnd:GetHealPower() end
    if heal > 0 then
        self.parent:Heal(heal, self.ability)
        self:PlayEfxHeal()
    end

	-- UP 1.1
	if self.ability:GetRank(1) then
		self.parent:Purge(false, true, false, false, false)
	end
end

-----------------------------------------------------------

function dasdingo_1_modifier_heal_effect:PlayEfxHeal()
	local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_parent = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_parent, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_parent)

	if IsServer() then self.parent:EmitSound("Hero_Dasdingo.Heal") end
end

function dasdingo_1_modifier_heal_effect:PlayEfxRegen()
	local particle = "particles/units/heroes/hero_oracle/oracle_purifyingflames.vpcf"
	self.particle_regen = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
end