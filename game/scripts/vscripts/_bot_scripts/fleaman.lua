if not fleaman then
	fleaman = {}
  fleaman.values = {}
  fleaman.random_values = {}
end

function fleaman:TrySpell(target)
  local cast = false
  self.target = target

  if self.caster:IsCommandRestricted() then return cast end

  local abilities_actions = {
    [1] = self.TryCast_Jump,
    [2] = self.TryCast_Smoke,
    [3] = self.TryCast_Precision
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false then
      cast = abilities_actions[i](self)
    end
  end

  return cast
end

function fleaman:TryCast_Jump()
  local ability = self.caster:FindAbilityByName("fleaman_3__jump")
  if IsAbilityCastable(ability) == false then return false end

  if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

  local angle = VectorToAngles(self.target:GetOrigin() - self.caster:GetOrigin())
  local angle_diff = AngleDiff(self.caster:GetAngles().y, angle.y)
  if angle_diff < -3 or angle_diff > 3 then return false end

  self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())

  return true
end

function fleaman:TryCast_Smoke()
  local ability = self.caster:FindAbilityByName("fleaman_u__smoke")
  if IsAbilityCastable(ability) == false then return false end

  if self.caster:GetHealthPercent() >= 50 then return false end
  if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

  self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())

  return true
end

function fleaman:TryCast_Precision()
  local ability = self.caster:FindAbilityByName("fleaman_1__precision")
  if IsAbilityCastable(ability) == false then return false end

  if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

  if self.random_values["precision_charges"] == nil then self:RandomizeValue(ability, "precision_charges") end
  if ability:GetCurrentAbilityCharges() < self.random_values["precision_charges"] then return false end

  self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
  
  if ability:GetCurrentAbilityCharges() == 0 then
    self:RandomizeValue(ability, "precision_charges")
  else
    self.random_values["precision_charges"] = 0
  end

  return true
end

function fleaman:RandomizeValue(ability, value_name)
  if value_name == "precision_charges" then
    self.random_values[value_name] = RandomInt(1, ability:GetMaxAbilityCharges(ability:GetLevel()))
  end
end

return fleaman