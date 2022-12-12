shadowmancer_1_modifier_debuff = class({})
local tempTable = require("libraries/tempTable")

function shadowmancer_1_modifier_debuff:IsHidden()
	return false
end

function shadowmancer_1_modifier_debuff:IsPurgable()
	return true
end

function shadowmancer_1_modifier_debuff:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function shadowmancer_1_modifier_debuff:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local debuff_tick = self.ability:GetSpecialValueFor("debuff_tick")
	local damage_start = self.ability:GetSpecialValueFor("damage_start")
	self.ability:ApplyPoisonDamage(self.caster, self.parent, damage_start)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "shadowmancer_1_modifier_debuff_status_efx", true) end

	if IsServer() then
		self:StartIntervalThink(debuff_tick)
		self:SetStackCount(0)
		self:AddMultStack()
		self:PlayEfxStart()
	end
end

function shadowmancer_1_modifier_debuff:OnRefresh(kv)
	local damage_start = self.ability:GetSpecialValueFor("damage_start")
	self.ability:ApplyPoisonDamage(self.caster, self.parent, damage_start)
	
	if IsServer() then
		self:AddMultStack()
		self:PlayEfxStart()
	end
end

function shadowmancer_1_modifier_debuff:OnRemoved()
	RemoveBonus(self.ability, "_1_STR", self.parent)
	RemoveBonus(self.ability, "_2_DEF", self.parent)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "shadowmancer_1_modifier_debuff_status_efx", false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function shadowmancer_1_modifier_debuff:OnIntervalThink()
	local debuff_tick = self.ability:GetSpecialValueFor("debuff_tick")
	local poison_damage = self.ability:GetSpecialValueFor("poison") * self:GetStackCount()

	if self.parent:IsMagicImmune() == false then
		self.ability:ApplyPoisonDamage(self.caster, self.parent, poison_damage)
	end

	if IsServer() then
		self:PlayEfxDamage()
		self:StartIntervalThink(debuff_tick)
	end
end

function shadowmancer_1_modifier_debuff:OnStackCountChanged(iStackCount)
	if iStackCount == self:GetStackCount() then return end

	if self:GetStackCount() > 0 then self:ApplyDebuff() else self:Destroy() end
end

-- UTILS -----------------------------------------------------------

function shadowmancer_1_modifier_debuff:AddMultStack()
	local duration = CalcStatus(self.ability:GetSpecialValueFor("duration"), self.caster, self.parent)
	self:SetDuration(duration, true)
	self:IncrementStackCount()

	local this = tempTable:AddATValue(self)
	self.parent:AddNewModifier(self.caster, self.ability, "shadowmancer_1_modifier_debuff_stack", {
		duration = duration,
		modifier = this
	})
end

function shadowmancer_1_modifier_debuff:ApplyDebuff()
	local stats_loss = self.ability:GetSpecialValueFor("stats_loss") * self:GetStackCount()

	RemoveBonus(self.ability, "_1_STR", self.parent)
	RemoveBonus(self.ability, "_2_DEF", self.parent)
	AddBonus(self.ability, "_1_STR", self.parent, -stats_loss, 0, nil)
	AddBonus(self.ability, "_2_DEF", self.parent, -stats_loss, 0, nil)
end

-- EFFECTS -----------------------------------------------------------

function shadowmancer_1_modifier_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_maledict.vpcf"
end

function shadowmancer_1_modifier_debuff:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function shadowmancer_1_modifier_debuff:PlayEfxStart()
	local effect = ParticleManager:CreateParticle("particles/bioshadow/bioshadow_poison_hit.vpcf", PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, Vector(100, 0, 0))
	ParticleManager:ReleaseParticleIndex(effect)

	--if IsServer() then self.parent:EmitSound("Hero_Bioshadow.Poison") end
	if IsServer() then self.parent:EmitSound("Shadowmancer.Poison.Start") end
end

function shadowmancer_1_modifier_debuff:PlayEfxDamage()
    local particle_cast = "particles/econ/events/ti9/blink_dagger_ti9_start_lvl2_splash.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end