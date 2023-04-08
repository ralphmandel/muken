druid_2_modifier_armor = class({})

function druid_2_modifier_armor:IsHidden() return false end
function druid_2_modifier_armor:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_2_modifier_armor:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddBonus(self.ability, "_2_DEF", self.parent, self.ability:GetSpecialValueFor("def"), 0, nil)

	if IsServer() then self:PlayEfxStart() end
end

function druid_2_modifier_armor:OnRefresh(kv)
  RemoveBonus(self.ability, "_2_DEF", self.parent)
  AddBonus(self.ability, "_2_DEF", self.parent, self.ability:GetSpecialValueFor("def"), 0, nil)
end

function druid_2_modifier_armor:OnRemoved()
	RemoveBonus(self.ability, "_2_DEF", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_2_modifier_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
    MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function druid_2_modifier_armor:GetModifierConstantHealthRegen()
	return self:GetParent():GetBaseMaxHealth() * self:GetAbility():GetSpecialValueFor("regen") * 0.01
end

function druid_2_modifier_armor:GetModifierStatusResistanceStacking()
  return self:GetAbility():GetSpecialValueFor("special_status_resist")
end

function druid_2_modifier_armor:OnAttackLanded(keys)
  if keys.attacker:IsMagicImmune() then return end
  if keys.target ~= self.parent then return end

  if RandomFloat(1, 100) <= self.ability:GetSpecialValueFor("special_root_chance") then
    keys.attacker:AddNewModifier(self.caster, self.ability, "_modifier_root", {
      duration = CalcStatus(self.ability:GetSpecialValueFor("special_root_duration"), self.caster, keys.attacker),
      effect = 7
    })
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_2_modifier_armor:PlayEfxStart()
	local string = "particles/units/heroes/hero_treant/treant_livingarmor.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_origin", self.parent:GetAbsOrigin(), true)
	self:AddParticle(particle, false, false, -1, false, false)
end