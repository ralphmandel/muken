bloodstained_3__curse = class({})
LinkLuaModifier("bloodstained_3_modifier_curse", "heroes/bloodstained/bloodstained_3_modifier_curse", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_3_modifier_damage", "heroes/bloodstained/bloodstained_3_modifier_damage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_break", "modifiers/_modifier_break", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_disarm", "modifiers/_modifier_disarm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function bloodstained_3__curse:OnOwnerSpawned()
        self:SetActivated(true)
    end

    function bloodstained_3__curse:OnSpellStart()
        local caster = self:GetCaster()
        self.target = self:GetCursorTarget()
        
        if self.target:TriggerSpellAbsorb(self) then return end

        caster:RemoveModifierByNameAndCaster("bloodstained_3_modifier_curse", caster)
        self.target:AddNewModifier(caster, self, "bloodstained_3_modifier_curse", {})

        if IsServer() then
            caster:EmitSound("Hero_ShadowDemon.DemonicPurge.Cast")
            if self.target then self.target:EmitSound("Hero_Oracle.FortunesEnd.Attack") end
        end
    end

-- EFFECTS