paladin_2__shield = class({})
LinkLuaModifier("paladin_2_modifier_shield", "heroes/sun/paladin/paladin_2_modifier_shield", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function paladin_2__shield:OnAbilityPhaseStart()
    local caster = self:GetCaster()

    if IsServer() then caster:EmitSound("Hero_Dawnbreaker.PreAttack") end

    return true
  end

  function paladin_2__shield:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()

    if IsServer() then caster:StopSound("Hero_Dawnbreaker.PreAttack") end
  end

	function paladin_2__shield:OnSpellStart()
		local caster = self:GetCaster()

    AddModifier(caster, self, "paladin_2_modifier_shield", {duration = self:GetSpecialValueFor("duration")}, true)
	end

-- EFFECTS