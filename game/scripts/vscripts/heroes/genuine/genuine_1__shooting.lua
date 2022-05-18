genuine_1__shooting = class({})
LinkLuaModifier("genuine_1_modifier_orb", "heroes/genuine/genuine_1_modifier_orb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_1_modifier_chaos", "heroes/genuine/genuine_1_modifier_chaos", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_1__shooting:CalcStatus(duration, caster, target)
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

    function genuine_1__shooting:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function genuine_1__shooting:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_1__shooting:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("genuine__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        return att.talents[1][upgrade]
    end

    function genuine_1__shooting:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        local att = caster:FindAbilityByName("genuine__attributes")
        if att then
            if att:IsTrained() then
                att.talents[1][0] = true
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
        self:SetCurrentAbilityCharges(charges)
    end

    function genuine_1__shooting:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function genuine_1__shooting:GetIntrinsicModifierName()
        return "genuine_1_modifier_orb"
    end

    function genuine_1__shooting:GetProjectileName()
        return "particles/genuine/shooting_star/genuine_shooting.vpcf"
    end

    function genuine_1__shooting:OnOrbFire(keys)
        local caster = self:GetCaster()
        if IsServer() then caster:EmitSound("Hero_DrowRanger.FrostArrows") end
    end

    function genuine_1__shooting:OnOrbImpact(keys)
        local caster = self:GetCaster()
        local bonus_damage = self:GetSpecialValueFor("bonus_damage")

        local damageTable = {
            victim = keys.target,
            attacker = caster,
            damage = bonus_damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self
        }
        ApplyDamage(damageTable)

        --if RandomInt(1, 100) <= chaos_chance
        --and keys.target:IsMagicImmune() == false then
            -- keys.target:AddNewModifier(caster, self, "genuine_1_modifier_chaos", {
            --     duration = self:CalcStatus(chaos_duration, caster, keys.target)
            -- })

            -- self:PlayEfxChaos(keys.target)
        --end

        if IsServer() then keys.target:EmitSound("Hero_DrowRanger.Marksmanship.Target") end
    end

-- EFFECTS