genuine_1__shooting = class({})
LinkLuaModifier("genuine_1_modifier_orb", "heroes/moon/genuine/genuine_1_modifier_orb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_1_modifier_starfall_stack", "heroes/moon/genuine/genuine_1_modifier_starfall_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "_modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear", "_modifiers/_modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear_status_efx", "_modifiers/_modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function genuine_1__shooting:Spawn()
    Timers:CreateTimer(0.2, function()
      if self:IsTrained() == false then
        self:UpgradeAbility(true)
        BaseStats(self:GetCaster()):AddManaExtra(self)
      end
    end)
  end

  function genuine_1__shooting:GetIntrinsicModifierName()
		return "genuine_1_modifier_orb"
	end

	function genuine_1__shooting:GetProjectileName()
		return "particles/genuine/shooting_star/genuine_shooting.vpcf"
	end

-- SPELL START

  function genuine_1__shooting:OnOrbFire(keys)
    local caster = self:GetCaster()
    if IsServer() then caster:EmitSound("Hero_DrowRanger.FrostArrows") end
  end

  function genuine_1__shooting:OnOrbImpact(keys)
    local caster = self:GetCaster()
    if IsServer() then keys.target:EmitSound("Hero_DrowRanger.Marksmanship.Target") end

    ApplyDamage({
      victim = keys.target, attacker = caster,
      damage = self:GetSpecialValueFor("damage"),
      damage_type = self:GetAbilityDamageType(),
      ability = self
    })
  end

  function genuine_1__shooting:OnOrbFail(keys)
  end

-- EFFECTS