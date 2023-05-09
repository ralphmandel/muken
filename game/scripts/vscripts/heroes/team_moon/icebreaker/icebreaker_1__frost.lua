icebreaker_1__frost = class({})
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant", "heroes/team_moon/icebreaker/icebreaker__modifier_instant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_instant_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_passive", "heroes/team_moon/icebreaker/icebreaker_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_passive_status_efx", "heroes/team_moon/icebreaker/icebreaker_1_modifier_passive_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_hits", "heroes/team_moon/icebreaker/icebreaker_1_modifier_hits", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_illusion", "heroes/team_moon/icebreaker/icebreaker_1_modifier_illusion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_permanent_movespeed_buff", "modifiers/_modifier_permanent_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function icebreaker_1__frost:GetBehavior()
    if self:GetSpecialValueFor("special_hits") > 0 then
      return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
  end

-- SPELL START

	function icebreaker_1__frost:GetIntrinsicModifierName()
		return "icebreaker_1_modifier_passive"
	end

  function icebreaker_1__frost:OnSpellStart()
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "icebreaker_1_modifier_hits", {
      duration = CalcStatus(self:GetSpecialValueFor("special_hits_duration"), caster, caster)
    })
	end

  function icebreaker_1__frost:PerformFrostAttack(target, damage)
    local caster = self:GetCaster()
    local bonus_damage = self:GetSpecialValueFor("special_bonus_damage")

    if bonus_damage > 0 then
      ApplyDamage({
        attacker = caster, victim = target,
        damage = bonus_damage,
        damage_type = self:GetAbilityDamageType(),
        ability = self
      })
    end

    target:AddNewModifier(caster, self, "icebreaker__modifier_hypo", {
      stack = self:GetSpecialValueFor("hypo_stack")
    })

    if self:GetSpecialValueFor("special_cleave") == 1 then
      DoCleaveAttack(caster, target, self, damage, 100, 400, 500,
        "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_crit.vpcf"
      )
    end

    if RandomFloat(0, 100) < self:GetSpecialValueFor("special_mini_freeze_chance")
    and target:HasModifier("icebreaker__modifier_frozen") == false then
      target:AddNewModifier(caster, self, "icebreaker__modifier_instant", {
        duration = CalcStatus(self:GetSpecialValueFor("special_mini_freeze"), caster, target)
      })
    end

    if RandomFloat(0, 100) < self:GetSpecialValueFor("special_blink_chance")
    and target:HasModifier("icebreaker__modifier_frozen") == false then
      self:PerformAutoBlink(target)
    end
  end

  function icebreaker_1__frost:PerformAutoBlink(target)
    local caster = self:GetCaster()
    if caster:IsRooted() then return end
  
    local original_loc = caster:GetOrigin()
    local forward = caster:GetForwardVector()
    local direction = (original_loc - target:GetOrigin()):Normalized() * (-1)
    local blink_point = target:GetAbsOrigin() + direction * caster:Script_GetAttackRange()
  
    self:PlayEfxAutoBlink()
    caster:SetAbsOrigin(blink_point)
    caster:SetForwardVector(-direction)
    FindClearSpaceForUnit(caster, blink_point, true)

		local illu_array = CreateIllusions(caster, caster, {
			outgoing_damage = -100 + self:GetSpecialValueFor("special_copy_outgoing"),
			incoming_damage = self:GetSpecialValueFor("special_copy_incoming"),
			bounty_base = 0,
			bounty_growth = 0,
			duration = self:GetSpecialValueFor("special_copy_duration")
		}, 1, 64, false, true)

		for _,illu in pairs(illu_array) do
			illu:SetAbsOrigin(original_loc)
			illu:SetForwardVector(forward)
			illu:SetForceAttackTarget(target)
			FindClearSpaceForUnit(illu, original_loc, true)
      illu:AddNewModifier(caster, self, "icebreaker_1_modifier_illusion", {})
		end		
  end

-- EFFECTS

  function icebreaker_1__frost:PlayEfxAutoBlink()
    local caster = self:GetCaster()
    local particle_cast = "particles/econ/events/winter_major_2017/blink_dagger_start_wm07.vpcf" 
    local effect_cast_a = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(effect_cast_a, 0, caster:GetOrigin())
    --ParticleManager:SetParticleControlForward(effect_cast_a, 0, direction:Normalized())
    --ParticleManager:SetParticleControl(effect_cast_a, 1, origin + direction)
    ParticleManager:ReleaseParticleIndex(effect_cast_a)

    if IsServer() then caster:EmitSound("Hero_QueenOfPain.Blink_out") end
  end