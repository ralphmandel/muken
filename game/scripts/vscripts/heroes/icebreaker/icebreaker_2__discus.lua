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
		if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
    end

    function icebreaker_2__discus:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then base_hero.ranks[2][0] = true end

        local charges = 1
		self:SetCurrentAbilityCharges(charges)
    end

    function icebreaker_2__discus:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function icebreaker_2__discus:OnSpellStart()
        local caster = self:GetCaster()
        local cursorPt = self:GetCursorPosition()
        local casterPt = caster:GetAbsOrigin()
        local direction = cursorPt - casterPt
        direction = direction:Normalized()

        local distance = self:GetSpecialValueFor("distance")
        local speed = self:GetSpecialValueFor("speed")
        local vision_radius = self:GetSpecialValueFor("vision_radius")
        local radius = self:GetSpecialValueFor("radius")
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
            attacker = caster,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }

        -- UP 2.31
        if self:GetRank(31) then
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

        caster:AddNewModifier(caster, self, "icebreaker_2_modifier_refresh", {})
        if IsServer() then caster:EmitSound("Hero_Ancient_Apparition.IceBlast.Target") end
    end

    function icebreaker_2__discus:OnProjectileHit(target, vLocation)
        local caster = self:GetCaster()
        if target == nil then return end
        if target:HasModifier("icebreaker_0_modifier_freeze") then return end

        local ability_slow = caster:FindAbilityByName("icebreaker_0__slow")
        if ability_slow == nil then return end
	    if ability_slow:IsTrained() == false then return end
        ability_slow:AddSlow(target, self)

        if self.first_hit == false then
            caster:MoveToTargetToAttack(target)
            self.first_hit = true
        end

        -- UP 2.12
        if self:GetRank(12) then
            target:AddNewModifier(caster, self, "_modifier_silence", {
                duration = self:CalcStatus(2, caster, target)
            })
        end

        -- UP 2.22
        if self:GetRank(22) then
            local burned_mana = target:GetMaxMana() * 0.2
            if burned_mana > target:GetMana() then burned_mana = target:GetMana() end

            if burned_mana > 0 then
                target:ReduceMana(burned_mana)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, burned_mana, caster)

                self.damageTable.victim = target
                self.damageTable.damage = burned_mana
                ApplyDamage(self.damageTable)
            end
        end

        -- UP 2.31
        if self:GetRank(31) then
            local distance = self:GetSpecialValueFor("distance") - CalcDistanceBetweenEntityOBB(caster, target)
            if distance > 0 then
                self.knockbackProperties.duration = 0.25
                self.knockbackProperties.knockback_duration = 0.25
                self.knockbackProperties.knockback_distance = self:CalcStatus(distance / 2, caster, target)

                target:AddNewModifier(caster, nil, "modifier_knockback", self.knockbackProperties)
            end
        end

        -- UP 2.32
        if self:GetRank(32) then
            ability_slow:CreateIceIllusions(target, self:CalcStatus(7, caster, nil))
        end

        if IsServer() then target:EmitSound("Hero_Lich.preAttack") end
    end

    function icebreaker_2__discus:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then manacost = 0 end
        return manacost * level
    end

-- EFFECTS