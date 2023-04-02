item_tp = class({})
require("settings")

function item_tp:Spawn()
	self.cooldown = 60
	--self:SetCurrentAbilityCharges(1)
end

-- if not self.gesture then self.gesture = 1500 end --1591
-- caster:FadeGesture(self.gesture - 1)
-- caster:StartGesture(self.gesture)
-- GameRules:SendCustomMessage("gesture" .. self.gesture, -1, 0)
-- self.gesture = self.gesture + 1

-----------------------------------------------------------

function item_tp:OnSpellStart()
	local caster = self:GetCaster()
	self.location = self:GetCursorPosition()
	local start_pfx_name = "particles/items2_fx/teleport_start.vpcf"
	local end_pfx_name = "particles/items2_fx/teleport_end.vpcf"
	
	if self.location == nil then
		self.location = self:RandomizePlayerSpawn(caster)
	else
		if self.location.x > 3200 or self.location.x < -3200
		or self.location.y > 3200 or self.location.y < -3200 then
			self.location = self:RandomizePlayerSpawn(caster)
		end
		if self.location == Vector(0, 0, 0) then
			self.location = self:RandomizePlayerSpawn(caster)
		end
	end

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
	for i = 1, #TEAMS, 1 do
		if TEAMS[i][1] == unit:GetTeamNumber() then
			return TEAMS[i]["spawn"]
		end
	end
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
		
		local flea_speed = caster:FindAbilityByName("flea_2__speed")
		if flea_speed then
			if flea_speed:IsTrained() then
				flea_speed.origin = self.location	
			end
		end

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

function item_tp:SetCooldown(cd)
	self.cooldown = cd
end

function item_tp:GetChannelTime()
	local channel = self:GetCaster():FindAbilityByName("_channel")
	local channel_time = self:GetSpecialValueFor("channel_time")
	return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
end

function item_tp:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET
	--if self:GetCurrentAbilityCharges() == 2 then return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED end
	return behavior + DOTA_ABILITY_BEHAVIOR_CHANNELLED
end