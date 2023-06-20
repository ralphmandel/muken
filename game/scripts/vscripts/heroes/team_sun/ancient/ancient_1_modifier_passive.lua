ancient_1_modifier_passive = class({})

function ancient_1_modifier_passive:IsHidden() return false end
function ancient_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_1_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddModifier(self.parent, self.caster, self.ability, "_modifier_crit_damage", {
    amount = self.ability:GetSpecialValueFor("crit_damage")
  }, false)

  Timers:CreateTimer(0.3, function()
    self:ChanegeBAT()
  end)

  if IsServer() then self:SetStackCount(self.ability:GetSpecialValueFor("special_double_hit")) end
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
    MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_EVENT_ON_ATTACKED,
	}

	return funcs
end

function ancient_1_modifier_passive:GetModifierBaseDamageOutgoing_Percentage()
  return self:GetAbility():GetSpecialValueFor("bat")
end

function ancient_1_modifier_passive:GetModifierAttackSpeedBonus_Constant()
  if self:GetAbility():GetSpecialValueFor("special_double_hit") > 0 and self:GetStackCount() == 0 then return 450 end
  return 0
end

function ancient_1_modifier_passive:OnAttackFail(keys)
	if keys.attacker ~= self.parent then return end
  self:ReduceHit()
end

function ancient_1_modifier_passive:OnAttacked(keys)
	if keys.attacker ~= self.parent then return end

  self:ReduceHit()

	if self.parent:PassivesDisabled() then return end

  if BaseStats(keys.attacker).has_crit then
    self:PlayEfxCrit(keys.attacker, true)
    if keys.target:GetPlayerOwner() then
      self:PlayEfxCrit(keys.target, false)
    end
  end

	AddModifier(keys.target, self.caster, self.ability, "_modifier_stun", {
    duration = self:CalcStunDuration(keys.target, keys.original_damage)
  }, false)
end

function ancient_1_modifier_passive:OnStackCountChanged(old)
  self:ChanegeBAT()
end

-- UTILS -----------------------------------------------------------

function ancient_1_modifier_passive:ChanegeBAT()
  if BaseStats(self.parent) == nil then return end

  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_bat_increased", self.ability)

  if self.ability:GetSpecialValueFor("special_double_hit") == 0 or self:GetStackCount() > 0 then
    AddModifier(self.parent, self.caster, self.ability, "_modifier_bat_increased", {
      amount = BaseStats(self.parent):GetSpecialValueFor("base_attack_time") * self.ability:GetSpecialValueFor("bat") * 0.01
    }, false)
  end
end

function ancient_1_modifier_passive:CalcStunDuration(target, damage)
  return CalcStatusResistance(self.ability:GetSpecialValueFor("stun_duration") * damage * 0.01, target)
end

function ancient_1_modifier_passive:ReduceHit()
  local double_hit = self.ability:GetSpecialValueFor("special_double_hit")

  if self.parent:HasModifier("ancient_2_modifier_leap") == false then
    if IsServer() then
      if double_hit > 0 then
        if self:GetStackCount() > 0 then
          self:DecrementStackCount()
        else
          self:SetStackCount(double_hit)
        end        
      end
    end
  end
end

-- EFFECTS -----------------------------------------------------------

function ancient_1_modifier_passive:PlayEfxCrit(target, sound)
	local particle_screen = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_screen.vpcf"
	local effect_screen = ParticleManager:CreateParticleForPlayer(particle_screen, PATTACH_WORLDORIGIN, nil, target:GetPlayerOwner())

  local particle_shake = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
	local effect = ParticleManager:CreateParticle(particle_shake, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, Vector(500, 0, 0))

  if IsServer() then target:EmitSound("Ancient.Stun.Crit") end
end