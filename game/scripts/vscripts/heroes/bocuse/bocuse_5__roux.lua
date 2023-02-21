bocuse_5__roux = class({})
LinkLuaModifier("bocuse_5_modifier_roux", "heroes/bocuse/bocuse_5_modifier_roux", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_5_modifier_roux_aura_effect", "heroes/bocuse/bocuse_5_modifier_roux_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function bocuse_5__roux:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function bocuse_5__roux:GetCastRange(vLocation, hTarget)
		return self:GetSpecialValueFor("cast_range")
	end

	function bocuse_5__roux:OnSpellStart()
		local caster = self:GetCaster()

		CreateModifierThinker(caster, self, "bocuse_5_modifier_roux", {
			duration = self:GetSpecialValueFor("lifetime")
		}, self:GetCursorPosition(), caster:GetTeamNumber(), false)

		-- local thinkers = Entities:FindAllByClassname("npc_dota_thinker")
		-- for _,smoke in pairs(thinkers) do
		-- 	if smoke:GetOwner() == caster and smoke:HasModifier("bocuse_5_modifier_puddle") then
    --             smoke:FindModifierByName("bocuse_5_modifier_puddle"):Destroy()
		-- 		--smoke:Kill(self, nil)
		-- 	end
		-- end
	end

-- EFFECTS