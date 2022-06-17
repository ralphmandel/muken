icebreaker_u__zero = class({})
LinkLuaModifier( "icebreaker_u_modifier_zero", "heroes/icebreaker/icebreaker_u_modifier_zero", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_u_modifier_aura_effect", "heroes/icebreaker/icebreaker_u_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_u_modifier_status_effect", "heroes/icebreaker/icebreaker_u_modifier_status_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_u_modifier_blur", "heroes/icebreaker/icebreaker_u_modifier_blur", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_u_modifier_resistance", "heroes/icebreaker/icebreaker_u_modifier_resistance", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_1_modifier_instant", "heroes/icebreaker/icebreaker_1_modifier_instant", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_1_modifier_instant_status_effect", "heroes/icebreaker/icebreaker_1_modifier_instant_status_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "_modifier_no_bar", "modifiers/_modifier_no_bar", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function icebreaker_u__zero:CalcStatus(duration, caster, target)
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

    function icebreaker_u__zero:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function icebreaker_u__zero:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function icebreaker_u__zero:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("icebreaker__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        return att.talents[4][upgrade]
    end

    function icebreaker_u__zero:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        local att = caster:FindAbilityByName("icebreaker__attributes")
        if att then
            if att:IsTrained() then
                att.talents[4][0] = true
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

        -- UP 4.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        -- UP 4.21
        if self:GetRank(21) then
            charges = charges * 3
        end

	    -- UP 4.32
	    if self:GetRank(32) then
            charges = charges * 5
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function icebreaker_u__zero:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function icebreaker_u__zero:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local duration = self:GetSpecialValueFor("duration")

        self:DestroyShard()
        local shard = CreateUnitByName("ice_shard", point, true, caster, caster, caster:GetTeamNumber())
        shard:CreatureLevelUp(self:GetLevel() - 1)
        shard:AddNewModifier(caster, self, "icebreaker_u_modifier_zero", {duration = duration})

        if IsServer() then caster:EmitSound("Hero_Ancient_Apparition.ColdFeetCast") end
    end

    function icebreaker_u__zero:DestroyShard()
        local caster = self:GetCaster()
        local units = Entities:FindAllByClassname("npc_dota_creature")
        for _,shard in pairs(units) do
            if shard:GetPlayerOwner() == caster:GetPlayerOwner()
            and shard:IsAlive() and shard:GetUnitName() == "ice_shard" then
                shard:RemoveModifierByName("icebreaker_u_modifier_zero")
            end
        end
    end

    function icebreaker_u__zero:CastFilterResultLocation( vec )
        local caster = self:GetCaster()
        local origin = caster:GetOrigin()
        local distance = (vec - origin):Length2D()

        if caster:HasModifier("icebreaker_x1_modifier_skin") then
            if distance > self:GetCastRange(caster:GetOrigin(), nil) then
                self.fail = 1
                return UF_FAIL_CUSTOM
            end
        end

        return UF_SUCCESS
    end

    function icebreaker_u__zero:GetCustomCastErrorLocation( vec )
        if self.fail == 1 then return "No Range" end
    end

    function icebreaker_u__zero:GetCooldown(iLevel)
        if self:GetCurrentAbilityCharges() == 0 then return 120 end
        if self:GetCurrentAbilityCharges() == 1 then return 120 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 90 end
        return 120
    end

    function icebreaker_u__zero:GetAOERadius()
        if self:GetCurrentAbilityCharges() == 0 then return self:GetSpecialValueFor("radius") end
        if self:GetCurrentAbilityCharges() == 1 then return self:GetSpecialValueFor("radius") end
        if self:GetCurrentAbilityCharges() % 5 == 0 then return self:GetSpecialValueFor("radius") + 500 end
        return self:GetSpecialValueFor("radius")
    end

-- EFFECTS