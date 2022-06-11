bocuse_1__julienne = class ({})
LinkLuaModifier("bocuse_1_modifier_charges", "heroes/bocuse/bocuse_1_modifier_charges", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_1_modifier_julienne", "heroes/bocuse/bocuse_1_modifier_julienne", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_1_modifier_bleed", "heroes/bocuse/bocuse_1_modifier_bleed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bocuse_1__julienne:CalcStatus(duration, caster, target)
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
                    local value = base_stats_target.res_total * 0.01
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - calc)
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
                        local value = (base_stats_caster.int_total - base_stats_target.res_total) * 0.01
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + calc)
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - calc)
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function bocuse_1__julienne:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bocuse_1__julienne:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bocuse_1__julienne:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("bocuse__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

        return att.talents[1][upgrade]
    end

    function bocuse_1__julienne:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

        local att = caster:FindAbilityByName("bocuse__attributes")
        if att then
            if att:IsTrained() then
                att.talents[1][0] = true
            end
        end
        
        

        local mod = caster:FindModifierByName("bocuse_1_modifier_charges")
        if mod then
            -- UP 1.11
            if not self.rank_1 then self.rank_1 = false end
            if self:GetRank(11) and self.rank_1 == false then
                self.rank_1 = true
                mod:StartIntervalThink(10)
            end
        end

        local charges = 1

        -- UP 1.21
        if self:GetRank(21) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function bocuse_1__julienne:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.cut = {
            [1] = "particles/bocuse/bocuse_strike_blur.vpcf",
            [2] = "particles/bocuse/bocuse_strike_blur_2.vpcf",
            [3] = "particles/bocuse/bocuse_strike_blur_3.vpcf",
            [4] = "particles/bocuse/bocuse_strike_blur_extra_1.vpcf",
            [5] = "particles/bocuse/bocuse_strike_blur_extra_2.vpcf",
            [6] = "particles/bocuse/bocuse_strike_blur_extra_3.vpcf",
            [7] = "particles/bocuse/bocuse_strike_blur_extra_4.vpcf"
        }
    end

-- SPELL START

    function bocuse_1__julienne:GetIntrinsicModifierName()
        return "bocuse_1_modifier_charges"
    end

    function bocuse_1__julienne:OnSpellStart()
        local caster = self:GetCaster()
        self.target = self:GetCursorTarget()

        local charges = caster:FindModifierByName("bocuse_1_modifier_charges")
        if charges then charges:StartIntervalThink(5) end

        if self.target:TriggerSpellAbsorb( self ) then
            if charges then
                charges:ResetHits()
                charges:DecrementStackCount()
            end
            return
        end

        caster:FadeGesture(ACT_DOTA_ATTACK)
        caster:StartGesture(ACT_DOTA_ATTACK)
        caster:AddNewModifier(caster, self, "bocuse_1_modifier_julienne", {duration = 3})
        self:AddBonus("_1_AGI", caster, 0, -500, 1)
        
        Timers:CreateTimer((0.55), function()
            if self.target ~= nil then
                if IsValidEntity(self.target) then
                    self:LandCut(self.target, self.cut[1], 1)
                end
            end
        end)
    end

    function bocuse_1__julienne:LandCut(target, particle, index)
        if target == nil then return end

        local caster = self:GetCaster()
        local max_distance = self:GetSpecialValueFor("max_distance")
        local distance = CalcDistanceBetweenEntityOBB(caster, target)
        self.cancel = true

        -- UP 1.21
        if self:GetRank(21) then
            max_distance = max_distance + 200
        end

        local charges = caster:FindModifierByName("bocuse_1_modifier_charges")
        if charges then
            charges:ResetHits()
            charges:DecrementStackCount()
            charges:StartIntervalThink(5)
            local stacks = charges:GetStackCount()
            if stacks > 0 then self.cancel = false end
        end

        local result = UF_FAIL_ENEMY
        if IsValidEntity(target) then
            result = UnitFilter(
                target,	-- Target Filter
                DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,	-- Unit Flag
                caster:GetTeamNumber()	-- Team reference
            )
        end

        if caster:IsStunned() == false
        and caster:IsHexed() == false
        and caster:IsOutOfGame() == false
        and caster:IsNightmared() == false
        and distance <= max_distance
        and result == UF_SUCCESS
        then
            if target:HasModifier("strider_1_modifier_spirit") == false
            and target:HasModifier("bloodstained_u_modifier_copy") == false
            and target:IsIllusion() then
                target:Kill(self, caster)
                self.cancel = true
            end

            -- UP 1.21
            if self:GetRank(21) then
                local forward = caster:GetForwardVector():Normalized()
                local point = target:GetOrigin() - (forward * 50)

                local units = FindUnitsInLine(
                    caster:GetTeamNumber(),	-- int, your team number
                    caster:GetOrigin(),	-- point, center point
                    point,
                    nil,	-- handle, cacheUnit. (not known)
                    50,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                    DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- int, type filter
                    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE	-- int, flag filter
                )
            
                for _,unit in pairs(units) do
                    if unit ~= target then
                        self:PlayEfxStart(unit, particle)

                        if unit:HasModifier("strider_1_modifier_spirit") == false 
                        and unit:HasModifier("bloodstained_u_modifier_copy") == false then
                            self:ApplyCut(unit, particle, false, index)
                        end
                    end
                end
            end

            self:PlayEfxStart(target, particle)
            self:ApplyCut(target, particle, true, index)
        else
            self.cancel = true
        end

        if self.cancel then
            caster:RemoveModifierByName("bocuse_1_modifier_julienne")
        else
            Timers:CreateTimer((0.25), function()
                if self.target ~= nil then
                    if IsValidEntity(self.target) then
                        self:LandCut(self.target, self.cut[index + 1], index + 1)
                    end
                end
            end)

            self:RemoveBonus("_1_AGI", caster)
            self:AddBonus("_1_AGI", caster, 0, -500, 0.75)
            caster:FadeGesture(ACT_DOTA_ATTACK)
            caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 2)
        end
    end

    function bocuse_1__julienne:ApplyCut(target, particle, original, index)
        if target:HasModifier("strider_1_modifier_spirit") == false
        and target:HasModifier("bloodstained_u_modifier_copy") == false
        and target:IsIllusion() then return end

        local caster = self:GetCaster()
        local damage = self:GetSpecialValueFor("damage")
        local charges = self:GetSpecialValueFor("charges")
        local stun_duration = self:GetSpecialValueFor("stun_duration")

        -- up 1.41
        if self:GetRank(41) then
            charges = charges + 4
        end

        --local max_cut = self.cut[charges]

        -- UP 1.12
        if self:GetRank(12) and original == true then
            stun_duration = stun_duration + 1
        end

        self:InflictBleeding(target)

        local damageTable = {
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self
        }

        local apply_damage = math.floor(ApplyDamage(damageTable))
        --if apply_damage > 0 then self:PopupCut(target, apply_damage) end
        if target:IsAlive() == false and original == true then self.cancel = true end

        if target:IsAlive() then
            if index > 2 and self.cancel == true then
                if target:IsMagicImmune() == false and original == true then
                    target:AddNewModifier(caster, self, "_modifier_stun", {duration = self:CalcStatus(stun_duration, caster, target)})
                end
            end
        end
    end

    function bocuse_1__julienne:InflictBleeding(target)
        local caster = self:GetCaster()
        local bleed_duration = self:GetSpecialValueFor("bleed_duration")

        -- UP 1.22
        if self:GetRank(22) then
            bleed_duration = bleed_duration * 2
        end
        
        target:AddNewModifier(caster, self, "bocuse_1_modifier_bleed", {duration = self:CalcStatus(bleed_duration, caster, target)})
    end

    function bocuse_1__julienne:CastFilterResultTarget( hTarget )
        local caster = self:GetCaster()
        if caster == hTarget then
            return UF_FAIL_CUSTOM
        end

        local result = UnitFilter(
            hTarget,	-- Target Filter
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,	-- Unit Flag
            caster:GetTeamNumber()	-- Team reference
        )
        
        if result ~= UF_SUCCESS then
            return result
        end

        return UF_SUCCESS
    end

    function bocuse_1__julienne:GetCustomCastErrorTarget(hTarget)
        if self:GetCaster() == hTarget then
            return "#dota_hud_error_cant_cast_on_self"
        end
    end

    function bocuse_1__julienne:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return 300 end
        if self:GetCurrentAbilityCharges() == 1 then return 300 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 500 end
    end

-- EFFECTS

    function bocuse_1__julienne:PlayEfxStart(target, particle_cast)
        local caster = self:GetCaster()
        local origin = caster:GetOrigin()
        local point = target:GetOrigin()
        
        --local forward = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
        local forward = caster:GetForwardVector():Normalized()
        local point = point - (forward * 100)
        point.z = point.z + 100

        local direction = (point - origin)

        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect_cast, 0, point)
        ParticleManager:SetParticleControlForward(effect_cast, 0, direction:Normalized())
        ParticleManager:ReleaseParticleIndex(effect_cast)

        --if IsServer() then target:EmitSound("Hero_Alchemist.ChemicalRage.Attack") end
    end

    -- function bocuse_1__julienne:PopupCut(target, amount)
    --     self:PopupNumbers(target, "crit", Vector(100, 25, 40), 1.0, amount, nil, POPUP_SYMBOL_POST_SKULL)
    -- end

    -- function bocuse_1__julienne:PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
    --     local pfxPath = string.format("particles/bocuse/bocuse_msg.vpcf", pfx)
    --     local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_OVERHEAD_FOLLOW, target) -- target:GetOwner()
    --     postsymbol = 3
        
    --     local digits = 0
    --     if number ~= nil then
    --         digits = #tostring(number)
    --     end
    --     if presymbol ~= nil then
    --         digits = digits + 1
    --     end
    --     if postsymbol ~= nil then
    --         digits = digits + 1
    --     end

    --     ParticleManager:SetParticleControl(pidx, 3, Vector(tonumber(nil), tonumber(number), tonumber(postsymbol)))
    --     ParticleManager:SetParticleControl(pidx, 4, Vector(5, digits, 0))
    --     --ParticleManager:SetParticleControl(pidx, 3, color)
    -- end