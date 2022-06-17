bocuse_x2__mirepoix = class ({})
LinkLuaModifier("bocuse_x2_modifier_mirepoix", "heroes/bocuse/bocuse_x2_modifier_mirepoix", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_x2_modifier_channel", "heroes/bocuse/bocuse_x2_modifier_channel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_x2_modifier_end", "heroes/bocuse/bocuse_x2_modifier_end", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bocuse_x2__mirepoix:CalcStatus(duration, caster, target)
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

    function bocuse_x2__mirepoix:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bocuse_x2__mirepoix:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bocuse_x2__mirepoix:OnUpgrade()
        self:SetHidden(false)
    end

    function bocuse_x2__mirepoix:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function bocuse_x2__mirepoix:OnSpellStart()
        local caster = self:GetCaster()
        local time = self:GetChannelTime()

        caster:RemoveModifierByName("bocuse_x2_modifier_channel")
        if IsServer() then
            caster:EmitSound("DOTA_Item.Cheese.Activate")
            caster:EmitSound("DOTA_Item.RepairKit.Target")
        end
        caster:AddNewModifier(caster, self, "bocuse_x2_modifier_channel", {duration = time})

        self:EndCooldown()
        self:SetActivated(false)
    end

    function bocuse_x2__mirepoix:OnChannelFinish( bInterrupted )
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        
        if bInterrupted == true then
            caster:RemoveModifierByName("bocuse_x2_modifier_channel")
            self:StartCooldown(5)
            self:SetActivated(true)
            return
        end

        caster:AddNewModifier(caster, self, "bocuse_x2_modifier_mirepoix", {duration = self:CalcStatus(duration, caster, caster)})
    end

    function bocuse_x2__mirepoix:GetChannelTime()
        local channel = self:GetCaster():FindAbilityByName("_channel")
        local channel_time = self:GetSpecialValueFor("channel_time")
        return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
    end

-- EFFECTS