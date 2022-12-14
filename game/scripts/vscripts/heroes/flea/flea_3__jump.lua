flea_3__jump = class({})
LinkLuaModifier("flea_3_modifier_passive", "heroes/flea/flea_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_3_modifier_jump", "heroes/flea/flea_3_modifier_jump", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_3_modifier_effect", "heroes/flea/flea_3_modifier_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_3_modifier_attack", "heroes/flea/flea_3_modifier_attack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_generic_arc", "modifiers/_modifier_generic_arc", LUA_MODIFIER_MOTION_BOTH)

-- INIT

-- SPELL START

    function flea_3__jump:OnOwnerSpawned()
        self:SetActivated(true)
    end

    function flea_3__jump:GetIntrinsicModifierName()
        return "flea_3_modifier_passive"
    end

    function flea_3__jump:OnSpellStart()
        local caster = self:GetCaster()
        self.point = self:GetCursorPosition()
        self.hits = self:GetSpecialValueFor("hits")

        ProjectileManager:ProjectileDodge(caster)
        caster:RemoveModifierByName("flea_3_modifier_jump")
        caster:AddNewModifier(caster, self, "flea_3_modifier_jump", {})
    end

    function flea_3__jump:FindTargets(radius_impact, point)
        local caster = self:GetCaster()
        local mod = caster:AddNewModifier(caster, self, "flea_3_modifier_attack", {})

        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), point, nil, radius_impact,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
        )
    
        for _,enemy in pairs(enemies) do
            if enemy:HasModifier("bloodstained_u_modifier_copy") == false
            and enemy:IsIllusion() then
                enemy:ForceKill(false)
            else
                caster:PerformAttack(enemy, false, true, true, true, false, false, false)
            end
        end
    
        mod:Destroy()

        self.hits = self.hits - 1
        if self.hits > 0 then
            Timers:CreateTimer(0.25, function()
                if caster:IsAlive() then
                    self:FindTargets(radius_impact, point)
                end
            end)
        end
    end

-- EFFECTS