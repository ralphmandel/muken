bocuse_4__mirepoix = class({})
LinkLuaModifier("bocuse_4_modifier_mirepoix", "heroes/team_death/bocuse/bocuse_4_modifier_mirepoix", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_4_modifier_end", "heroes/team_death/bocuse/bocuse_4_modifier_end", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bkb", "modifiers/_modifier_bkb", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function bocuse_4__mirepoix:OnAbilityPhaseStart()
		local caster = self:GetCaster()
		if BaseHeroMod(caster) then BaseHeroMod(caster):ChangeActivity("ftp_dendi_back") end

		if IsServer() then
			caster:EmitSound("DOTA_Item.Cheese.Activate")
			caster:EmitSound("DOTA_Item.RepairKit.Target")
		end

		return true
	end

	function bocuse_4__mirepoix:OnAbilityPhaseInterrupted()
		self:StopFeed()
	end

	function bocuse_4__mirepoix:OnSpellStart()
		local caster = self:GetCaster()
		self:StopFeed()

		caster:RemoveModifierByName("bocuse_4_modifier_end")
		caster:AddNewModifier(caster, self, "bocuse_4_modifier_mirepoix", {
			duration = CalcStatus(self:GetSpecialValueFor("duration"), caster, caster)
		})
	end

	function bocuse_4__mirepoix:StopFeed()
		local caster = self:GetCaster()
		if BaseHeroMod(caster) then BaseHeroMod(caster):ChangeActivity("trapper") end

		if IsServer() then
			caster:StopSound("DOTA_Item.Cheese.Activate")
			caster:StopSound("DOTA_Item.RepairKit.Target")
		end
	end

	function bocuse_4__mirepoix:GetCastPoint()
		return self:GetSpecialValueFor("cast_point")
	end

-- EFFECTS