ancient_2__leap = class({})
LinkLuaModifier("_modifier_break", "modifiers/_modifier_break", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function ancient_2__leap:CalcStatus(duration, caster, target)
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

    function ancient_2__leap:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function ancient_2__leap:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function ancient_2__leap:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("ancient__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        return att.talents[2][upgrade]
    end

    function ancient_2__leap:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        local att = caster:FindAbilityByName("ancient__attributes")
        if att then
            if att:IsTrained() then
                att.talents[2][0] = true
            end
        end
        
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_RES"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_REC"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_MND"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true) end

        local charges = 1

        -- UP 2.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function ancient_2__leap:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    -- function ancient_2__leap:GetChannelTime()
    --     return self:GetCaster():FindModifierByName("_2_REC_modifier"):GetChannelTimeReduction(self:GetSpecialValueFor("channel"))
    -- end

    --function ancient_2__leap:OnSpellStart()
        -- local caster = self:GetCaster()
        -- local time = self:GetChannelTime()

        -- caster:RemoveModifierByName("ancient_2_channel_leap")
        -- caster:AddNewModifier(caster, self, "ancient_2_channel_leap", {duration = time})
    --end

    function ancient_2__leap:OnSpellStart()
        local caster = self:GetCaster()
        local point = caster:GetOrigin()
        local radius = self:GetCastRange(point, nil)
        local damage = self:GetSpecialValueFor("damage")
        local berserk = caster:FindAbilityByName("ancient_1__berserk")
        local str = caster:FindModifierByName("_1_STR_modifier")
        local has_crit = nil
        local special = 0

        if str then
            if str:RollChance() == true then
                if caster:HasModifier("ancient_1_modifier_berserk") then special = 1 end
                has_crit = true
            end
        end

        self:PlayEfxStart(caster, point, radius, special)

        local damageTable = {
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self
        }

        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), point, nil, radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0, 0, false
        )

        for _,enemy in pairs(enemies) do
            if berserk then enemy:AddNewModifier(caster, berserk, "ancient_1_modifier_original", {}) end
            if str then str:EnableForceSpellCrit(0, has_crit) end         

            damageTable.victim = enemy
            ApplyDamage(damageTable)
            
            enemy:RemoveModifierByName("ancient_1_modifier_original")

            if enemy:IsAlive() then
                -- UP 2.12
                if self:GetRank(12) then
                    enemy:AddNewModifier(caster, self, "_modifier_break", {
                        duration = self:CalcStatus(3 * (special + 1), caster, enemy),
                    })
                end
            end
        end
    end

    function ancient_2__leap:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return self:GetSpecialValueFor("radius") end
        if self:GetCurrentAbilityCharges() == 1 then return self:GetSpecialValueFor("radius") end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return self:GetSpecialValueFor("radius") + 75 end
    end

-- EFFECTS

    function ancient_2__leap:PlayEfxStart(caster, point, radius, special)
        if special == 1 then
            local particle_screen = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_screen.vpcf"
            local effect_screen = ParticleManager:CreateParticleForPlayer(particle_screen, PATTACH_WORLDORIGIN, nil, caster:GetPlayerOwner())
        end

        local particle_cast = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect_cast, 0, point)
        ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))

        if IsServer() then caster:EmitSound("Hero_ElderTitan.EchoStomp") end
    end