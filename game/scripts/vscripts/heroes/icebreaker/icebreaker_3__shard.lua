icebreaker_3__shard = class({})
LinkLuaModifier("icebreaker_3_modifier_shard", "heroes/icebreaker/icebreaker_3_modifier_shard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_3_modifier_aura_effect", "heroes/icebreaker/icebreaker_3_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function icebreaker_3__shard:OnSpellStart()
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local shard = CreateUnitByName("icebreaker_shard", point, true, caster, caster, caster:GetTeamNumber())

		shard:CreatureLevelUp(self:GetSpecialValueFor("rank"))
		shard:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
		AddBonus(self, "_1_CON", shard, BaseStats(caster):GetStatTotal("MND"), 0, nil)
		
		shard:AddNewModifier(caster, self, "icebreaker_3_modifier_shard", {duration = self:GetSpecialValueFor("duration")})
	end

-- EFFECTS