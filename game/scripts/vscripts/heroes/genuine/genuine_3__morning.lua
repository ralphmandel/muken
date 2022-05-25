genuine_3__morning = class({})
LinkLuaModifier("genuine_3_modifier_morning", "heroes/genuine/genuine_3_modifier_morning", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_3_modifier_passive", "heroes/genuine/genuine_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_3__morning:CalcStatus(duration, caster, target)
        local time = duration
        local caster_int = nil
        local caster_mnd = nil
        local target_res = nil

        if caster ~= nil then
            caster_int = caster:FindModifierByName("_1_INT_modifier")
            caster_mnd = caster:FindModifierByName("_2_MND_modifier")
        end

        if target ~= nil then
            target_res = target:FindModifierByName("_2_RES_modifier")
        end

        if caster == nil then
            if target ~= nil then
                if target_res then time = time * (1 - target_res:GetStatus()) end
            end
        else
            if target == nil then
                if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
            else
                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
                else
                    if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
                    if target_res then time = time * (1 - target_res:GetStatus()) end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function genuine_3__morning:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function genuine_3__morning:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_3__morning:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("genuine__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        return att.talents[3][upgrade]
    end

    function genuine_3__morning:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        local att = caster:FindAbilityByName("genuine__attributes")
        if att then
            if att:IsTrained() then
                att.talents[3][0] = true
            end
        end
        
        if self:GetLevel() == 1 then
			caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_RES"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_REC"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_MND"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true)
		end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function genuine_3__morning:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.kills = 0
    end

-- SPELL START

    function genuine_3__morning:GetIntrinsicModifierName()
        return "genuine_3_modifier_passive"
    end

    function genuine_3__morning:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        local passive = caster:FindModifierByName("genuine_3_modifier_passive")
        if passive then passive:PlayEfxBuff() end

        return true
    end

    function genuine_3__morning:OnAbilityPhaseInterrupted()
        local caster = self:GetCaster()
        local passive = caster:FindModifierByName("genuine_3_modifier_passive")
        if passive then passive:StopEfxBuff() end
    end

    function genuine_3__morning:OnOwnerDied()
        local caster = self:GetCaster()
        local passive = caster:FindModifierByName("genuine_3_modifier_passive")
        if passive then passive:StopEfxBuff() end
    end

    function genuine_3__morning:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")

        -- UP 3.41
        if self:GetRank(41) then
            duration = duration + 12
        end

        if IsServer() then caster:EmitSound("Genuine.Morning") end

        caster:AddNewModifier(caster, self, "genuine_3_modifier_morning", {
            duration = self:CalcStatus(duration, caster, caster)
        })
    end

    function genuine_3__morning:AddKillPoint(pts)
        local caster = self:GetCaster()
        self.kills = self.kills + pts

        local mod = caster:FindAbilityByName("_1_INT")
        if mod ~= nil then mod:BonusPermanent(1) end

        local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
        ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
        ParticleManager:ReleaseParticleIndex(nFXIndex)
    end

    function genuine_3__morning:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level =  (1 + ((self:GetLevel() - 1) * 0.1))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end
    
-- EFFECTS