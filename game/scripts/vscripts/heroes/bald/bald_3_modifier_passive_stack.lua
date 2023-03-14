bald_3_modifier_passive_stack = class({})

function bald_3_modifier_passive_stack:IsHidden() return true end
function bald_3_modifier_passive_stack:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_3_modifier_passive_stack:OnCreated( kv )
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self:AddStack()
end

function bald_3_modifier_passive_stack:OnRefresh(kv)
  self:AddStack()
end

function bald_3_modifier_passive_stack:OnRemoved()
  if IsServer() then
    local modifier = self.parent:FindModifierByNameAndCaster(self.ability:GetIntrinsicModifierName(), self.caster)
    if modifier then modifier:SetStackCount(0) end
  end
end

function bald_3_modifier_passive_stack:OnDestroy()
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_3_modifier_passive_stack:AddStack()
  if IsServer() then
    local modifier = self.parent:FindModifierByNameAndCaster(self.ability:GetIntrinsicModifierName(), self.caster)
    if modifier then modifier:IncrementStackCount() end
  end

  local parent = self.parent

  Timers:CreateTimer(self.ability:GetSpecialValueFor("stack_duration"), function()
    if parent then
      if IsValidEntity(parent) then
        local passive = parent:FindModifierByNameAndCaster("bald_3_modifier_passive", parent)
        local mod = parent:FindModifierByName("bald_3_modifier_passive_stack")
        if passive and mod then
          passive:DecrementStackCount()
          if passive:GetStackCount() == 0 then
            mod:Destroy()
          end
        end
      end
    end
  end)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------