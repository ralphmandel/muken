genuine_1__shooting = class({})
LinkLuaModifier("genuine_1_modifier_orb", "heroes/genuine/genuine_1_modifier_orb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_1_modifier_starfall_stack", "heroes/genuine/genuine_1_modifier_starfall_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine__modifier_fear", "heroes/genuine/genuine__modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine__modifier_fear_status_efx", "heroes/genuine/genuine__modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function genuine_1__shooting:GetIntrinsicModifierName()
		return "genuine_1_modifier_orb"
	end

	function genuine_1__shooting:GetProjectileName()
		return "particles/genuine/shooting_star/genuine_shooting.vpcf"
	end

	function genuine_1__shooting:OnOrbFire(keys)
		local caster = self:GetCaster()
		if IsServer() then caster:EmitSound("Hero_DrowRanger.FrostArrows") end
	end

	function genuine_1__shooting:OnOrbImpact(keys)
		local caster = self:GetCaster()
		local starfall_tick = self:GetSpecialValueFor("special_starfall_tick")

		if starfall_tick > 0 then
			keys.target:AddNewModifier(caster, self, "genuine_1_modifier_starfall_stack", {
				duration = starfall_tick
			})
		end

		if RandomFloat(1, 100) <= self:GetSpecialValueFor("special_fear_chance") then
			keys.target:AddNewModifier(caster, self, "genuine__modifier_fear", {
				duration = CalcStatus(self:GetSpecialValueFor("special_fear_duration"), caster, keys.target)
			})
		end

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