striker_2__shield = class({})
LinkLuaModifier("striker_2_modifier_shield", "heroes/sun/striker/striker_2_modifier_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_2_modifier_burn_aura", "heroes/sun/striker/striker_2_modifier_burn_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_2_modifier_burn_aura_effect", "heroes/sun/striker/striker_2_modifier_burn_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function striker_2__shield:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if IsServer() then caster:EmitSound("Hero_Dawnbreaker.PreAttack") end

        if target == caster then
            caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
            caster:StartGesture(ACT_DOTA_CAST_ABILITY_6)
        else
            caster:StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)
        end

        return true
    end

    function striker_2__shield:OnAbilityPhaseInterrupted()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if IsServer() then caster:StopSound("Hero_Dawnbreaker.PreAttack") end

        if target then
            if target == caster then
                caster:FadeGesture(ACT_DOTA_CAST_ABILITY_2)
                caster:FadeGesture(ACT_DOTA_CAST_ABILITY_6)
            else
                caster:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
            end
        end
    end

    function striker_2__shield:OnSpellStart()
        local caster = self:GetCaster()
		local target = self:GetCursorTarget()

        if target then
            if target == caster then
                Timers:CreateTimer((0.2), function()
                    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_2)
                    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_6)
                end)
            else
                caster:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
            end
        end

        self:PerformAbility(target)
    end

    function striker_2__shield:PerformAbility(target)
        local caster = self:GetCaster()
        
        target:AddNewModifier(caster, self, "striker_2_modifier_shield", {
            duration = CalcStatus(self:GetSpecialValueFor("duration"), caster, target)
        })

        return true
    end

-- EFFECTS