bloodstained__modifier_copy = class({})

function bloodstained__modifier_copy:IsHidden() return false end
function bloodstained__modifier_copy:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained__modifier_copy:OnCreated(kv)
  if not IsServer() then return end

  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.hp_stolen = kv.hp_stolen
  self.target = EntIndexToHScript(kv.target_index)

  AddStatusEfx(self.ability, "bloodstained__modifier_copy_status_efx", self.caster, self.parent)
  AddBonus(self.ability, "_1_CON", self.parent, -9999, 0, nil)

  self.max_barrier = 100
  self.barrier = self.max_barrier

  self:SetHasCustomTransmitterData(true)
  self:SetStackCount(self.hp_stolen)
end

function bloodstained__modifier_copy:OnRefresh(kv)
end

function bloodstained__modifier_copy:OnRemoved()
  RemoveStatusEfx(self.ability, "bloodstained__modifier_copy_status_efx", self.caster, self.parent)
  RemoveBonus(self.ability, "_1_CON", self.parent)

  if self.target then
    if IsValidEntity(self.target) then
      local mod_bloodstained = self.target:FindModifierByName("bloodstained__modifier_bloodstained")

      if self.parent:IsAlive() then
        if mod_bloodstained then mod_bloodstained:Destroy() end
        self.parent:ForceKill(false)
      else
        if mod_bloodstained then
          mod_bloodstained.steal = false
          mod_bloodstained:Destroy()
        end
      end
    end
  end
end

function bloodstained__modifier_copy:AddCustomTransmitterData()
  return {
    barrier = self.barrier,
  }
end

function bloodstained__modifier_copy:HandleCustomTransmitterData(data)
  self.barrier = data.barrier
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained__modifier_copy:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    [MODIFIER_STATE_EVADE_DISABLED] = true
	}

	return state
end

function bloodstained__modifier_copy:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_MIN_HEALTH,
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_EVENT_ON_DEATH
	}

	return funcs
end

function bloodstained__modifier_copy:GetMinHealth(keys)
	return self:GetParent():GetMaxHealth()
end

function bloodstained__modifier_copy:GetModifierMoveSpeedBonus_Percentage(target)
	return 100
end

function bloodstained__modifier_copy:GetModifierIncomingPhysicalDamageConstant(keys)  
  if not IsServer() then return self.barrier end

  if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return 0 end

  local damage = 12.5
  if self:GetParent():HasModifier("ancient_1_modifier_passive") then damage = 25 end

  self.barrier = self.barrier - damage
  self:SendBuffRefreshToClients()
  if self.barrier < 1 then self:GetParent():ForceKill(false) end

  return -damage
end

function bloodstained__modifier_copy:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

  self.hp_stolen = self.hp_stolen + math.floor(keys.damage)

  if IsServer() then self:SetStackCount(self.hp_stolen) end
end

function bloodstained__modifier_copy:OnDeath(keys)
  if self.target == nil then return end
  if IsValidEntity(self.target) == false then return end
  if keys.unit ~= self.target then return end

  self.target:RemoveModifierByName("bloodstained__modifier_bloodstained")
  self.parent:ForceKill(false)
end

function bloodstained__modifier_copy:OnStackCountChanged(old)
  if self:GetStackCount() == 0 then return end
  if self.target == nil then return end
  if IsValidEntity(self.target) == false then return end
  
  AddModifier(self.target, self.caster, self.ability, "bloodstained__modifier_bloodstained", {
    hp_stolen = self:GetStackCount()
  }, false)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bloodstained__modifier_copy:GetStatusEffectName()
	return "particles/bloodstained/bloodstained_u_illusion_status.vpcf"
end

function bloodstained__modifier_copy:StatusEffectPriority()
	return 99999999
end

function bloodstained__modifier_copy:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end