item_tp = class({})
LinkLuaModifier("rank_points", "items/rank_points", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("gold_next_level", "items/gold_next_level", LUA_MODIFIER_MOTION_NONE)

function item_tp:Spawn()
	self.cooldown = 60
end

function item_tp:GetIntrinsicModifierName()
	return "rank_points"
end

-----------------------------------------------------------

function item_tp:OnSpellStart()
	local caster = self:GetCaster()
	local start_pfx_name = "particles/items2_fx/teleport_start.vpcf"
	local end_pfx_name = "particles/items2_fx/teleport_end.vpcf"
	self.location = self:RandomizePlayerSpawn(caster)

	self.gesture = ACT_DOTA_TELEPORT
	if caster:GetUnitName() == "npc_dota_hero_furion" then
		self.gesture = ACT_DOTA_GENERIC_CHANNEL_1
	end

	caster:StartGesture(self.gesture)
	self:EndCooldown()
	self:SetActivated(false)
	EmitSoundOn("Portal.Loop_Disappear", caster)

	self.start_pfx = ParticleManager:CreateParticle(start_pfx_name, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(self.start_pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.start_pfx, 2, Vector(255,255,0))
	ParticleManager:SetParticleControl(self.start_pfx, 3, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.start_pfx, 4, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.start_pfx, 5, Vector(3,0,0))
	ParticleManager:SetParticleControl(self.start_pfx, 6, caster:GetAbsOrigin())
end

function item_tp:RandomizePlayerSpawn(unit)
	local spawn_pos = {
		[1] = Vector(455, -1394, 0),
		[2] = Vector(-1040, -3661, 0),
		[3] = Vector(-2724, -2628, 0),
		[4] = Vector(-2563, -923, 0),
		[5] = Vector(-3144, 1596, 0),
		[6] = Vector(-828, 1413, 0),
		[7] = Vector(-2047, 4349, 0),
		[8] = Vector(1858, 5903, 0),
		[9] = Vector(935, 2619, 0),
		[10] = Vector(3291, 2578, 0),
		[11] = Vector(1084, 875, 0),
		[12] = Vector(3587, -670, 0),
		[13] = Vector(3848, -1969, 0),
		[14] = Vector(3920, -3897, 0),
		[15] = Vector(2175, -3259, 0)
	}

	return spawn_pos[RandomInt(1, 15)]
	-- unit:SetOrigin(further_loc)
	-- FindClearSpaceForUnit(unit, further_loc, true)
end

function item_tp:OnChannelThink( fInterval )
end

function item_tp:OnChannelFinish( bInterrupted )
	local caster = self:GetCaster()
	self:SetActivated(true)
	caster:FadeGesture(self.gesture)

	if bInterrupted then -- unsuccessful
		self:StartCooldown(5)
	else -- successful
		caster:StartGesture(ACT_DOTA_TELEPORT_END)
		self:StartCooldown(self:GetEffectiveCooldown(self:GetLevel()))

		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Portal.Hero_Disappear", caster)
		FindClearSpaceForUnit(caster, self.location, true)
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Portal.Hero_Appear", caster)

		local playerID = caster:GetPlayerOwnerID()
		if playerID ~= nil then
			CenterCameraOnUnit(playerID, caster)
		end
	end

	StopSoundOn("Portal.Loop_Disappear", caster)
	if self.start_pfx ~= nil then
		ParticleManager:DestroyParticle(self.start_pfx, false)
		self.start_pfx = nil
	end
end

function item_tp:GetCooldown(iLevel)
	return self.cooldown
end

function item_tp:GetChannelTime()
	local rec = self:GetCaster():FindAbilityByName("_2_REC")
	local channel = self:GetCaster():FindAbilityByName("_channel")
	local channel_time = self:GetSpecialValueFor("channel_time")
	return channel_time * (1 - (channel:GetLevel() * rec:GetSpecialValueFor("channel") * 0.01))
end

-- function item_tp:RepickItem(hItem)
-- 	local caster = self:GetCaster()
-- 	caster:DropItemAtPosition(caster:GetOrigin(), hItem)
		
-- 	Timers:CreateTimer((2), function()
-- 		caster:PickupDroppedItem(hItem)
-- 	end)
-- end