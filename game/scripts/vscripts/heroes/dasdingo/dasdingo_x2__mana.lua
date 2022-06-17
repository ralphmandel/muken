dasdingo_x2__mana = class({})
LinkLuaModifier("dasdingo_x2_modifier_mana", "heroes/dasdingo/dasdingo_x2_modifier_mana", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_x2__mana:CalcStatus(duration, caster, target)
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
                    local value = base_stats_target.stat_total["RES"] * 0.7
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

    function dasdingo_x2__mana:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
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

        local base_stats = caster:FindModifierByName("base_stats")
        if base_stats then mana = mana * base_stats:GetHealPower() end
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