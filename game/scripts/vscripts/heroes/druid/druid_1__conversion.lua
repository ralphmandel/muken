druid_1__conversion = class({})
LinkLuaModifier("druid_1_modifier_channel", "heroes/druid/druid_1_modifier_channel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_1_modifier_conversion", "heroes/druid/druid_1_modifier_conversion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_1_modifier_failed", "heroes/druid/druid_1_modifier_failed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_1__conversion:CalcStatus(duration, caster, target)
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
                    local value = base_stats_target.res_total * 0.01
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - calc)
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
                        local value = (base_stats_caster.int_total - base_stats_target.res_total) * 0.01
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + calc)
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - calc)
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function druid_1__conversion:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function druid_1__conversion:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function druid_1__conversion:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("druid__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        return att.talents[1][upgrade]
    end

    function druid_1__conversion:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        local att = caster:FindAbilityByName("druid__attributes")
        if att then
            if att:IsTrained() then
                att.talents[1][0] = true
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

        -- UP 1.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        -- UP 1.41
        if self:GetRank(41) then
            local tp = caster:FindItemInInventory("item_tp")
            if tp then tp.cooldown = 0 end
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function druid_1__conversion:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function druid_1__conversion:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function druid_1__conversion:OnSpellStart()    
        local caster = self:GetCaster()
        local time = self:GetChannelTime()
        self.radius = self:GetAOERadius()
        self.point = self:GetCursorPosition()

        caster:RemoveModifierByName("druid_1_modifier_channel")
        caster:AddNewModifier(caster, self, "druid_1_modifier_channel", {duration = time + 1.1})
        
        self:EndCooldown()
        self:SetActivated(false)
        self:PlayEfxStart()
    end

    function druid_1__conversion:OnChannelFinish(bInterrupted)
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        local damage = self:GetSpecialValueFor("damage")
        local cd_red_lvl = self:GetSpecialValueFor("cd_red_lvl") * 0.01
        local extra_hp = 0

        self:PlayEfxEnd(bInterrupted)
        self:SetActivated(true)

        if bInterrupted == true then
            caster:RemoveModifierByName("druid_1_modifier_channel")
            self:StartCooldown(5)
            return
        end

        local cooldown_reduction = 0

        -- UP 1.31
	    if self:GetRank(31) then
            extra_hp = 300
        end

        local damageTable = {
            attacker = caster,
            damage_type = DAMAGE_TYPE_PURE,
            damage = damage,
            ability = self
        }

        local neutrals = FindUnitsInRadius(
            caster:GetTeamNumber(), self.point, nil, self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC,
            0, 0, false
        )

        for _,neutral in pairs(neutrals) do
            local chance = self:CalcChance(neutral:GetLevel())
            if neutral:GetUnitName() ~= "summoner_spider"
            and neutral:GetUnitName() ~= "boss_gorillaz"
            and neutral:HasModifier("druid_1_modifier_failed") == false
            and neutral:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
                if RandomInt(1, 10000) <= chance * 100 then
                    neutral:Purge( false, true, false, false, false )
                    neutral:AddNewModifier(caster, self, "druid_1_modifier_conversion", {
                        duration = self:CalcStatus(duration, caster, nil),
                        extra_hp = extra_hp
                    })
                else
                    cooldown_reduction = cooldown_reduction + (neutral:GetLevel() * cd_red_lvl)
                    damageTable.victim = neutral
                    ApplyDamage(damageTable)
                    if IsServer() then neutral:EmitSound("Hero_Treant.LeechSeed.Target") end
                    if neutral:IsAlive() then
                        neutral:AddNewModifier(caster, self, "druid_1_modifier_failed", {})
                    end
                end
            end
        end

        self:StartCooldown(self:GetEffectiveCooldown(self:GetLevel()) * (1 - cooldown_reduction))
    end

    function druid_1__conversion:CalcChance(level)
        local chance = self:GetSpecialValueFor("chance")
        local chance_lvl = self:GetSpecialValueFor("chance_lvl")
        local chance_bonus = self:GetSpecialValueFor("chance_bonus")
        local chance_bonus_lvl = self:GetSpecialValueFor("chance_bonus_lvl")
        local calc = chance + (chance_lvl * level)
        local calc_bonus = chance_bonus + (chance_bonus_lvl * level)

        return (calc + calc_bonus)
    end

    function druid_1__conversion:GetChannelTime()
        local rec = self:GetCaster():FindAbilityByName("_2_REC")
        local channel = self:GetCaster():FindAbilityByName("_channel")
        local channel_time = self:GetSpecialValueFor("channel_time")
        return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
    end

    function druid_1__conversion:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level =  (1 + ((self:GetLevel() - 1) * 0.1))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() == 1 then return manacost * level end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return (manacost - 40) * level end
        return manacost * level
    end

-- EFFECTS

    function druid_1__conversion:PlayEfxStart()
        local caster = self:GetCaster()
        self.efx_channel = ParticleManager:CreateParticle("particles/druid/druid_skill1_channeling.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(self.efx_channel, 0, caster:GetOrigin())

        self.efx_channel2 = ParticleManager:CreateParticle("particles/druid/druid_skill1_channeling.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.efx_channel2, 0, self.point)
        ParticleManager:SetParticleControl(self.efx_channel2, 5, Vector(math.floor(self.radius * 0.1), 0, 0))

        self.fow = AddFOWViewer(caster:GetTeamNumber(), self.point, self.radius, 10, true)
        if IsServer() then caster:EmitSound("Druid.Channel") end
    end

    function druid_1__conversion:PlayEfxEnd(bInterrupted)
        local caster = self:GetCaster()
        if self.efx_channel then ParticleManager:DestroyParticle(self.efx_channel, false) end
        if self.efx_channel2 then ParticleManager:DestroyParticle(self.efx_channel2, false) end
        RemoveFOWViewer(caster:GetTeamNumber(), self.fow)
        if IsServer() then caster:StopSound("Druid.Channel") end

        if bInterrupted == false then
            local efx = ParticleManager:CreateParticle("particles/druid/druid_skill1_cast_circle_leaf.vpcf", PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(efx, 0, self.point)
            ParticleManager:SetParticleControl(efx, 1, Vector(self.radius, 0, 0))
            if IsServer() then caster:EmitSound("Druid.Finish") end
        end
    end