item_rare_arcane_hammer = class({})
LinkLuaModifier("item_rare_arcane_hammer_mod_passive", "items/item_rare_arcane_hammer_mod_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_rare_arcane_hammer_mod_silence", "items/item_rare_arcane_hammer_mod_silence", LUA_MODIFIER_MOTION_NONE)

function item_rare_arcane_hammer:CalcStatus(duration, caster, target)
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

function item_rare_arcane_hammer:AddBonus(string, target, const, percent, time)
	local base_stats = target:FindAbilityByName("base_stats")
	if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
end

function item_rare_arcane_hammer:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

-----------------------------------------------------------

function item_rare_arcane_hammer:GetIntrinsicModifierName()
	return "item_rare_arcane_hammer_mod_passive"
end

function item_rare_arcane_hammer:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")

	if IsServer() then target:EmitSound("Arcane_Hammer.Start") end

	target:AddNewModifier(caster, self, "item_rare_arcane_hammer_mod_silence", {
		duration = CalcStatus(duration, caster, target)
	})
end

function item_rare_arcane_hammer:CastFilterResultTarget(hTarget)
	local caster = self:GetCaster()

	local result = UnitFilter(
		hTarget,	-- Target Filter
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
		0,	-- Unit Flag
		caster:GetTeamNumber()	-- Team reference
	)
	
	if result ~= UF_SUCCESS then
		return result
	end

	return UF_SUCCESS
end