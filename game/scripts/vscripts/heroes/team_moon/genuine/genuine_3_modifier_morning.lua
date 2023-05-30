genuine_3_modifier_morning = class({})

function genuine_3_modifier_morning:IsHidden() return false end
function genuine_3_modifier_morning:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_3_modifier_morning:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.ability:EndCooldown()
	self.ability:SetActivated(false)

  AddBonus(self.ability, "_1_AGI", self.parent, self.ability:GetSpecialValueFor("agi"), 0, nil)
  AddModifier(self.parent, self.caster, self.ability, "_modifier_movespeed_buff", {
    percent = self.ability:GetSpecialValueFor("ms")
  }, false)

  GameRules:BeginTemporaryNight(self:GetDuration())

	if IsServer() then self.parent:EmitSound("Genuine.Morning") end
end

function genuine_3_modifier_morning:OnRefresh(kv)
end

function genuine_3_modifier_morning:OnRemoved()
  self.parent:FindModifierByName(self.ability:GetIntrinsicModifierName()):StopEfxBuff()
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self.ability:SetActivated(true)

	RemoveBonus(self.ability, "_1_AGI", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------