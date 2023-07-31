item_med_kit_modifier = class({})

function item_med_kit_modifier:IsHidden() return false end
function item_med_kit_modifier:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function item_med_kit_modifier:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()

  local interval = 0.2
  self.heal = kv.heal_per_second * interval

  if IsServer() then
    self.parent:EmitSound("n_creep_ForestTrollHighPriest.Heal")
    self:StartIntervalThink(interval)
  end
end

function item_med_kit_modifier:OnRefresh(kv)
end

function item_med_kit_modifier:OnRemoved()	
end

-- API FUNCTIONS -----------------------------------------------------------

function item_med_kit_modifier:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function item_med_kit_modifier:OnAttackLanded(keys)
  if keys.target ~= self.parent then return end
  self:Destroy()
end

function item_med_kit_modifier:OnIntervalThink()
  self.parent:Heal(CalcHeal(self.caster, self.heal), BaseHero(self.caster))
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function item_med_kit_modifier:GetEffectName()
	return "particles/units/heroes/hero_mars/mars_arena_of_blood_heal.vpcf"
end

function item_med_kit_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end