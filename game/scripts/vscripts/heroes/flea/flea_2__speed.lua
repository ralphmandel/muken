flea_2__speed = class({})
LinkLuaModifier("flea_2_modifier_passive", "heroes/flea/flea_2_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_2_modifier_speed", "heroes/flea/flea_2_modifier_speed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function flea_2__speed:OnUpgrade()
        if self:GetLevel() == 1 then
            self.origin = self:GetCaster():GetOrigin()
        end
    end

-- SPELL START

    function flea_2__speed:GetIntrinsicModifierName()
        return "flea_2_modifier_passive"
    end

    function flea_2__speed:OnOwnerSpawned()
        self.origin = self:GetCaster():GetOrigin()
    end

-- EFFECTS