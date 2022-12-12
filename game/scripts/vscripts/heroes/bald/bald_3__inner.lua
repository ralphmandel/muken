bald_3__inner = class({})
LinkLuaModifier("bald_3_modifier_passive", "heroes/bald/bald_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_3_modifier_passive_stack", "heroes/bald/bald_3_modifier_passive_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_3_modifier_inner", "heroes/bald/bald_3_modifier_inner", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bald_3__inner:OnUpgrade()
        local caster = self:GetCaster()
        local base_hero_mod = caster:FindModifierByName("base_hero_mod")
        if base_hero_mod then
            base_hero_mod.model_scale = 1 + (self:GetSpecialValueFor("permanent_size") * 0.01)
            self:ChangeModelScale()
        end
    end

    function bald_3__inner:Spawn()
        self:SetCurrentAbilityCharges(2)
        self.def = 0
        self.atk_range = 0
    end

-- SPELL START

    function bald_3__inner:GetIntrinsicModifierName()
        return "bald_3_modifier_passive"
    end

    function bald_3__inner:OnOwnerSpawned()
        self:SetActivated(true)
    end

    function bald_3__inner:OnSpellStart()
        local caster = self:GetCaster()
        local max_stack = self:GetSpecialValueFor("max_stack")

        local def = caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):GetStackCount()
        if def > max_stack then def = max_stack end

        caster:AddNewModifier(caster, self, "bald_3_modifier_inner", {
            duration = CalcStatus(self:GetSpecialValueFor("buff_duration"), caster, caster),
            def = def
        })

        local mod = caster:FindAllModifiersByName("bald_3_modifier_passive_stack")
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bald_3__inner:ChangeModelScale()
        local caster = self:GetCaster()
        local base_hero_mod = caster:FindModifierByName("base_hero_mod")
        if base_hero_mod == nil then return end
        if base_hero_mod.model_scale == nil then return end
    
        local extra_size = self.def * self:GetSpecialValueFor("size_mult") * 0.01
    
        caster:SetModelScale(base_hero_mod.model_scale + extra_size)
        caster:FindAbilityByName("bald__precache"):SetLevel(caster:GetModelScale() * 100)
        self.atk_range = 120 * (caster:GetModelScale() - 1)
    end

    function bald_3__inner:GetBehavior()
        return self:GetCurrentAbilityCharges()
    end

-- EFFECTS