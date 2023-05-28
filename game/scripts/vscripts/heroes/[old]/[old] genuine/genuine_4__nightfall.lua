genuine_4__nightfall = class({})
LinkLuaModifier("genuine_4_modifier_aura", "heroes/team_moon/genuine/genuine_4_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_4_modifier_aura_effect", "heroes/team_moon/genuine/genuine_4_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_debuff_increase", "_modifiers/_modifier_debuff_increase", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function genuine_4__nightfall:OnOwnerSpawned()
		self:OnToggle()
	end

	function genuine_4__nightfall:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function genuine_4__nightfall:OnToggle()
		local caster = self:GetCaster()

		if self:GetToggleState() then
			caster:AddNewModifier(caster, self, "genuine_4_modifier_aura", {})
		else
			caster:RemoveModifierByName("genuine_4_modifier_aura")
		end
	end

-- EFFECTS