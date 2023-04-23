flea_1__precision = class({})
LinkLuaModifier("flea_1_modifier_passive", "heroes/team_death/flea/flea_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_1_modifier_gesture", "heroes/team_death/flea/flea_1_modifier_gesture", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_1_modifier_precision", "heroes/team_death/flea/flea_1_modifier_precision", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_1_modifier_precision_stack", "heroes/team_death/flea/flea_1_modifier_precision_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_1_modifier_precision_status_efx", "heroes/team_death/flea/flea_1_modifier_precision_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_1_modifier_dark_pact", "heroes/team_death/flea/flea_1_modifier_dark_pact", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function flea_1__precision:Spawn()
        if self:IsTrained() == false then self:UpgradeAbility(true) end
    end

-- SPELL START

    function flea_1__precision:GetIntrinsicModifierName()
        return "flea_1_modifier_passive"
    end

    function flea_1__precision:OnSpellStart()
        local caster = self:GetCaster()
        caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):DecrementStackCount()
        caster:RemoveModifierByNameAndCaster("flea_1_modifier_gesture", self.caster)

        caster:AttackNoEarlierThan(10, 20)
        caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
        caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)

        if self:GetSpecialValueFor("special_pact_damage") > 0 then
            caster:AddNewModifier(caster, self, "flea_1_modifier_dark_pact", {})
        end

        Timers:CreateTimer(0.1, function()
            if caster:IsAlive() then
                if self:GetSpecialValueFor("special_purge") > 0 then
                    caster:Purge(false, true, false, true, false)
                end

                caster:AddNewModifier(caster, self, "flea_1_modifier_precision", {})
                if IsServer() then caster:EmitSound("Fleaman.Precision") end
            end
        end)

        Timers:CreateTimer(0.7, function()
            if caster:IsAlive() then
                caster:AttackNoEarlierThan(1, 1)
                caster:AddNewModifier(caster, self, "flea_1_modifier_gesture", {duration = 1.2}) 
            end
        end)
    end

-- EFFECTS