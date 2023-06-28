if not lawbreaker then
	lawbreaker = {}
  lawbreaker.random_values = {}
end

function lawbreaker:TrySpell(caster, target)
  local cast = false
  self.caster = caster
  self.target = target
  self.script = caster:FindModifierByName("general_script")

  local abilities_actions = {
    [1] = self.TryCast_Combo,
    [2] = self.TryCast_Grenade,
    [3] = self.TryCast_Rain,
    [4] = self.TryCast_Blink,
    [5] = self.TryCast_Form
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false then
      cast = abilities_actions[i](self)
    end
  end

  return cast
end

function lawbreaker:TryCast_Combo()
  local ability = self.caster:FindAbilityByName("lawbreaker_2__combo")
  if self.caster:HasModifier("lawbreaker_2_modifier_combo") then return true end
  if IsAbilityCastable(ability) == false then return false end
  if CalcDistanceBetweenEntityOBB(self.caster, self.target) > self.caster:Script_GetAttackRange() then return false end

  local angle = VectorToAngles(self.target:GetOrigin() - self.caster:GetOrigin())
  local angle_diff = AngleDiff(self.caster:GetAngles().y, angle.y)

  if angle_diff < -5 or angle_diff > 5 then return false end

  if self.random_values["combo_bullets"] == nil then self:RandomizeValue(ability, "combo_bullets") end
  if self.caster:FindModifierByName(ability:GetIntrinsicModifierName()):GetStackCount() < self.random_values["combo_bullets"] then
    return false
  end

  self:RandomizeValue(ability, "combo_bullets")
  self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
  self.script.interval = ability:GetCastPoint() + 0.5

  return true
end

function lawbreaker:TryCast_Grenade()
  local ability = self.caster:FindAbilityByName("lawbreaker_3__grenade")
  if IsAbilityCastable(ability) == false then return false end
  if CalcDistanceBetweenEntityOBB(self.caster, self.target) > ability:GetCastRange(self.caster:GetOrigin(), self.target) then return false end

  self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
  self.script.interval = ability:GetCastPoint() + 0.5

  return true
end

function lawbreaker:TryCast_Rain()
  return false
end

function lawbreaker:TryCast_Blink()
  return false
end

function lawbreaker:TryCast_Form()
  return false
end

function lawbreaker:RandomizeValue(ability, value_name)
  if value_name == "combo_bullets" then
    self.random_values["combo_bullets"] = RandomInt(ability:GetSpecialValueFor("min_shots"), ability:GetSpecialValueFor("max_shots"))
  end
end

return lawbreaker