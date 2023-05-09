icebreaker_1_modifier_hits = class({})

function icebreaker_1_modifier_hits:IsHidden() return false end
function icebreaker_1_modifier_hits:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_1_modifier_hits:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then
    self.parent:EmitSound("Item.MoonShard.Consume")
    self:SetStackCount(self.ability:GetSpecialValueFor("special_hits"))
  end
end

function icebreaker_1_modifier_hits:OnRefresh(kv)
  if IsServer() then
    self:SetStackCount(self.ability:GetSpecialValueFor("special_hits"))
  end
end

function icebreaker_1_modifier_hits:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_1_modifier_hits:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function icebreaker_1_modifier_hits:OnAttackLanded(keys)
  if keys.attacker ~= self.parent then return end
  if keys.target:IsMagicImmune() then return end
  if self.parent:IsIllusion() then return end

  self.ability:PerformFrostAttack(keys.target)
  
  if IsServer() then self:DecrementStackCount() end
end

function icebreaker_1_modifier_hits:OnStackCountChanged(old)
  if self:GetStackCount() ~= old then
    if self:GetStackCount() == 0 then self:Destroy() return end
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------