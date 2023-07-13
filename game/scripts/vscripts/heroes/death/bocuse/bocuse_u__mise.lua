bocuse_u__mise = class({})
LinkLuaModifier("bocuse_u_modifier_passive", "heroes/death/bocuse/bocuse_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_u_modifier_mise", "heroes/death/bocuse/bocuse_u_modifier_mise", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_u_modifier_mise_status_efx", "heroes/death/bocuse/bocuse_u_modifier_mise_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_u_modifier_jump", "heroes/death/bocuse/bocuse_u_modifier_jump", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_unslowable", "_modifiers/_modifier_unslowable", LUA_MODIFIER_MOTION_NONE)

-- INIT

	function bocuse_u__mise:Spawn()
    self.autocast = false
		self.kills = 0
	end

  function bocuse_u__mise:OnOwnerSpawned()
		self:SetActivated(true)
	end

-- SPELL START

	function bocuse_u__mise:GetIntrinsicModifierName()
		return "bocuse_u_modifier_passive"
	end

	function bocuse_u__mise:OnSpellStart()
		local caster = self:GetCaster()
    self.autocast = false

    AddModifier(caster, caster, self, "bocuse_u_modifier_mise", {duration = self:GetSpecialValueFor("duration")}, true)
	end

-- EFFECTS