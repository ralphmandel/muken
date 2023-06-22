bloodstained_u_modifier_copy = class({})

function bloodstained_u_modifier_copy:IsHidden() return false end
function bloodstained_u_modifier_copy:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_u_modifier_copy:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
	self.target = nil
	self.target_mod = nil
	self.slow_mod = nil
	self.hp = kv.hp

  AddStatusEfx(self.ability, "bloodstained_u_modifier_copy_status_efx", self.caster, self.parent)

	Timers:CreateTimer(FrameTime(), function()
		self.parent:ModifyHealth(self.parent:GetMaxHealth(), self.ability, false, 0)
	end)

	if IsServer() then self:SetStackCount(self.hp) end
end

function bloodstained_u_modifier_copy:OnRefresh(kv)
end

function bloodstained_u_modifier_copy:OnRemoved()
  RemoveStatusEfx(self.ability, "bloodstained_u_modifier_copy_status_efx", self.caster, self.parent)

	if self.target == nil then return end

  if self.target:IsAlive() then self.slow_mod:Destroy() end

	if self.parent:IsAlive() then
    AddModifier(self.caster, self.caster, self.ability, "bloodstained__modifier_extra_hp", {
      duration = self.ability:GetSpecialValueFor("steal_duration"), extra_life = self:GetStackCount()
    }, false)

    if IsServer() then
      self.target_mod:SetStackCount(self:GetStackCount())
      self.target_mod:SetDuration(self.ability:GetSpecialValueFor("steal_duration"), true)
    end

		self.parent:Kill(self.ability, nil)
	else
    self.target_mod:Destroy()
  end
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_u_modifier_copy:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}

	return state
end


function bloodstained_u_modifier_copy:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_DEATH
	}

	return funcs
end

function bloodstained_u_modifier_copy:GetModifierMoveSpeedBonus_Percentage(target)
	return 100
end

function bloodstained_u_modifier_copy:OnDeath(keys)
	if keys.unit == self.target then
    self:Destroy()
  end
end

function bloodstained_u_modifier_copy:OnTakeDamage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if self.target_mod == nil then return end

	self.target_mod:ChangeHP(keys.damage)
	self.hp = self.hp + keys.damage
	if IsServer() then self:SetStackCount(math.floor(self.hp)) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bloodstained_u_modifier_copy:GetStatusEffectName()
	return "particles/bloodstained/bloodstained_u_illusion_status.vpcf"
end

function bloodstained_u_modifier_copy:StatusEffectPriority()
	return 99999999
end

function bloodstained_u_modifier_copy:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end