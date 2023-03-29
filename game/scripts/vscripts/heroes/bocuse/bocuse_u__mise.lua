bocuse_u__mise = class({})
LinkLuaModifier("bocuse_u_modifier_passive", "heroes/bocuse/bocuse_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_u_modifier_mise", "heroes/bocuse/bocuse_u_modifier_mise", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_u_modifier_mise_status_efx", "heroes/bocuse/bocuse_u_modifier_mise_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_u_modifier_jump", "heroes/bocuse/bocuse_u_modifier_jump", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_unslowable", "modifiers/_modifier_unslowable", LUA_MODIFIER_MOTION_NONE)

-- INIT

	function bocuse_u__mise:Spawn()
		self.kills = 0
	end

-- SPELL START

	function bocuse_u__mise:GetIntrinsicModifierName()
		return "bocuse_u_modifier_passive"
	end

	function bocuse_u__mise:OnSpellStart()
		local caster = self:GetCaster()
		local jump_duration = self:GetSpecialValueFor("special_jump_duration")

		if jump_duration > 0 then
			caster:AddNewModifier(caster, self, "bocuse_u_modifier_jump", {duration = jump_duration})
		end

		caster:AddNewModifier(caster, self, "bocuse_u_modifier_mise", {
			duration = CalcStatus(self:GetSpecialValueFor("duration"), caster, caster)
		})
	end

-- EFFECTS