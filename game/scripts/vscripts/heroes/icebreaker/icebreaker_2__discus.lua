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

    function icebreaker_2__discus:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
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
        
        if self:GetLevel() == 1 then
			caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_RES"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_REC"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_MND"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true)
		end
    end

    function icebreaker_2__discus:Spawn()
    end

-- SPELL START

    function icebreaker_2__discus:OnSpellStart()

        local caster = self:GetCaster()
        local cursorPt = self:GetCursorPosition()
        local casterPt = caster:GetAbsOrigin()

        if IsServer() then caster:EmitSound("Hero_Ancient_Apparition.IceBlast.Target") end
        
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

        -- UP 2.22
        if self:GetRank(22) then
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
        if target:IsInvulnerable() or target:IsMagicImmune() then return end
        if target:HasModifier("icebreaker_0_modifier_freeze") then return end

        if self.first_hit == false then
            caster:MoveToTargetToAttack(target)
            self.first_hit = true
        end

        -- UP 2.13
        if self:GetRank(13) then
            local burned_mana = target:GetMaxMana() * 0.1
            if burned_mana > target:GetMana() then burned_mana = target:GetMana() end
            if target:GetUnitName() == "npc_dota_hero_elder_titan" then burned_mana = burned_mana * 0.5 end

            if burned_mana > 0 then
                target:ReduceMana(burned_mana)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, burned_mana, caster)

                self.damageTable.victim = target
                self.damageTable.damage = burned_mana
                ApplyDamage(self.damageTable)
            end
        end

        -- UP 2.22
        if self:GetRank(22) then
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
            -- UP 2.12
            if self:GetRank(12) then
                target:AddNewModifier(caster, self, "_modifier_silence", {
                    duration = self:CalcStatus(2.5, caster, target)
                })
            end

            -- UP 2.41
            if self:GetRank(41) then
                local illu = CreateIllusions(
                    caster, caster,
                    {
                        outgoing_damage = -100,
                        incoming_damage = 0,
                        bounty_base = 0,
                        bounty_growth = 0,
                        duration = self:CalcStatus(7, caster, nil),
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