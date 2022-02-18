icebreaker_1__frost = class({})
LinkLuaModifier( "icebreaker_1_modifier_frost", "heroes/icebreaker/icebreaker_1_modifier_frost", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_1_modifier_instant", "heroes/icebreaker/icebreaker_1_modifier_instant", LUA_MODIFIER_MOTION_NONE )

-- INIT

    function icebreaker_1__frost:CalcStatus(duration, caster, target)
        local time = duration
        if caster == nil then return time end
        local caster_int = caster:FindModifierByName("_1_INT_modifier")
        local caster_mnd = caster:FindModifierByName("_2_MND_modifier")

        if target == nil then
            if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
        else
            if caster:GetTeamNumber() == target:GetTeamNumber() then
                if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
            else
                local target_res = target:FindModifierByName("_2_RES_modifier")
                if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
                if target_res then time = time * (1 - target_res:GetStatus()) end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function icebreaker_1__frost:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function icebreaker_1__frost:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function icebreaker_1__frost:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("icebreaker__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        return att.talents[1][upgrade]
    end

    function icebreaker_1__frost:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        local att = caster:FindAbilityByName("icebreaker__attributes")
        if att then
            if att:IsTrained() then
                att.talents[1][0] = true
            end
        end
        
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_RES"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_REC"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_MND"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true) end
    end

    function icebreaker_1__frost:Spawn()
        self.kills = 0
        self.double = true
    end

-- SPELL START

    function icebreaker_1__frost:GetIntrinsicModifierName()
        return "icebreaker_1_modifier_frost"
    end

    function icebreaker_1__frost:AddKillPoint(pts)
        local caster = self:GetCaster()
        self.kills = self.kills + pts

        local mod = caster:FindAbilityByName("_1_AGI")
        if mod ~= nil then mod:BonusPermanent(1) end

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
    end

    function icebreaker_1__frost:ResetDouble()
        self.double = true
    end

-- EFFECTS