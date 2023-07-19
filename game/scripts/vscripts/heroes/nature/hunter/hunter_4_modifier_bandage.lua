hunter_4_modifier_bandage = class({})

function hunter_4_modifier_bandage:IsHidden() return false end
function hunter_4_modifier_bandage:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_4_modifier_bandage:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.interval = 0.2

  if IsServer() then
    self.parent:EmitSound("n_creep_ForestTrollHighPriest.Heal")
    self:StartIntervalThink(self.interval)
  end
end

function hunter_4_modifier_bandage:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_4_modifier_bandage:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function hunter_4_modifier_bandage:OnAttackLanded(keys)
  if keys.target ~= self.parent then return end
  self:Destroy()
end

function hunter_4_modifier_bandage:OnIntervalThink()
  self.parent:Heal(CalcHeal(self.parent, self.ability:GetSpecialValueFor("heal_per_second") * self.interval), self.ability)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function hunter_4_modifier_bandage:GetEffectName()
	return "particles/units/heroes/hero_mars/mars_arena_of_blood_heal.vpcf"
end

function hunter_4_modifier_bandage:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end