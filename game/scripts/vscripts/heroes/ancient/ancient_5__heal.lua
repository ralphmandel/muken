ancient_5__heal = class({})
LinkLuaModifier("ancient_5_modifier_buff", "heroes/ancient/ancient_5_modifier_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function ancient_5__heal:CalcStatus(duration, caster, target)
        if caster == nil or target == nil then return duration end
        if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
        local base_stats = caster:FindAbilityByName("base_stats")

        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
        else
            if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
            duration = duration * (1 - target:GetStatusResistance())
        end
        
        return duration
    end

    function ancient_5__heal:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function ancient_5__heal:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function ancient_5__heal:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[5][upgrade] end
    end

    function ancient_5__heal:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[5][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function ancient_5__heal:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function ancient_5__heal:OnAbilityPhaseStart()
        self:GetCaster():RemoveModifierByName("ancient_5_modifier_buff")
        self:PlayEfxStart(self:GetCaster())
        return true
    end

    function ancient_5__heal:OnSpellStart()
        local caster = self:GetCaster()
        local hp_min = self:GetSpecialValueFor("hp_min")
        local percent = self:GetSpecialValueFor("percent")
        
        local deficit = caster:GetBaseMaxHealth() - caster:GetHealth()
        local extra_health = math.floor(deficit * percent * 0.01)
        local sound = "Hero_Omniknight.Purification"

        -- UP 5.21
        if self:GetRank(21) then
            extra_health = extra_health + (caster:GetBaseMaxHealth() * 0.1)
        end

        -- UP 5.22
        if self:GetRank(22) then
            local ult = caster:FindAbilityByName("ancient_u__final")
            if ult then
                if ult:IsTrained() then
                    ult:AddEnergy(self, nil)
                end
            end
        end

        caster:Purge(false, true, false, false, false)
        
        if extra_health > hp_min then
            sound = "Hero_Omniknight.Purification.Wingfall"
            caster:AddNewModifier(caster, self, "ancient_5_modifier_buff", {
                extra_health = extra_health,
                duration = extra_health * 0.04
            })
        end

        self:PlayEfxEnd(caster, sound)
    end

    function ancient_5__heal:GetBehavior()
        if self:GetCurrentAbilityCharges() == 0 then return 4 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 137438953476 end
        return 4
    end

    function ancient_5__heal:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function ancient_5__heal:CheckAbilityCharges(charges)
        -- UP 5.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function ancient_5__heal:PlayEfxStart(target)
        if IsServer() then target:EmitSound("Hero_ElderTitan.PreAttack") end
    end

    function ancient_5__heal:StopEfxStart(bImmediate)
        if self.pfx then ParticleManager:DestroyParticle(self.pfx, bImmediate) end
    end

    function ancient_5__heal:PlayEfxEnd(target, sound)
        local string = "particles/units/heroes/hero_chen/chen_holy_persuasion.vpcf"
        local pfx = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(pfx)

        if IsServer() then target:EmitSound(sound) end
    end