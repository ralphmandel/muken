shadowmancer_1_modifier_weapon = class({})

function shadowmancer_1_modifier_weapon:IsHidden()
	return false
end

function shadowmancer_1_modifier_weapon:IsPurgable()
	return true
end

function shadowmancer_1_modifier_weapon:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function shadowmancer_1_modifier_weapon:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if self.parent:IsIllusion() == false then
		local agi = self.ability:GetSpecialValueFor("agi")
		AddBonus(self.ability, "_1_AGI", self.parent, agi, 0, nil)
	end

	if IsServer() then self:PlayEfxStart() end
end

function shadowmancer_1_modifier_weapon:OnRefresh(kv)
	if self.parent:IsIllusion() == false then
		local agi = self.ability:GetSpecialValueFor("agi")
		RemoveBonus(self.ability, "_1_AGI", self.parent)
		AddBonus(self.ability, "_1_AGI", self.parent, agi, 0, nil)
	end

	if IsServer() then self:PlayEfxStart() end
end

function shadowmancer_1_modifier_weapon:OnRemoved()
	RemoveBonus(self.ability, "_1_AGI", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function shadowmancer_1_modifier_weapon:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function shadowmancer_1_modifier_weapon:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:IsMagicImmune() then return end

	local debuff_chance = self.ability:GetSpecialValueFor("debuff_chance")
	local debuff_duration = self.ability:GetSpecialValueFor("debuff_duration")
	local poison_damage = self.ability:GetSpecialValueFor("poison")

	self.ability:ApplyPoisonDamage(self.parent, keys.target, poison_damage)

	if RandomFloat(1, 100) <= debuff_chance then
		keys.target:AddNewModifier(self.caster, self.ability, "shadowmancer_1_modifier_debuff", {
			duration = CalcStatus(debuff_duration, self.caster, keys.target)
		})
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function shadowmancer_1_modifier_weapon:PlayEfxStart()
	if self.efx then ParticleManager:DestroyParticle(self.efx, false) end

	local string = "particles/shadowmancer/bath_weapon/shadowmancer_bath_buff.vpcf"
	self.efx = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.efx, 0, self.parent:GetOrigin())
	self:AddParticle(self.efx, false, false, -1, false, false)

	if self.parent:IsIllusion() == false then
		local string_1 = "particles/shadowmancer/bath_weapon/shadowmancer_bath_cast.vpcf"
		local particle_1 = ParticleManager:CreateParticle(string_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(particle_1, 0, self.parent:GetOrigin())
		ParticleManager:ReleaseParticleIndex(particle_1)

		if IsServer() then self.parent:EmitSound("Hero_Visage.SoulAssumption.Target") end
	end
end