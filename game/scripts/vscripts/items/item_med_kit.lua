item_med_kit = class({})
LinkLuaModifier("item_med_kit_channeling_modifier", "items/item_med_kit_channeling_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_med_kit_modifier", "items/item_med_kit_modifier", LUA_MODIFIER_MOTION_NONE)

function item_med_kit:OnSpellStart()
  local caster = self:GetCaster()
  local target = self:GetCursorTarget()

  target:Purge(false, true, false, true, false)
  target:RemoveModifierByName("item_med_kit_modifier")

  AddModifier(target, self, "item_med_kit_modifier", {
    duration = self:GetSpecialValueFor("heal_duration"),
    heal_per_second = self:GetSpecialValueFor("heal_per_second")
  }, true)

  self:SpendCharge()
end