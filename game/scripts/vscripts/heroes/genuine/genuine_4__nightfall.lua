genuine_4__nightfall = class({})
LinkLuaModifier("genuine_4_modifier_passive", "heroes/genuine/genuine_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_4__nightfall:CalcStatus(duration, caster, target)
        if caster == nil or target == nil then return duration end
        if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
        local base_stats = caster:FindAbilityByName("base_stats")

        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
        else
            if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
            duration = duration * (1 - target:GetStatusResistance())
        end
        
        return duration
    end

    function genuine_4__nightfall:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function genuine_4__nightfall:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_4__nightfall:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[4][upgrade] end
    end

    function genuine_4__nightfall:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[4][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        if self:GetLevel() == 1 then self:SetCurrentAbilityCharges(1) return end
    end

    function genuine_4__nightfall:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.invi = false
    end

-- SPELL START

function genuine_4__nightfall:GetIntrinsicModifierName()
        return "genuine_4_modifier_passive"
    end

    function genuine_4__nightfall:OnSpellStart()
        self.invi = true
        local caster = self:GetCaster()
        local charges = 1

        self:SetCurrentAbilityCharges(charges)
        caster:AddNewModifier(caster, self, "_modifier_invisible", {delay = 1, spell_break = 1, attack_break = 1})
        if IsServer() then caster:EmitSound("DOTA_Item.InvisibilitySword.Activate") end
    end

    function genuine_4__nightfall:CreateStarfall(target)
        self:PlayEfxStarfall(target)

		Timers:CreateTimer((0.5), function()
			if target ~= nil then
				if IsValidEntity(target) then
					self:ApplyStarfall(target)
				end
			end
		end)
    end

    function genuine_4__nightfall:ApplyStarfall(target)
        local caster = self:GetCaster()
        local starfall_damage = 75
        local starfall_radius = 250
        local damageTable = {
            attacker = caster,
            damage = starfall_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }
        
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), target:GetOrigin(), nil, starfall_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0, 0, false
        )

        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            ApplyDamage(damageTable)
        end

        if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Impact") end
    end

    function genuine_4__nightfall:GetBehavior()
        local behavior = DOTA_ABILITY_BEHAVIOR_PASSIVE
        if self:GetCurrentAbilityCharges() == 0 then return behavior end
        if self:GetCurrentAbilityCharges() % 2 == 0 then
            behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET
        end

        return behavior
    end

    function genuine_4__nightfall:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 100 end
        return manacost * level
    end

-- EFFECTS

    function genuine_4__nightfall:PlayEfxStarfall(target)
        local particle_cast = "particles/genuine/starfall/genuine_starfall_attack.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Cast") end
    end