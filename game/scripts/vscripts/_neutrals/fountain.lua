fountain = class({})
LinkLuaModifier( "fountain_modifier", "_neutrals/fountain_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "fountain_modifier_aura_effect", "_neutrals/fountain_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE )

function fountain:GetIntrinsicModifierName()
	return "fountain_modifier_aura_effect"
end

-- function fountain:Spawn()
--     local caster = self:GetCaster()
--     CreateModifierThinker(caster, self, "fountain_modifier", {}, caster:GetOrigin(), caster:GetTeamNumber(), false)
-- end