striker_1__blow = class({})
LinkLuaModifier("striker_1_modifier_passive", "heroes/striker/striker_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_ban", "modifiers/_modifier_ban", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function striker_1__blow:Spawn()
        if self:IsTrained() == false then self:UpgradeAbility(true) end
    end

-- SPELL START

    function striker_1__blow:GetIntrinsicModifierName()
        return "striker_1_modifier_passive"
    end

    function striker_1__blow:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if target:TriggerSpellAbsorb(self) then return false end

        caster:FindModifierByName(self:GetIntrinsicModifierName()).last_hit_target = target
        caster:FindModifierByName(self:GetIntrinsicModifierName()):PerformBlink(target)
    end

    function striker_1__blow:GetAbilityTextureName()
        if self:GetCaster():HasModifier("striker_5_modifier_sof")
        or self:GetCaster():HasModifier("striker_5_modifier_illusion_sof")
        or self:GetCaster():HasModifier("striker_5_modifier_return") then
            return "striker_blow_alter"
        end

        return "striker_blow"
    end

    function striker_1__blow:GetBehavior()
        if self:GetSpecialValueFor("AbilityCastRange") > 0 then
            return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
        end

        return DOTA_ABILITY_BEHAVIOR_PASSIVE
    end

    function striker_1__blow:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()

        local result = UnitFilter(
            hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            0, caster:GetTeamNumber()
        )

        return result
    end

-- EFFECTS