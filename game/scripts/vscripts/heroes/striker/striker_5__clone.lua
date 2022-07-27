striker_5__clone = class({})
LinkLuaModifier("striker_5_modifier_clone", "heroes/striker/striker_5_modifier_clone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_5_modifier_hero", "heroes/striker/striker_5_modifier_hero", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function striker_5__clone:CalcStatus(duration, caster, target)
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

    function striker_5__clone:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function striker_5__clone:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function striker_5__clone:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[5][upgrade] end
    end

    function striker_5__clone:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[5][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function striker_5__clone:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function striker_5__clone:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local owner = target

        if target:GetTeamNumber() ~= caster:GetTeamNumber() then
            if target:TriggerSpellAbsorb(self) then return end
            owner = caster
        end

        self:CreateClone(owner, target)
        caster:MoveToPositionAggressive(target:GetOrigin())
    end

    function striker_5__clone:CreateClone(owner, target)
        local caster = self:GetCaster()
        local illu_duration = self:GetSpecialValueFor("illu_duration")
        local incoming = self:GetSpecialValueFor("incoming")
        local outgoing = self:GetSpecialValueFor("outgoing")

        target:RemoveModifierByNameAndCaster("striker_5_modifier_hero", caster)

        -- UP 5.41
        if self:GetRank(41) then
            illu_duration = illu_duration - 10
        end

        local illu = CreateIllusions(owner, target, {
            outgoing_damage = -outgoing, incoming_damage = incoming,
            bounty_base = 0, bounty_growth = 0,
            duration = illu_duration
        }, 1, 64, false, true)
        illu = illu[1]

        local loc = target:GetAbsOrigin() + RandomVector(150)
        illu:SetAbsOrigin(loc)
        illu:SetForwardVector((target:GetAbsOrigin() - loc):Normalized())
        FindClearSpaceForUnit(illu, loc, true)
        illu:MoveToPositionAggressive(loc)
        illu:ModifyHealth(illu:GetMaxHealth(), self, false, 0)

        local mod_clone = illu:AddNewModifier(caster, self, "striker_5_modifier_clone", {})
        mod_clone.target = target

        local mod_hero = target:AddNewModifier(caster, self, "striker_5_modifier_hero", {})
        mod_hero.clone = illu

        if IsServer() then target:EmitSound("Blink_Layer.Overwhelming") end

        self:UpgradeCloneAbility(target, illu)
        self:PlayEfxStart(target)
        self:PlayEfxStart(illu)
    end

    function striker_5__clone:UpgradeCloneAbility(target, illu)
        for i = 0, 16, 1 do
            local target_ability = target:GetAbilityByIndex(i)
            if target_ability then
                if target_ability:IsTrained() then
                    local illu_ability = illu:FindAbilityByName(target_ability:GetAbilityName())
                    if illu_ability then
                        if illu_ability:IsTrained() == false then
                            illu_ability:UpgradeAbility(true)
                        end
                    end
                end
            end
        end
    end

    function striker_5__clone:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()
        if caster == hTarget then return UF_FAIL_CUSTOM end
        if hTarget:IsIllusion() then return UF_FAIL_CUSTOM end

        local result = UnitFilter(
            hTarget, self:GetAbilityTargetTeam(),
            self:GetAbilityTargetType(),
            self:GetAbilityTargetFlags(),
            caster:GetTeamNumber()
        )

        return result
    end

    function striker_5__clone:GetCustomCastErrorTarget(hTarget)
        if hTarget:IsIllusion() then return "Ability Can't Target Illusion" end
        if self:GetCaster() == hTarget then return "#dota_hud_error_cant_cast_on_self" end
    end

    function striker_5__clone:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function striker_5__clone:PlayEfxStart(target)
        local string_1 = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_blink_start_v2.vpcf"
        local particle_1 = ParticleManager:CreateParticle(string_1, PATTACH_ABSORIGIN, target)
        ParticleManager:SetParticleControl(particle_1, 0, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(particle_1)
    end