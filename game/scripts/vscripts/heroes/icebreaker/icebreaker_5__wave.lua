icebreaker_5__wave = class({})
LinkLuaModifier("icebreaker_5_modifier_recharge", "heroes/icebreaker/icebreaker_5_modifier_recharge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function icebreaker_5__wave:CalcStatus(duration, caster, target)
        if caster == nil or target == nil then return end
        if IsValidEntity(caster) == false or IsValidEntity(target) == false then return end
        local base_stats = caster:FindAbilityByName("base_stats")

        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
        else
            if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
            duration = duration * (1 - target:GetStatusResistance())
        end
        
        return duration
    end

    function icebreaker_5__wave:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function icebreaker_5__wave:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function icebreaker_5__wave:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[5][upgrade] end
    end

    function icebreaker_5__wave:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[5][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function icebreaker_5__wave:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function icebreaker_5__wave:GetIntrinsicModifierName()
        return "icebreaker_5_modifier_recharge"
    end

    function icebreaker_5__wave:OnSpellStart()
        local caster = self:GetCaster()
        local frozen_duration = self:GetSpecialValueFor("frozen_duration")
        local blast_radius = self:GetSpecialValueFor("blast_radius")
        local blast_speed = self:GetSpecialValueFor("blast_speed")
        local blast_duration = blast_radius / blast_speed
        local current_loc = caster:GetAbsOrigin()
        local target_type = DOTA_UNIT_TARGET_TEAM_ENEMY

        local hypo = caster:FindAbilityByName("icebreaker_1__hypo")
        if hypo == nil then return end
        if hypo:IsTrained() == false then return end

        self:PlayEfxActive(blast_radius, blast_duration, blast_speed)

        -- UP 5.11
        if self:GetRank(11) then
            frozen_duration = frozen_duration * 2
        end

        -- UP 5.21
        if self:GetRank(21) then
            target_type = DOTA_UNIT_TARGET_TEAM_BOTH
            caster:AddNewModifier(caster, self, "_modifier_movespeed_buff", {
                duration = blast_duration,
                percent = 50
            })
        end

        local targets_hit = {}
        local current_radius = 0
        local tick_interval = 0.1

        Timers:CreateTimer(tick_interval, function()
            AddFOWViewer(caster:GetTeamNumber(), current_loc, current_radius, 0.1, false)
            current_radius = current_radius + blast_speed * tick_interval
            current_loc = caster:GetAbsOrigin()

            local nearby_enemies = FindUnitsInRadius(
                caster:GetTeamNumber(), current_loc, nil, current_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false
            )

            for _,enemy in pairs(nearby_enemies) do
                if enemy ~= caster then
                    local enemy_has_been_hit = false
                    for _,enemy_hit in pairs(targets_hit) do
                        if enemy == enemy_hit then enemy_has_been_hit = true end
                    end

                    if not enemy_has_been_hit then
                        targets_hit[#targets_hit + 1] = enemy

                        if enemy:GetTeamNumber() == caster:GetTeamNumber() then
                            local heal = 275
                            local base_stats = caster:FindAbilityByName("base_stats")
                            if base_stats then heal = heal * base_stats:GetHealPower() end
                            if heal > 0 then enemy:Heal(heal, self) end
                        else
                            if enemy:HasModifier("strider_1_modifier_spirit") == false
                            and enemy:HasModifier("bloodstained_u_modifier_copy") == false
                            and enemy:IsIllusion() then
                                enemy:Kill(self, caster)
                            elseif enemy:IsHero() then
                                enemy:AddNewModifier(caster, hypo, "icebreaker_1_modifier_frozen", {
                                    duration = self:CalcStatus(frozen_duration, caster, enemy) 
                                })
                            else
                                hypo:AddSlow(enemy, self, 5, true)
                            end
                        end
                        
                        self:PlayEfxHit(enemy)
                    end
                end
            end

            if current_radius < blast_radius then
                return tick_interval
            end
        end)
    end

    function icebreaker_5__wave:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function icebreaker_5__wave:PlayEfxActive(blast_radius, blast_duration, blast_speed)
        local caster = self:GetCaster()
        local blast_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(blast_pfx, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(blast_pfx, 1, Vector(blast_radius, blast_duration * 1.33, blast_speed))
        ParticleManager:ReleaseParticleIndex(blast_pfx)

        if IsServer() then caster:EmitSound("DOTA_Item.ShivasGuard.Activate") end
    end

    function icebreaker_5__wave:PlayEfxHit(enemy)
        local caster = self:GetCaster()
        local hit_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
        ParticleManager:SetParticleControl(hit_pfx, 0, enemy:GetAbsOrigin())
        ParticleManager:SetParticleControl(hit_pfx, 1, enemy:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(hit_pfx)
    end