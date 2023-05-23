dasdingo_u_modifier_fear = class ({})

function dasdingo_u_modifier_fear:IsHidden()
    return false
end

function dasdingo_u_modifier_fear:IsPurgable()
    return true
end

function dasdingo_u_modifier_fear:IsDebuff()
    return true
end

-----------------------------------------------------------

function dasdingo_u_modifier_fear:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  local percent = 50

  -- UP 6.12
  if self.ability:GetRank(12) then
    percent = percent + 20
  end

  AddStatusEfx(self.ability, "dasdingo_u_modifier_fear_status_efx", self.caster, self.parent)

  self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = percent})
  self:ApplyFear()
end

function dasdingo_u_modifier_fear:OnRefresh(kv)
  self:ApplyFear()
end

function dasdingo_u_modifier_fear:OnRemoved(kv)
  RemoveStatusEfx(self.ability, "dasdingo_u_modifier_fear_status_efx", self.caster, self.parent)
end

function dasdingo_u_modifier_fear:OnDestroy()
    local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-----------------------------------------------------------

function dasdingo_u_modifier_fear:CheckState()
	local state = {
        [MODIFIER_STATE_FEARED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true
    }

	return state
end

function dasdingo_u_modifier_fear:ApplyFear()
    local direction = (self.caster:GetAbsOrigin() - self.parent:GetAbsOrigin()):Normalized() * -1000
    local pos = self.parent:GetOrigin() + direction
    self.parent:MoveToPosition(pos)
end

-----------------------------------------------------------

function dasdingo_u_modifier_fear:GetStatusEffectName()
 	return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end

function dasdingo_u_modifier_fear:StatusEffectPriority()
 	return MODIFIER_PRIORITY_HIGH
end

function dasdingo_u_modifier_fear:GetEffectName()
	return "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf"
end

function dasdingo_u_modifier_fear:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end