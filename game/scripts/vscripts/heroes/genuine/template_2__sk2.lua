template_2__sk2 = class({})
LinkLuaModifier("template_2_modifier_sk2", "heroes/template/template_2_modifier_sk2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function template_2__sk2:OnSpellStart()
        local caster = self:GetCaster()
    end

-- EFFECTS