ancient_2__leap = class({})
LinkLuaModifier("ancient_2_modifier_combo", "heroes/ancient/ancient_2_modifier_combo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_2_modifier_jump", "heroes/ancient/ancient_2_modifier_jump", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_generic_arc", "modifiers/_modifier_generic_arc", LUA_MODIFIER_MOTION_BOTH)
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
        
        if self:GetLevel() == 1 then
			caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_RES"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_REC"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_MND"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true)
		end
        
        self:SetCharges(nil)
    end

    function ancient_2__leap:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.temp_charge = 1
    end

    function ancient_2__leap:SetCharges(value)
        if value ~= nil then self.temp_charge = value end
        local charges = self.temp_charge

        -- UP 2.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        -- UP 2.32
        if self:GetRank(32) then
            charges = charges * 3
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- SPELL START

    function ancient_2__leap:OnAbilityPhaseStart()
        local caster = self:GetCaster()

        -- UP 2.32
        if self:GetRank(32) then
            self.point = self:GetCursorPosition()
            local jump_range = 900 --self:GetCastRange(self.point, nil)
            local distance = (caster:GetOrigin() - self.point):Length2D()
            local percent = distance / jump_range
            self.duration = percent * 1.5
            self.height = jump_range * 0.4 * percent

            caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)

            if self.duration < 0.4 then
                Timers:CreateTimer((self.duration), function()
                    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
                    caster:StartGesture(ACT_DOTA_CAST_ABILITY_5)
                    if IsServer() then caster:EmitSound("Hero_ElderTitan.PreAttack") end
                end)
            end

            if self.duration >= 0.6 then
                Timers:CreateTimer((0.2), function()
                    if IsServer() then caster:EmitSound("Ancient.Jump") end
                end)
            end

            return true
        end

        if IsServer() then caster:EmitSound("Hero_ElderTitan.PreAttack") end

        return true
    end

    function ancient_2__leap:OnSpellStart()
        -- UP 2.32
        if self:GetRank(32) then
            local caster = self:GetCaster()
            caster:RemoveModifierByName("ancient_2_modifier_jump")
            caster:AddNewModifier(caster, self, "ancient_2_modifier_jump", {})
            return
        end

        self:CheckCombo()
    end

    function ancient_2__leap:CheckCombo()
        -- UP 2.41
        if self:GetRank(41) then
            local caster = self:GetCaster()
            caster:RemoveModifierByName("ancient_2_modifier_combo")
            caster:AddNewModifier(caster, self, "ancient_2_modifier_combo", {})
            return
        end

        self:DoImpact()
    end

    function ancient_2__leap:DoImpact()
        local caster = self:GetCaster()
        local point = caster:GetOrigin()
        local radius = self:GetAOERadius()
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
        GridNav:DestroyTreesAroundPoint(point, radius, false)

        -- UP 2.41
        local flag = 0
        if self:GetRank(41) then
            damage = damage - 30
            flag = 16
        end

        local mana_gain = 0
        local damageTable = {
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self
        }

        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), point, nil, radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            flag, 0, false
        )

        for _,enemy in pairs(enemies) do
            if berserk then enemy:AddNewModifier(caster, berserk, "ancient_1_modifier_original", {}) end
            if str then str:EnableForceSpellCrit(0, has_crit) end         

            damageTable.victim = enemy
            ApplyDamage(damageTable)
            
            enemy:RemoveModifierByName("ancient_1_modifier_original")

            if mana_gain == 0 then
                mana_gain = self:GetSpecialValueFor("mana_gain") + self:GetSpecialValueFor("mana_gain_bonus")
            else
                mana_gain = mana_gain + self:GetSpecialValueFor("mana_gain_bonus")
            end

            if enemy:IsAlive() then
                -- UP 2.12
                if self:GetRank(12) then
                    enemy:AddNewModifier(caster, self, "_modifier_break", {
                        duration = self:CalcStatus(3 * (special + 1), caster, enemy),
                    })
                end
            end
        end

        if has_crit ~= nil then mana_gain = mana_gain * self:GetSpecialValueFor("mana_gain_crit") end
        if mana_gain > 0 then
            caster:GiveMana(mana_gain)
		    SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, caster, mana_gain, caster)
        end
    end

	function ancient_2__leap:GetAOERadius()
		if self:GetCurrentAbilityCharges() == 0 then return self:GetSpecialValueFor("radius") end
        if self:GetCurrentAbilityCharges() == 1 then return self:GetSpecialValueFor("radius") end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return self:GetSpecialValueFor("radius") + 75 end
        return self:GetSpecialValueFor("radius")
	end

    function ancient_2__leap:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return self:GetSpecialValueFor("radius") end
        if self:GetCurrentAbilityCharges() == 1 then return self:GetSpecialValueFor("radius") end
        if self:GetCurrentAbilityCharges() % 3 == 0 and self:GetCurrentAbilityCharges() % 5 == 0 then return 200 end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return 900 end
        return self:GetSpecialValueFor("radius") + 75
    end

    function ancient_2__leap:GetBehavior()
        if self:GetCurrentAbilityCharges() == 0 then return DOTA_ABILITY_BEHAVIOR_NO_TARGET end
        if self:GetCurrentAbilityCharges() == 1 then return DOTA_ABILITY_BEHAVIOR_NO_TARGET end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES end
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
    
    function ancient_2__leap:GetCastAnimation()
        if self:GetCurrentAbilityCharges() == 0 then return ACT_DOTA_CAST_ABILITY_5 end
        if self:GetCurrentAbilityCharges() == 1 then return ACT_DOTA_CAST_ABILITY_5 end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return end
        return ACT_DOTA_CAST_ABILITY_5
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