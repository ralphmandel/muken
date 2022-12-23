striker_u__auto = class({})
LinkLuaModifier("striker_u_modifier_autocast", "heroes/striker/striker_u_modifier_autocast", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function striker_u__auto:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.mana_state = 0
    end

-- SPELL START

    function striker_u__auto:GetIntrinsicModifierName()
        return "striker_u_modifier_autocast"
    end

    function striker_u__auto:OnSpellStart()
        local caster = self:GetCaster()
        self:ToggleAutoCast()
        self:OnAutoCastChange(true)
    end

    function striker_u__auto:OnAutoCastChange(state)
        local caster = self:GetCaster()
        local cosmetics = caster:FindAbilityByName("cosmetics")
        local base_stats = caster:FindAbilityByName("base_stats")
        if base_stats == nil then return end

        if self:GetAutoCastState() == state then
            self:SetCurrentAbilityCharges(1)

            if self.mana_state == 0 then
                base_stats:SetMPRegenState(-1)
                self.mana_state = 1
            end

            if cosmetics then
                local model = "models/items/dawnbreaker/judgment_of_light_weapon/judgment_of_light_weapon.vmdl"
                local ambients = {["particles/econ/items/dawnbreaker/dawnbreaker_judgement_of_light/dawnbreaker_judgement_of_light_weapon_ambient.vpcf"] = "nil"}
                cosmetics:ApplyAmbient(ambients, caster, cosmetics:FindModifierByModel(model))
            end
        else
            self:SetCurrentAbilityCharges(0)

            if self.mana_state == 1 then
                base_stats:SetMPRegenState(1)
                self.mana_state = 0
            end

            if cosmetics then
                cosmetics:DestroyAmbient(
                    "models/items/dawnbreaker/judgment_of_light_weapon/judgment_of_light_weapon.vmdl",
                    "particles/econ/items/dawnbreaker/dawnbreaker_judgement_of_light/dawnbreaker_judgement_of_light_weapon_ambient.vpcf",
                    false
                )
            end
        end
    end

-- EFFECTS
