if not _script_template then
	_script_template = {}
  _script_template.values = {}
  _script_template.random_values = {}
end

function _script_template:TrySpell(target, state)
  local cast = false
  self.target = target
  self.state = state

  if self.caster:IsCommandRestricted() then return cast end

  local abilities_actions = {
    [1] = self.TryCast_Ability1,
    [2] = self.TryCast_Ability2,
    [3] = self.TryCast_Ability3
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false or cast == nil then
      cast = abilities_actions[i](self)
    end
  end

  if cast == nil then return false end

  return cast
end

function _script_template:TryCast_Ability1()
  local ability = self.caster:FindAbilityByName("ability_name")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    return true
  end
end

function _script_template:TryCast_Ability2()
  local ability = self.caster:FindAbilityByName("ability_name")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    return true
  end
end

function _script_template:TryCast_Ability3()
  local ability = self.caster:FindAbilityByName("ability_name")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    return true
  end
end

return _script_template