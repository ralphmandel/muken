genuine_5__nightfall = class({})
LinkLuaModifier("genuine_5_modifier_nightfall", "heroes/team_moon/genuine/genuine_5_modifier_nightfall", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function genuine_5__nightfall:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
  end

-- SPELL START

	function genuine_5__nightfall:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS