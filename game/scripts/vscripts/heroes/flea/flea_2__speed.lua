flea_2__speed = class({})
LinkLuaModifier("flea_2_modifier_passive", "heroes/flea/flea_2_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_2_modifier_speed", "heroes/flea/flea_2_modifier_speed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_2_modifier_unslow", "heroes/flea/flea_2_modifier_unslow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

	function flea_2__speed:OnUpgrade()
		if self:GetLevel() == 1 then
			self.origin = self:GetCaster():GetOrigin()
		end
	end

-- SPELL START

	function flea_2__speed:GetIntrinsicModifierName()
		return "flea_2_modifier_passive"
	end

	function flea_2__speed:OnOwnerSpawned()
		self.origin = self:GetCaster():GetOrigin()
	end

	function flea_2__speed:OnSpellStart()
		local caster = self:GetCaster()

		caster:AddNewModifier(caster, self, "flea_2_modifier_unslow", {
			duration = CalcStatus(self:GetSpecialValueFor("special_no_slow_duration"), caster, caster)
		})
	end

	function flea_2__speed:GetBehavior()
		if self:GetSpecialValueFor("special_no_slow") == 1 then
			return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
		end

		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end

-- EFFECTS