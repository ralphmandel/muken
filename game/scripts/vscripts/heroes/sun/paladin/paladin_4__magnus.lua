paladin_4__magnus = class({})
LinkLuaModifier("paladin_4_modifier_passive", "heroes/sun/paladin/paladin_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("paladin_4_modifier_aura", "heroes/sun/paladin/paladin_4_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("paladin_4_modifier_aura_effect", "heroes/sun/paladin/paladin_4_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function paladin_4__magnus:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

  function paladin_4__magnus:GetIntrinsicModifierName()
    return "paladin_4_modifier_passive"
  end

-- SPELL START

	function paladin_4__magnus:OnSpellStart()
		local caster = self:GetCaster()
    AddModifier(caster, self, "paladin_4_modifier_aura", {duration = self:GetSpecialValueFor("duration")}, true)

    if IsServer() then caster:EmitSound("Hero_ArcWarden.MagneticField.Cast") end
	end

-- EFFECTS