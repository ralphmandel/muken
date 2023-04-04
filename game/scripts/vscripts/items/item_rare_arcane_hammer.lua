item_rare_arcane_hammer = class({})
LinkLuaModifier("item_rare_arcane_hammer_mod_passive", "items/item_rare_arcane_hammer_mod_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_rare_arcane_hammer_mod_silence", "items/item_rare_arcane_hammer_mod_silence", LUA_MODIFIER_MOTION_NONE)

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