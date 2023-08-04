item_med_kit = class({})
LinkLuaModifier("item_med_kit_channeling_modifier", "items/item_med_kit_channeling_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_med_kit_modifier", "items/item_med_kit_modifier", LUA_MODIFIER_MOTION_NONE)

function item_med_kit:OnSpellStart()
  local caster = self:GetCaster()
  self.target = self:GetCursorTarget()

  caster:StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)

  AddModifier(self.target, self, "item_med_kit_channeling_modifier", {}, false)
end

function item_med_kit:OnChannelFinish(bInterrupted)
  local caster = self:GetCaster()
  caster:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)

  if self.target == nil then return end
  self.target:RemoveModifierByName("item_med_kit_channeling_modifier")

  if bInterrupted then self:StartCooldown(1) return end

  self.target:Purge(false, true, false, true, false)
  self.target:RemoveModifierByName("item_med_kit_modifier")

  AddModifier(self.target, self, "item_med_kit_modifier", {
    duration = self:GetSpecialValueFor("heal_duration"),
    heal_per_second = self:GetSpecialValueFor("heal_per_second")
  }, true)

  self:SpendCharge()
end