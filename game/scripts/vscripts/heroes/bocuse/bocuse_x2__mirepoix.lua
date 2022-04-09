bocuse_x2__mirepoix = class ({})
LinkLuaModifier("bocuse_x2_modifier_mirepoix", "heroes/bocuse/bocuse_x2_modifier_mirepoix", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_x2_modifier_channel", "heroes/bocuse/bocuse_x2_modifier_channel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_x2_modifier_end", "heroes/bocuse/bocuse_x2_modifier_end", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bocuse_x2__mirepoix:CalcStatus(duration, caster, target)
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
        local rec = self:GetCaster():FindAbilityByName("_2_REC")
        local channel = self:GetCaster():FindAbilityByName("_channel")
        local channel_time = self:GetSpecialValueFor("channel_time")
        return channel_time * (1 - (channel:GetLevel() * rec:GetSpecialValueFor("channel") * 0.01))
    end

-- EFFECTS