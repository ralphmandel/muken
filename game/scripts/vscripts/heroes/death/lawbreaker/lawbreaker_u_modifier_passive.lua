lawbreaker_u_modifier_passive = class({})

function lawbreaker_u_modifier_passive:IsHidden() return true end
function lawbreaker_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_u_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function lawbreaker_u_modifier_passive:OnRefresh(kv)
end

function lawbreaker_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function lawbreaker_u_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_MIN_HEALTH,
    MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function lawbreaker_u_modifier_passive:GetMinHealth()
  if self.parent:PassivesDisabled() then return 0 end
  if self.ability:IsCooldownReady() == false then return 0 end
  if self.parent:HasModifier("lawbreaker_u_modifier_form") then return 0 end

  return 1
end

function lawbreaker_u_modifier_passive:OnTakeDamage(keys)
  if keys.unit ~= self.parent then return end
  self.ability.attacker = keys.attacker

  if self.parent:PassivesDisabled() then return end
  if self.ability:IsCooldownReady() == false then return end
  if self.parent:HasModifier("lawbreaker_u_modifier_form") then return end

  if self.parent:GetHealth() == 1 then
    self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_4)

    local attacker = nil
    if self.ability.attacker then
      if IsValidEntity(self.ability.attacker) then
        attacker = self.ability.attacker:entindex()
      end
    end

    AddModifier(self.parent, self.ability, "lawbreaker_u_modifier_form", {attacker = attacker}, false)
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------