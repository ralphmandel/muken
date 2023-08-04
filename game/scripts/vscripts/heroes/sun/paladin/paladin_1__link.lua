paladin_1__link = class({})
LinkLuaModifier("paladin_1_modifier_link", "heroes/sun/paladin/paladin_1_modifier_link", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("paladin_1_modifier_regen", "heroes/sun/paladin/paladin_1_modifier_regen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function paladin_1__link:CastFilterResultTarget(hTarget)
    local caster = self:GetCaster()
    if caster == hTarget then return UF_FAIL_CUSTOM end

    local result = UnitFilter(
      hTarget, self:GetAbilityTargetTeam(),
      self:GetAbilityTargetType(),
      self:GetAbilityTargetFlags(),
      caster:GetTeamNumber()
    )
    
    if result ~= UF_SUCCESS then return result end

    return UF_SUCCESS
  end

  function paladin_1__link:GetCustomCastErrorTarget(hTarget)
    if self:GetCaster() == hTarget then return "#dota_hud_error_cant_cast_on_self" end
  end

-- SPELL START

	function paladin_1__link:OnSpellStart()
		local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    target:RemoveModifierByName("paladin_1_modifier_link")
    AddModifier(target, self, "paladin_1_modifier_link", {duration = self:GetSpecialValueFor("duration")}, true)
  end

-- EFFECTS