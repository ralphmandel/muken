genuine_3__morning = class({})
LinkLuaModifier("genuine_3_modifier_passive", "heroes/genuine/genuine_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_3_modifier_morning", "heroes/genuine/genuine_3_modifier_morning", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function genuine_3__morning:GetIntrinsicModifierName()
    return "genuine_3_modifier_passive"
  end

  function genuine_3__morning:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    caster:FindModifierByName(self:GetIntrinsicModifierName()):PlayEfxBuff()
    return true
  end

  function genuine_3__morning:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    caster:FindModifierByName(self:GetIntrinsicModifierName()):StopEfxBuff()
  end

  function genuine_3__morning:OnSpellStart()
    local caster = self:GetCaster()

    caster:AddNewModifier(caster, self, "genuine_3_modifier_morning", {
      duration = CalcStatus(self:GetSpecialValueFor("duration"), caster, caster)
    })

    if IsServer() then caster:EmitSound("Genuine.Morning") end
  end

  function genuine_3__morning:CreateStarfall(target)
		local caster = self:GetCaster()
		local point = target:GetOrigin()
		self:PlayEfxStarfall(target)

		Timers:CreateTimer(self:GetSpecialValueFor("starfall_delay"), function()
			if target then
				if IsValidEntity(target) then
					if IsServer() then
						target:EmitSound("Hero_Mirana.Starstorm.Impact")
					end			
				end
			end

			local enemies = FindUnitsInRadius(
				caster:GetTeamNumber(), point, nil,
				self:GetSpecialValueFor("starfall_radius"),
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
			)
		
			for _,enemy in pairs(enemies) do
				ApplyDamage({
					attacker = caster, victim = enemy,
					damage = self:GetSpecialValueFor("starfall_damage"),
					damage_type = DAMAGE_TYPE_MAGICAL, ability = self
				})
			end		
		end)
	end

-- EFFECTS

  function genuine_3__morning:PlayEfxStarfall(target)
    local particle_cast = "particles/genuine/starfall/genuine_starfall_attack.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)

    if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Cast") end
  end