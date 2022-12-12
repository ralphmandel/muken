shadowmancer_1__weapon = class({})
LinkLuaModifier("shadowmancer_1_modifier_passive", "heroes/shadowmancer/shadowmancer_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadowmancer_1_modifier_weapon", "heroes/shadowmancer/shadowmancer_1_modifier_weapon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadowmancer_1_modifier_debuff", "heroes/shadowmancer/shadowmancer_1_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadowmancer_1_modifier_debuff_stack", "heroes/shadowmancer/shadowmancer_1_modifier_debuff_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadowmancer_1_modifier_debuff_status_efx", "heroes/shadowmancer/shadowmancer_1_modifier_debuff_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function shadowmancer_1__weapon:CalcStatus(duration, caster, target)
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

    function shadowmancer_1__weapon:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function shadowmancer_1__weapon:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function shadowmancer_1__weapon:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function shadowmancer_1__weapon:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[1][0] = true
            Timers:CreateTimer(0.2, function()
				if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
			end)
        end

        self:CheckAbilityCharges(1)
    end

    function shadowmancer_1__weapon:Spawn()
        self:CheckAbilityCharges(0)
        if self:IsTrained() == false then self:UpgradeAbility(true) end
    end

-- SPELL START

    function shadowmancer_1__weapon:GetIntrinsicModifierName()
        return "shadowmancer_1_modifier_passive"
    end

    function shadowmancer_1__weapon:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local duration = self:GetSpecialValueFor("duration")

        caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):DecrementStackCount()

        target:AddNewModifier(caster, self, "shadowmancer_1_modifier_weapon", {
            duration = CalcStatus(duration, caster, target)
        })

        if IsServer() then caster:EmitSound("Hero_Visage.SoulAssumption.Cast") end
    end

    function shadowmancer_1__weapon:ApplyPoisonDamage(attacker, target, poison)
        local caster = self:GetCaster()
        local ultimate = caster:FindAbilityByName("shadowmancer_u__dagger")
        local base_stats = attacker:FindAbilityByName("base_stats")
        local poison_cap = self:GetSpecialValueFor("poison_cap")
        local crit = false

        if target:GetHealthPercent() < poison_cap then return end

        if base_stats then
            if base_stats:RollChance() then
                poison = poison * base_stats.critical_damage * 0.01
                crit = true
            end
        end
    
        local damage = ApplyDamage({
            damage = poison,
            attacker = attacker,
            victim = target,
            damage_type = self:GetAbilityDamageType(),
            ability = self,
            damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL
        })

        if ultimate then
            if ultimate:IsTrained() then
                ultimate:ApplyToxin(target, damage)
            end
        end
    
        if crit == true then
            self:PopupDamage(math.floor(damage), Vector(153, 0, 204), target)
        end

        if IsServer() then target:EmitSound("Shadowmancer.Poison.Damage") end
    end

    function shadowmancer_1__weapon:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function shadowmancer_1__weapon:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function shadowmancer_1__weapon:PopupDamage(damage, color, target)
        local digits = 1
        if damage < 10 then digits = 2 end
        if damage > 9 and damage < 100 then digits = 3 end
        if damage > 99 and damage < 1000 then digits = 4 end
        if damage > 999 then digits = 5 end

        local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(pidx, 1, Vector(0, damage, 4))
        ParticleManager:SetParticleControl(pidx, 2, Vector(3, digits, 0))
        ParticleManager:SetParticleControl(pidx, 3, color)

        if IsServer() then target:EmitSound("Crit_Magical") end
    end