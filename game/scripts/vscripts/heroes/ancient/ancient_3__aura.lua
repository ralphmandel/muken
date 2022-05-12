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

    function ancient_3__aura:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
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
        local rec = self:GetCaster():FindAbilityByName("_2_REC")
        local channel = self:GetCaster():FindAbilityByName("_channel")
        local channel_time = self:GetSpecialValueFor("channel_time")
        return channel_time * (1 - (channel:GetLevel() * rec:GetSpecialValueFor("channel") * 0.01))
    end

    function ancient_3__aura:GetCastRange(vLocation, hTarget)
        return self:GetSpecialValueFor("radius")
    end

-- EFFECTS