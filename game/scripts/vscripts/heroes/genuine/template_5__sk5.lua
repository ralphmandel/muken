template_5__sk5 = class({})
LinkLuaModifier("template_5_modifier_sk5", "heroes/template/template_5_modifier_sk5", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function template_5__sk5:OnSpellStart()
    local caster = self:GetCaster()
end

-- EFFECTS