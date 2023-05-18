ancient_1_modifier_passive = class({})

function ancient_1_modifier_passive:IsHidden() return true end
function ancient_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_1_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddModifier(self.parent, self.caster, self.ability, "_modifier_bat_increased", {
    amount = self.ability:GetSpecialValueFor("bat")
  }, false)

  AddModifier(self.parent, self.caster, self.ability, "_modifier_crit_damage", {
    amount = self.ability:GetSpecialValueFor("crit_damage")
  }, false)
end

function ancient_1_modifier_passive:OnRefresh(kv)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_crit_damage", self.ability)
  AddModifier(self.parent, self.caster, self.ability, "_modifier_crit_damage", {
    amount = self.ability:GetSpecialValueFor("crit_damage")
  }, false)
end

function ancient_1_modifier_passive:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_bat_increased", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_crit_damage", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACKED
	}

	return funcs
end

function ancient_1_modifier_passive:OnAttacked(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

	AddModifier(keys.unit, self.caster, self.ability, "_modifier_stun", {
    duration = self:CalcStunDuration(keys.unit, keys.original_damage)
  }, false)
end

-- UTILS -----------------------------------------------------------

function ancient_1_modifier_passive:CalcStunDuration(target, damage)
  return CalcStatusResistance(self.ability:GetSpecialValueFor("stun_duration") * damage * 0.01, target)
end

-- EFFECTS -----------------------------------------------------------

function ancient_1_modifier_passive:PlayEfxCrit(target, crit)
	if target:GetPlayerOwner() == nil or crit == false then return end
	local particle_screen = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_screen.vpcf"
	local effect_screen = ParticleManager:CreateParticleForPlayer(particle_screen, PATTACH_WORLDORIGIN, nil, target:GetPlayerOwner())

	local effect = ParticleManager:CreateParticle("particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, Vector(500, 0, 0))
end