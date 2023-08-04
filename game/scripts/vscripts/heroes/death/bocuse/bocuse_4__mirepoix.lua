bocuse_4__mirepoix = class({})
LinkLuaModifier("bocuse_4_modifier_mirepoix", "heroes/death/bocuse/bocuse_4_modifier_mirepoix", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_4_modifier_mirepoix_status_efx", "heroes/death/bocuse/bocuse_4_modifier_mirepoix_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_4_modifier_end", "heroes/death/bocuse/bocuse_4_modifier_end", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bkb", "_modifiers/_modifier_bkb", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function bocuse_4__mirepoix:GetCastPoint()
    local channel = self:GetCaster():FindAbilityByName("_channel")
    local channel_time = self:GetSpecialValueFor("cast_point")
    return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
  end

-- SPELL START

	function bocuse_4__mirepoix:OnAbilityPhaseStart()
		local caster = self:GetCaster()
    ChangeActivity(caster, "ftp_dendi_back")

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
    AddModifier(caster, self, "bocuse_4_modifier_mirepoix", {
      duration = self:GetSpecialValueFor("duration")
    }, true)
	end

	function bocuse_4__mirepoix:StopFeed()
		local caster = self:GetCaster()
		ChangeActivity(caster, "trapper")

		if IsServer() then
			caster:StopSound("DOTA_Item.Cheese.Activate")
			caster:StopSound("DOTA_Item.RepairKit.Target")
		end
	end

-- EFFECTS