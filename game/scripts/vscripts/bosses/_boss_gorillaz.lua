_boss_gorillaz = class({})
LinkLuaModifier("_boss_gorillaz_modifier_passive", "bosses/_boss_gorillaz_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mk_gorillaz_buff", "bosses/mk_gorillaz_buff", LUA_MODIFIER_MOTION_NONE)

function _boss_gorillaz:CalcStatus(duration, caster, target)
	if caster == nil or target == nil then return end
	if IsValidEntity(caster) == false or IsValidEntity(target) == false then return end
	local base_stats = caster:FindAbilityByName("base_stats")

	if caster:GetTeamNumber() == target:GetTeamNumber() then
		if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
	else
		if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
		duration = duration * (1 - target:GetStatusResistance())
	end
	
	return duration
end

function _boss_gorillaz:GetIntrinsicModifierName()
	return "_boss_gorillaz_modifier_passive"
end