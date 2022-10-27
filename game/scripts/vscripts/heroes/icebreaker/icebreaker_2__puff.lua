icebreaker_2__puff = class({})
LinkLuaModifier("icebreaker_2_modifier_recharge", "heroes/icebreaker/icebreaker_2_modifier_recharge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_2_modifier_path", "heroes/icebreaker/icebreaker_2_modifier_path", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_path", "modifiers/_modifier_path", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_phase", "modifiers/_modifier_phase", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function icebreaker_2__puff:CalcStatus(duration, caster, target)
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

    function icebreaker_2__puff:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function icebreaker_2__puff:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function icebreaker_2__puff:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
    end

    function icebreaker_2__puff:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[2][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function icebreaker_2__puff:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function icebreaker_2__puff:GetIntrinsicModifierName()
        return "icebreaker_2_modifier_recharge"
    end

    function icebreaker_2__puff:OnSpellStart()
        local caster = self:GetCaster()
        local cursorPt = self:GetCursorPosition()
        local casterPt = caster:GetAbsOrigin()
        local direction = cursorPt - casterPt
        direction = direction:Normalized()

        local distance = self:GetSpecialValueFor("distance")
        local speed = self:GetSpecialValueFor("speed")
        local radius = self:GetSpecialValueFor("radius")
        local vision_radius = self:GetSpecialValueFor("radius")
        local flag = DOTA_UNIT_TARGET_FLAG_NONE
        
        local info = {
            Ability = self,
            EffectName = "particles/units/heroes/hero_drow/drow_silence_wave.vpcf",
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
        if IsServer() then caster:EmitSound("Hero_Ancient_Apparition.IceBlast.Target") end
    end

    function icebreaker_2__puff:OnProjectileHit(target, vLocation)
        if target == nil then return end

        local caster = self:GetCaster()
        local stack = self:GetSpecialValueFor("stack")
        local ability_hypo = caster:FindAbilityByName("icebreaker_1__hypo")

        -- UP 2.22
        if self:GetRank(22) then
            local rand = RandomInt(1, 12)
            if rand > 3 then
                if rand > 7 then
                    stack = 5
                else
                    stack = 4
                end
            end
        end

        if ability_hypo then
	        if ability_hypo:IsTrained() then
                ability_hypo:AddSlow(target, self, stack, true)
            end
        end

        if self.first_hit == false then
            caster:MoveToTargetToAttack(target)
            self.first_hit = true
        end

        -- UP 2.11
        if self:GetRank(11) then
            local burned_mana = target:GetMaxMana() * 0.15
            if burned_mana > target:GetMana() then burned_mana = target:GetMana() end

            if burned_mana > 0 then
                target:ReduceMana(burned_mana)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, burned_mana, caster)

                self.damageTable.victim = target
                self.damageTable.damage = burned_mana
                ApplyDamage(self.damageTable)
            end
        end

        -- UP 2.21
        if self:GetRank(21) then
            target:AddNewModifier(caster, self, "_modifier_silence", {
                duration = self:CalcStatus(2, caster, target)
            })
        end

        -- UP 2.31
        if self:GetRank(31) then
            local distance = self:GetSpecialValueFor("distance") - CalcDistanceBetweenEntityOBB(caster, target)
            if distance > 0 then
                self.knockbackProperties.duration = 0.25
                self.knockbackProperties.knockback_duration = 0.25
                self.knockbackProperties.knockback_distance = self:CalcStatus(distance / 3, caster, target)

                target:AddNewModifier(caster, nil, "modifier_knockback", self.knockbackProperties)
            end
        end

        -- UP 5.31
        local mirror = caster:FindAbilityByName("icebreaker_5__mirror")
        if mirror ~= nil then
            if mirror:GetRank(31)
            and target:IsMagicImmune() == false
            and target:IsAlive() then
                mirror:CreateMirrors(target, 1, 0, 1, 1)
            end
        end

        if IsServer() then target:EmitSound("Hero_Lich.preAttack") end
    end

    function icebreaker_2__puff:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS