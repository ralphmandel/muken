base_stats_mod = class ({})

-- MOD PROPERTIES

    function base_stats_mod:IsHidden()
        return true
    end

    function base_stats_mod:IsPermanent()
        return true
    end

    function base_stats_mod:IsPurgable()
        return false
    end

-- INIT

    function base_stats_mod:OnCreated(kv)
        if IsServer() then
            self.caster = self:GetCaster()
            self.parent = self:GetParent()
            self.ability = self:GetAbility()

            self.popup_spell_crit = false
            self.pierce_proc = false

            if self.parent:IsIllusion() then
                self.ability:LoadDataForIllusion()
            else
                self.ability:AddBaseStatsPoints()
                self.ability:IncrementSpenderPoints(0, 0)
            end

			self.ability:LoadSpecialValues()
        end
    end

    function base_stats_mod:OnRefresh(kv)
    end


-- DECLARE FUNCTIONS AND STATES

    function base_stats_mod:CheckState()
        local state = {}
        
        if self.ability.total_crit_damage > 0 and self.pierce_proc then
            state = {[MODIFIER_STATE_CANNOT_MISS] = true}
        end

        return state
    end

    function base_stats_mod:DeclareFunctions()

        local funcs = {
            MODIFIER_EVENT_ON_TAKEDAMAGE, -- POPUP DAMAGE TYPES
            MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, --SPELL DAMAGE AND CRIT CALC

            -- STR
            MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
            MODIFIER_PROPERTY_STATUS_RESISTANCE,
            MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
            MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
            MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
            MODIFIER_PROPERTY_PRE_ATTACK,
            MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
            MODIFIER_PROPERTY_MAGICAL_CONSTANT_BLOCK,

            -- AGI
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
            MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
            MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
            MODIFIER_PROPERTY_MOVESPEED_LIMIT,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
            MODIFIER_EVENT_ON_RESPAWN,

            -- INT
            MODIFIER_PROPERTY_MANA_BONUS,
            MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,

            -- CON
            MODIFIER_PROPERTY_HEALTH_BONUS,
            MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
            MODIFIER_EVENT_ON_HEAL_RECEIVED,

            --SECONDARY
            MODIFIER_PROPERTY_EVASION_CONSTANT,
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
            MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        }
        return funcs
    end

    function base_stats_mod:OnTakeDamage(keys)
        if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then return end
    
        if keys.unit == self.parent then
            local efx = nil
            if keys.damage_type == DAMAGE_TYPE_MAGICAL then efx = OVERHEAD_ALERT_BONUS_SPELL_DAMAGE end
            if keys.damage_type == DAMAGE_TYPE_PURE then self:PopupDamage(math.floor(keys.damage), Vector(255, 225, 175), self.parent) end
        
            if keys.inflictor ~= nil then
                if keys.inflictor:GetClassname() == "ability_lua" then
                    if keys.inflictor:GetAbilityName() == "shadow_0__toxin" 
                    or keys.inflictor:GetAbilityName() == "dasdingo_4__tribal" then
                        efx = OVERHEAD_ALERT_BONUS_POISON_DAMAGE
                    end
                end
            end
        
            if efx ~= nil then
                SendOverheadEventMessage(nil, efx, self.parent, keys.damage, self.parent)
            end
        end

        if keys.attacker == nil then return end
        if keys.attacker:IsBaseNPC() == false then return end
        if keys.attacker ~= self.parent then return end

        if self.popup_spell_crit then
            self:PopupSpellCrit(keys.damage, keys.unit, keys.damage_type)
        end
    end

    function base_stats_mod:GetModifierSpellAmplify_Percentage(keys)
        if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then return end
        self.popup_spell_crit = false
        local calc = 0

        if keys.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
            if keys.damage_type == DAMAGE_TYPE_PHYSICAL then
                calc = self.ability.stat_total["STR"] * self.ability.damage * 2.5
            elseif keys.damage_type == DAMAGE_TYPE_MAGICAL then
                calc = self.ability.stat_total["INT"] * self.ability.spell_amp
                return calc
            else
                return
            end

            self.ability.total_crit_damage = self.ability:CalcCritDamage(keys.damage_type)
            local crit = self.ability.total_crit_damage - 100
            local critical_chance = self.ability:GetCriticalChance()

            if self.ability.crit_damage_spell[keys.damage_type] > 0 then
                crit = self.ability.crit_damage_spell[keys.damage_type] - 100
                self.ability.crit_damage_spell[keys.damage_type] = 0
            end

            if self.ability.force_crit_spell[keys.damage_type] == nil then
                self.ability.force_crit_spell[keys.damage_type] = false
                self.ability.has_crit = false
            else
                if ((RandomFloat(1, 100) <= critical_chance * self.ability.critical_chance)
                or self.ability.force_crit_spell[keys.damage_type] == true)
                and not keys.target:IsBuilding() then
                    calc = calc + crit + (calc * crit * 0.01)
                    self.popup_spell_crit = true
                    self.ability.force_crit_spell[keys.damage_type] = false
                    self.ability.has_crit = true
                else
                    self.ability.has_crit = false
                end
            end

            return calc
        end
    end

-- STR

    function base_stats_mod:GetModifierBaseAttack_BonusDamage()
        return self.ability.stat_total["STR"] * self.ability.damage
    end

    function base_stats_mod:GetModifierStatusResistance()
        if self.parent:GetAttackCapability() == 1 then
            return self.ability.total_status_resist + self.ability.bonus_status_resist
        end

        return 0
    end

    function base_stats_mod:GetModifierAttackRangeBonus()
        if self.parent:GetAttackCapability() == 2 then
            return self.ability.total_range
        end
        
        return 0
    end

    function base_stats_mod:GetModifierProcAttack_Feedback(keys)
        if self.record then
            self.record = nil
            if self.ability.total_crit_damage > 0 then
                if IsServer() then self.parent:EmitSound("Item_Desolator.Target") end
            end
        end
    end

    function base_stats_mod:GetModifierPreAttack_CriticalStrike(keys)
        if self.pierce_proc == true or self.ability.force_crit_hit == true then
            self.pierce_proc = false
            self.ability.force_crit_hit = false

            if not keys.target:IsBuilding() then
                self.record = keys.record
                self.ability.has_crit = true
                self.ability.total_crit_damage = self.ability:CalcCritDamage(DAMAGE_TYPE_PHYSICAL)
                return self.ability.total_crit_damage
            else
                self.ability.has_crit = false
            end
        else
            self.ability.has_crit = false
        end
    end

    function base_stats_mod:GetModifierPreAttack(keys)
        if keys.attacker == self.parent then
            if self.ability:RollChance() then
                self.pierce_proc = true
            else
                self.pierce_proc = false
            end
        end
    end

    function base_stats_mod:GetModifierPhysical_ConstantBlock(keys)
        if RandomInt(1, 100) <= self.ability.block_chance then
            local total_block_percent = self.ability.base_block_damage + self.ability.physical_block
            local random_block = RandomFloat(1, total_block_percent)
            local calc = math.floor(keys.damage * random_block * 0.01)
            if calc > 0 then return calc end
        end
    end

    function base_stats_mod:GetModifierMagical_ConstantBlock(keys)
        if keys.damage_flags == DOTA_DAMAGE_FLAG_BYPASSES_BLOCK then return 0 end
        if RandomInt(1, 100) <= self.ability.block_chance then
            local total_block_percent = self.ability.base_block_damage + self.ability.magical_block
            local random_block = RandomFloat(1, total_block_percent)
            local calc = math.floor(keys.damage * random_block * 0.01)
            if calc > 0 then return calc end
        end
    end
    

-- AGI

    function base_stats_mod:GetModifierMoveSpeedBonus_Percentage_Unique(keys)
        return (10000) / self.ability.total_movespeed
    end

    function base_stats_mod:GetModifierMoveSpeedOverride(keys)
        return self.ability.total_movespeed
    end

    function base_stats_mod:GetModifierIgnoreMovespeedLimit()
        return 1
    end

    function base_stats_mod:GetModifierMoveSpeed_Limit()
        return (self.ability.total_movespeed * 2) + 100
    end

    function base_stats_mod:GetModifierAttackSpeedBonus_Constant()
        if self.parent:HasModifier("ancient_1_modifier_berserk") then return 0 end
        return self.ability.stat_total["AGI"] * self.ability.attack_speed
    end

    function base_stats_mod:GetModifierBaseAttackTimeConstant()
        return self.ability.attack_time
    end

    function base_stats_mod:OnRespawn(keys)
        if keys.unit == self.parent then
            self.ability:SetBaseAttackTime(0)
        end
    end

-- INT

    function base_stats_mod:GetModifierManaBonus()
        return self.ability.stat_total["INT"] * self.ability.mana
    end

    function base_stats_mod:GetModifierConstantManaRegen()
        if IsServer() then
            return self.ability.stat_total["INT"] * 0.1 * self.ability.mp_regen_state
        end
    end

-- CON

    function base_stats_mod:GetModifierHealthBonus()
        if IsServer() then
            return self.ability.stat_total["CON"] * self.ability.health_bonus
        end
    end

    function base_stats_mod:GetModifierConstantHealthRegen()
        if IsServer() then
            return self.ability.total_health_regen * self.ability.hp_regen_state
        end
    end

    function base_stats_mod:OnHealReceived(keys)
        if keys.unit ~= self.parent then return end
        if keys.inflictor == nil then return end
        if keys.gain < 1 then return end

        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, keys.unit, keys.gain, keys.unit)
    end

-- SECONDARY

    function base_stats_mod:GetModifierEvasion_Constant()
        local value = self.ability.stat_total["DEX"] * self.ability.evade
        local calc = (value * 6) / (1 +  (value * 0.06))
        return calc
    end

    function base_stats_mod:GetModifierPhysicalArmorBonus()
        return self.ability.stat_total["DEF"] * self.ability.armor
    end

    function base_stats_mod:GetModifierMagicalResistanceBonus()
        local value = self.ability.stat_total["RES"] * self.ability.magic_resist
        local calc = (value * 6) / (1 +  (value * 0.06))
        return calc
    end
    
    function base_stats_mod:GetModifierPercentageCooldown()
        local value = self.ability.stat_total["REC"] * self.ability.cooldown
        local calc = (value * 6) / (1 +  (value * 0.06))
        return calc
    end

-- EFFECTS

    function base_stats_mod:PopupSpellCrit(damage, target, damage_type)
        if damage_type == DAMAGE_TYPE_PHYSICAL then
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, math.floor(damage), target)
            if IsServer() then target:EmitSound("Item_Desolator.Target") end
        end

        if damage_type == DAMAGE_TYPE_MAGICAL then
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, math.floor(damage), target)
            --self:PopupDamage(math.floor(damage), Vector(153, 0, 204), target)
            if IsServer() then target:EmitSound("Crit_Magical") end
        end
    end

    function base_stats_mod:PopupDamage(damage, color, target)
        local digits = 1
        if damage < 10 then digits = 2 end
        if damage > 9 and damage < 100 then digits = 3 end
        if damage > 99 and damage < 1000 then digits = 4 end
        if damage > 999 then digits = 5 end
    
        local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(pidx, 1, Vector(0, damage, 4))
        ParticleManager:SetParticleControl(pidx, 2, Vector(3, digits, 0))
        ParticleManager:SetParticleControl(pidx, 3, color)
    end