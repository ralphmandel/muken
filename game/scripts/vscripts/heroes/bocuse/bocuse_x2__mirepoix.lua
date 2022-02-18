bocuse_x2__mirepoix = class ({})
LinkLuaModifier("bocuse_x2_modifier_mirepoix", "heroes/bocuse/bocuse_x2_modifier_mirepoix", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_x2_modifier_channel", "heroes/bocuse/bocuse_x2_modifier_channel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_x2_modifier_end", "heroes/bocuse/bocuse_x2_modifier_end", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bocuse_x2__mirepoix:CalcStatus(duration, caster, target)
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

    function bocuse_x2__mirepoix:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
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
        caster:StartGesture(ACT_DOTA_TELEPORT)
        caster:AddNewModifier(caster, self, "bocuse_x2_modifier_channel", {})
    end

    function bocuse_x2__mirepoix:OnChannelFinish( bInterrupted )
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        caster:RemoveModifierByName("bocuse_x2_modifier_channel")

        if bInterrupted then
            caster:FadeGesture(ACT_DOTA_TELEPORT)
            self:EndCooldown()
            self:StartCooldown(self:GetEffectiveCooldown(self:GetLevel()))
        else
            caster:FadeGesture(ACT_DOTA_TELEPORT)
            caster:StartGesture(ACT_DOTA_TELEPORT_END)
            caster:AddNewModifier(caster, self, "bocuse_x2_modifier_mirepoix", {duration = self:CalcStatus(duration, caster, caster)})
            self:EndCooldown()
        end
    end

-- EFFECTS