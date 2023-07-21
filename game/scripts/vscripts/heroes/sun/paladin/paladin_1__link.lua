paladin_1__link = class({})
LinkLuaModifier("paladin_1_modifier_link", "heroes/sun/paladin/paladin_1_modifier_link", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function paladin_1__link:OnSpellStart()
		local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    target:RemoveModifierByName("paladin_1_modifier_link")
    AddModifier(target, caster, self, "paladin_1_modifier_link", {duration = self:GetSpecialValueFor("duration")}, true)
  end

-- EFFECTS