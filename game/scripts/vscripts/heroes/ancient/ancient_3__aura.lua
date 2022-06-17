ancient_3__aura = class({})
LinkLuaModifier("ancient_3_modifier_channel", "heroes/ancient/ancient_3_modifier_channel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_3_modifier_hands", "heroes/ancient/ancient_3_modifier_hands", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_3_modifier_aura", "heroes/ancient/ancient_3_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_3_modifier_aura_status_efx", "heroes/ancient/ancient_3_modifier_aura_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_3_modifier_aura_effect", "heroes/ancient/ancient_3_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_truesight", "modifiers/_modifier_truesight", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function ancient_3__aura:CalcStatus(duration, caster, target)
        local time = duration
        local base_stats_caster = nil
        local base_stats_target = nil

        if caster ~= nil then
            base_stats_caster = caster:FindAbilityByName("base_stats")
        end

        if target ~= nil then
            base_stats_target = target:FindAbilityByName("base_stats")
        end

        if caster == nil then
            if target ~= nil then
                if base_stats_target then
                    local value = base_stats_target.stat_total["RES"] * 0.4
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - (calc * 0.01))
                end
            end
        else
            if target == nil then
                if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
            else
                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
                else
                    if base_stats_caster and base_stats_target then
                        local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + (calc * 0.01))
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - (calc * 0.01))
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function ancient_3__aura:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function ancient_3__aura:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function ancient_3__aura:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("ancient__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        return att.talents[3][upgrade]
    end

    function ancient_3__aura:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        local att = caster:FindAbilityByName("ancient__attributes")
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

        -- UP 3.42
        if self:GetRank(42) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function ancient_3__aura:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function ancient_3__aura:OnSpellStart()
        local caster = self:GetCaster()
        local time = self:GetChannelTime()

        caster:RemoveModifierByName("ancient_3_modifier_channel")
        if IsServer() then caster:EmitSound("Ancient.Aura.Channel") end
        caster:AddNewModifier(caster, self, "ancient_3_modifier_channel", {duration = time})
        
        self:EndCooldown()
        self:SetActivated(false)
    end
    
    function ancient_3__aura:OnChannelFinish(bInterrupted)
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        
        if bInterrupted == true then
            caster:RemoveModifierByName("ancient_3_modifier_channel")
            self:StartCooldown(5)
            self:SetActivated(true)
            return
        end

        caster:RemoveModifierByName("ancient_3_modifier_aura")
        caster:AddNewModifier(caster, self, "ancient_3_modifier_aura", {
            duration = self:CalcStatus(duration, caster, caster)
        })

        if IsServer() then
            caster:EmitSound("Ancient.Aura.Cast")
            caster:EmitSound("Ancient.Aura.Effect")
            caster:EmitSound("Ancient.Aura.Layer")
        end
    end

    function ancient_3__aura:CheckEnemies()
        local caster = self:GetCaster()
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), caster:GetOrigin(), nil, FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0, 0, false
        )
    
        for _,enemy in pairs(enemies) do
            if enemy:HasModifier("ancient_3_modifier_aura_effect")
            and enemy:IsHero() then
                self.find = true
                return
            end
        end
    
        self.find = false
    end

    function ancient_3__aura:OnOwnerDied()
        local caster = self:GetCaster()
        caster:RemoveModifierByName("ancient_3_modifier_aura")
        self:SetActivated(true)
    end

    function ancient_3__aura:GetChannelTime()
        local channel = self:GetCaster():FindAbilityByName("_channel")
        local channel_time = self:GetSpecialValueFor("channel_time")
        return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
    end

    function ancient_3__aura:GetCastRange(vLocation, hTarget)
        return self:GetSpecialValueFor("radius")
    end

-- EFFECTS