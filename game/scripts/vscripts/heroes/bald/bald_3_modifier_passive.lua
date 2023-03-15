bald_3_modifier_passive = class({})

function bald_3_modifier_passive:IsHidden() return false end
function bald_3_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_3_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.hits = 0

	if IsServer() then self:SetStackCount(0) end
end

function bald_3_modifier_passive:OnRefresh(kv)
end

function bald_3_modifier_passive:OnRemoved()
	RemoveBonus(self.ability, "_2_DEF", self.parent)
  self:ChangeModelScale(0)
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function bald_3_modifier_passive:GetModifierAttackRangeBonus()
	return 120 * (self:GetParent():GetModelScale() - 1)
end

function bald_3_modifier_passive:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	if self.parent:HasModifier("bald_3_modifier_inner") then return end
	if self.parent:PassivesDisabled() then return end

  self.hits = self.hits + 1
  if self.hits >= self.ability:GetSpecialValueFor("hits") then
    if IsServer() then
      if self:GetStackCount() < self.ability:GetSpecialValueFor("max_stack") then
        self:IncrementStackCount()
      end
      self:StartIntervalThink(self.ability:GetSpecialValueFor("stack_delay"))
    end
    self.hits = 0
  end
end

function bald_3_modifier_passive:OnIntervalThink()
  if IsServer() then
    self:DecrementStackCount()
    if self:GetStackCount() <= 0 then
      self:StartIntervalThink(-1)
    end
    self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
  end
end

function bald_3_modifier_passive:OnStackCountChanged(old)
	RemoveBonus(self.ability, "_2_DEF", self.parent)
  AddBonus(self.ability, "_2_DEF", self.parent, self:GetStackCount(), 0, nil)
  self:ChangeModelScale(self:GetStackCount())
end

-- UTILS -----------------------------------------------------------

function bald_3_modifier_passive:ChangeModelScale(amount)
  local base_hero_mod = self.parent:FindModifierByName("base_hero_mod")
  if base_hero_mod == nil then return end
  if base_hero_mod.model_scale == nil then return end

  local slow = amount * self.ability:GetSpecialValueFor("slow_mult")
  local base_stats = self.parent:FindAbilityByName("base_stats")
  if base_stats then base_stats:SetBonusMS(self.ability:GetAbilityName(), -slow) end

  local extra_size = amount * self.ability:GetSpecialValueFor("size_mult") * 0.01
  self.parent:SetModelScale(base_hero_mod.model_scale + extra_size)
  self.parent:FindAbilityByName("bald__precache"):SetLevel(self.parent:GetModelScale() * 100)
end

-- EFFECTS -----------------------------------------------------------