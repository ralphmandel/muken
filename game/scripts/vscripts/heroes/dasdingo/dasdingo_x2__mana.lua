dasdingo_x2__mana = class({})
LinkLuaModifier("dasdingo_x2_modifier_mana", "heroes/dasdingo/dasdingo_x2_modifier_mana", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_x2__mana:CalcStatus(duration, caster, target)
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

    function dasdingo_x2__mana:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function dasdingo_x2__mana:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_x2__mana:OnUpgrade()
        self:SetHidden(false)
    end

    function dasdingo_x2__mana:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_x2__mana:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local mana = self:GetSpecialValueFor("mana")
        local ms = self:GetSpecialValueFor("ms")
        local duration = self:CalcStatus(self:GetSpecialValueFor("duration"), caster, caster)

        local mnd = caster:FindModifierByName("_2_MND_modifier")
        if mnd then mana = mana * mnd:GetHealPower() end
        if target:GetUnitName() == "npc_dota_hero_elder_titan" then mana = mana * 0.5 end
        target:GiveMana(mana)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, target, mana, caster)

        caster:AddNewModifier(caster, self, "_modifier_movespeed_buff", {percent = ms, duration = duration})
        target:AddNewModifier(caster, self, "_modifier_movespeed_buff", {percent = ms, duration = duration})

        self:PlayEfxStart(target)
    end

    function dasdingo_x2__mana:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()

        if caster == hTarget then
            return UF_FAIL_CUSTOM
        end

        local result = UnitFilter(
            hTarget,	-- Target Filter
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- Team Filter
            DOTA_UNIT_TARGET_HERO,	-- Unit Filter
            0,	-- Unit Flag
            caster:GetTeamNumber()	-- Team reference
        )
        
        if result ~= UF_SUCCESS then
            return result
        end

        return UF_SUCCESS
    end

    function dasdingo_x2__mana:GetCustomCastErrorTarget( hTarget )
        if self:GetCaster() == hTarget then
            return "#dota_hud_error_cant_cast_on_self"
        end
    end

-- EFFECTS

    function dasdingo_x2__mana:PlayEfxStart(target)
        local caster = self:GetCaster()
        local particle = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_chakra_magic.vpcf"
        local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(effect, 0, caster:GetOrigin())
        ParticleManager:SetParticleControl(effect, 1, caster:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect)

        local effect2 = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect2, 0, target:GetOrigin())
        ParticleManager:SetParticleControl(effect2, 1, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect2)

        if IsServer() then target:EmitSound("Hero_KeeperOfTheLight.ChakraMagic.Target") end
    end