icebreaker_2__discus = class({})
LinkLuaModifier("icebreaker_2_modifier_refresh", "heroes/icebreaker/icebreaker_2_modifier_refresh", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("icebreaker_2_modifier_path", "heroes/icebreaker/icebreaker_2_modifier_path", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_path", "modifiers/_modifier_path", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_phase", "modifiers/_modifier_phase", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function icebreaker_2__discus:CalcStatus(duration, caster, target)
        local time = duration
        if caster == nil then return time end
        local caster_int = caster:FindModifierByName("_1_INT_modifier")
        local caster_mnd = caster:FindModifierByName("_2_MND_modifier")

        if target == nil then
            if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
        else
            if caster:GetTeamNumber() == target:GetTeamNumber() then
                if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
            else
                local target_res = target:FindModifierByName("_2_RES_modifier")
                if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
                if target_res then time = time * (1 - target_res:GetStatus()) end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function icebreaker_2__discus:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function icebreaker_2__discus:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function icebreaker_2__discus:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("icebreaker__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        return att.talents[2][upgrade]
    end

    function icebreaker_2__discus:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        local att = caster:FindAbilityByName("icebreaker__attributes")
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
    end

    function icebreaker_2__discus:Spawn()
    end

-- SPELL START

    function icebreaker_2__discus:OnSpellStart()

        local caster = self:GetCaster()
        local cursorPt = self:GetCursorPosition()
        local casterPt = caster:GetAbsOrigin()

        if IsServer() then caster:EmitSound("Hero_DrowRanger.Silence") end
        
        local direction = cursorPt - casterPt
        direction = direction:Normalized()
        
        local speed = self:GetSpecialValueFor("speed")
        local radius = self:GetSpecialValueFor("radius")
        local vision_radius = self:GetSpecialValueFor("vision_radius")
        local distance = self:GetSpecialValueFor("distance")

        local flag = DOTA_UNIT_TARGET_FLAG_NONE
        
        local info = 
        {
            Ability = self,
            EffectName = "particles/units/heroes/hero_drow/drow_silence_wave.vpcf", --particle effect
            vSpawnOrigin = caster:GetAbsOrigin(),
            Source = caster,
            bHasFrontalCone = true,
            bReplaceExisting = false,
            fStartRadius = radius,
            fEndRadius = radius,
            fDistance = distance,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = flag,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 10.0,
            bDeleteOnHit = false,
            vVelocity = direction * speed,
            bProvidesVision = true,
            iVisionRadius = vision_radius,
            iVisionTeamNumber = caster:GetTeamNumber()
        }
        ProjectileManager:CreateLinearProjectile(info)

        self.damageTable = {
            --victim = self.parent,
            attacker = caster,
            --damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }

        -- UP 2.5
        if self:GetRank(5) then
            CreateModifierThinker(caster, self, "icebreaker_2_modifier_path", {
                x = direction.x,
                y = direction.y,
            }, casterPt, caster:GetTeamNumber(), false)

            self.knockbackProperties =
            {
                center_x = casterPt.x + 1,
                center_y = casterPt.y + 1,
                center_z = casterPt.z,
                knockback_height = 0,
            }
        end

        self.first_hit = false
        self:SetActivated(false)
        if self:IsStolen() == false then
            caster:AddNewModifier(caster, self, "icebreaker_2_modifier_refresh", {})
        end
    end

    function icebreaker_2__discus:OnProjectileHit(target, vLocation)
        local caster = self:GetCaster()

        if target == nil then return end
        if target:HasModifier("icebreaker_0_modifier_freeze") then return end

        if self.first_hit == false then
            caster:MoveToTargetToAttack(target)
            self.first_hit = true
        end

        -- UP 2.3
        if self:GetRank(3) then
            local burned_mana = target:GetMaxMana() * 0.1
            if burned_mana > target:GetMana() then burned_mana = target:GetMana() end
            target:ReduceMana(burned_mana)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, -burned_mana, caster)

            self.damageTable.victim = target
            self.damageTable.damage = burned_mana
            ApplyDamage(self.damageTable)
        end

        -- UP 2.5
        if self:GetRank(5) then
            local distance = self:GetSpecialValueFor("distance") / 3
            self.knockbackProperties.duration = 0.25
            self.knockbackProperties.knockback_duration = 0.25
            self.knockbackProperties.knockback_distance = self:CalcStatus(distance, caster, target)

            target:AddNewModifier(caster, nil, "modifier_knockback", self.knockbackProperties)
        end

        local ability_slow = caster:FindAbilityByName("icebreaker_0__slow")
        if ability_slow then
            if ability_slow:IsTrained() then
                ability_slow:AddSlow(target, self)
                if IsServer() then target:EmitSound("Hero_Lich.preAttack") end
            end
        end

        if target:HasModifier("icebreaker_0_modifier_slow") then
            -- UP 2.2
            if self:GetRank(2) then
                target:AddNewModifier(caster, self, "_modifier_silence", {
                    duration = self:CalcStatus(2.5, caster, target)
                })
            end

            -- UP 2.6
            if self:GetRank(6) then
                local illu = CreateIllusions(
                    caster, caster,
                    {
                        outgoing_damage = -100,
                        incoming_damage = -100,
                        bounty_base = 0,
                        bounty_growth = 0,
                        duration = self:CalcStatus(5, caster, nil),
                    },
                    1, 64, false, true
                )
                illu = illu[1]

                local blinkDistance = 75
                local blinkDirection = (illu:GetOrigin() - target:GetOrigin()):Normalized() * blinkDistance
                local blinkPosition = target:GetOrigin() + blinkDirection
                illu:SetOrigin( blinkPosition )
                FindClearSpaceForUnit( illu, blinkPosition, true )

                illu:AddNewModifier(caster, ability_slow, "_modifier_phase", {})
                illu:AddNewModifier(caster, ability_slow, "icebreaker_0_modifier_illusion", {})
            end
        end
    end

-- EFFECTS