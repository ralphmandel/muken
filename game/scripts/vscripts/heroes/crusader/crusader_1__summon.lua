crusader_1__summon = class({})
LinkLuaModifier("crusader_1_modifier_summon", "heroes/crusader/crusader_1_modifier_summon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("crusader_1_modifier_passive", "heroes/crusader/crusader_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("crusader_1_modifier_charges", "heroes/crusader/crusader_1_modifier_charges", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("crusader_1_modifier_delay", "heroes/crusader/crusader_1_modifier_delay", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)


-- INIT

    function crusader_1__summon:CalcStatus(duration, caster, target)
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

    function crusader_1__summon:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function crusader_1__summon:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function crusader_1__summon:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("crusader__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_abaddon" then return end

        return att.talents[1][upgrade]
    end

    function crusader_1__summon:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_abaddon" then return end

        local att = caster:FindAbilityByName("crusader__attributes")
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

        -- UP 1.5
        if self:GetRank(5) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function crusader_1__summon:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function crusader_1__summon:GetIntrinsicModifierName()
        return "crusader_1_modifier_passive"
    end

    function crusader_1__summon:OnSpellStart()
        local caster = self:GetCaster()

        local charges = caster:FindModifierByName("crusader_1_modifier_charges")
        if charges then
            self:EndCooldown()
            self:StartCooldown(charges:GetRemainingTime())
        end

        -- UP 1.5
        if self:GetRank(5) then
            local passive = caster:FindModifierByName("crusader_1_modifier_passive")
            if passive then
                if passive:GetStackCount() > 0 then
                    passive:DecrementStackCount()
                end
            end
        end

        caster:AddNewModifier(caster, self, "crusader_1_modifier_delay", {})
        self:PlayEfxStart()
    end

    function crusader_1__summon:OnOwnerSpawned()
        local caster = self:GetCaster()
        local passive = caster:FindModifierByName("crusader_1_modifier_passive")

        if passive then
            -- UP 1.2
            if self:GetRank(2) then
                passive:StartIntervalThink(-1)
                passive:StartIntervalThink(RandomInt(25, 35))
            end
        end
    end

    function crusader_1__summon:GetCooldown(iLevel)
		if self:GetCurrentAbilityCharges() == 0 then return 60 end
		if self:GetCurrentAbilityCharges() == 1 then return 60 end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return 40 end
	end

    function crusader_1__summon:GetManaCost(iLevel)
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() == 1 then return 150 + (15 * (self:GetLevel() - 1)) end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 120 + (12 * (self:GetLevel() - 1)) end
    end

-- EFFECTS

    function crusader_1__summon:PlayEfxStart()
        local caster = self:GetCaster()
        local effect = ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_reincarn.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect, 0, caster:GetOrigin())

        if IsServer() then caster:EmitSound("Hero_Crusader.Summon") end
        --if IsServer() then caster:EmitSound("Hero_SkeletonKing.Reincarnate.Ghost") end --REBORN ALLIES
    end