_boss__ai = class({})
LinkLuaModifier("_boss_modifier__ai", "bosses/_boss_modifier__ai", LUA_MODIFIER_MOTION_NONE)

function _boss__ai:CalcStatus(duration, caster, target)
	if caster == nil or target == nil then return duration end
	if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
	local base_stats = caster:FindAbilityByName("base_stats")

	if caster:GetTeamNumber() == target:GetTeamNumber() then
		if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
	else
		if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
		duration = duration * (1 - target:GetStatusResistance())
	end
	
	return duration
end

function _boss__ai:GetIntrinsicModifierName()
	return "_boss_modifier__ai"
end