hunter_4__bandage = class({})
LinkLuaModifier("hunter_4_modifier_bandage", "heroes/nature/hunter/hunter_4_modifier_bandage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("hunter_4_modifier_debuff", "heroes/nature/hunter/hunter_4_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function hunter_4__bandage:OnSpellStart()
    local caster = self:GetCaster()
    local tree = self:GetCursorTarget()

    tree:CutDownRegrowAfter(180, caster:GetTeamNumber())
    AddModifier(caster, self, "hunter_4_modifier_bandage", {duration = self:GetSpecialValueFor("duration")}, true)
	end

-- EFFECTS