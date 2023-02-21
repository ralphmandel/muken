bocuse_4__mirepoix = class({})
LinkLuaModifier("bocuse_4_modifier_mirepoix", "heroes/bocuse/bocuse_4_modifier_mirepoix", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_4_modifier_end", "heroes/bocuse/bocuse_4_modifier_end", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function bocuse_4__mirepoix:OnAbilityPhaseStart()
		local caster = self:GetCaster()
		caster:FindModifierByName("base_hero_mod"):ChangeActivity("ftp_dendi_back")

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
		caster:FindModifierByName("base_hero_mod"):ChangeActivity("trapper")

		if IsServer() then
			caster:StopSound("DOTA_Item.Cheese.Activate")
			caster:StopSound("DOTA_Item.RepairKit.Target")
		end
	end

	function bocuse_4__mirepoix:GetCastPoint()
		return self:GetSpecialValueFor("cast_point")
	end

-- EFFECTS