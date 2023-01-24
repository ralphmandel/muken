icebreaker_5__shivas = class({})
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function icebreaker_5__shivas:OnSpellStart()
	local caster = self:GetCaster()
	local blast_radius = self:GetSpecialValueFor("blast_radius")
	local blast_speed = self:GetSpecialValueFor("blast_speed")
	local blast_duration = blast_radius / blast_speed
	local current_loc = caster:GetAbsOrigin()
	
	self:PlayEfxActive(blast_radius, blast_duration, blast_speed)
	caster:AddNewModifier(caster, self, "_modifier_movespeed_buff", {
		duration =  blast_duration, percent = self:GetSpecialValueFor("movespeed")
	})

	local targets_hit = {}
	local current_radius = 0
	local tick_interval = 0.1

	Timers:CreateTimer(tick_interval, function()
		AddFOWViewer(caster:GetTeamNumber(), current_loc, current_radius, 0.1, false)
		current_radius = current_radius + blast_speed * tick_interval
		current_loc = caster:GetAbsOrigin()

		local nearby_enemies = FindUnitsInRadius(
			caster:GetTeamNumber(), current_loc, nil, current_radius, self:GetAbilityTargetTeam(),
			self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false
		)

		for _,enemy in pairs(nearby_enemies) do
			if enemy ~= caster then
				local enemy_has_been_hit = false
				for _,enemy_hit in pairs(targets_hit) do
					if enemy == enemy_hit then enemy_has_been_hit = true end
				end

				if not enemy_has_been_hit then
					targets_hit[#targets_hit + 1] = enemy

					if enemy:HasModifier("bloodstained_u_modifier_copy") == false
					and enemy:IsIllusion() then
						enemy:Kill(self, caster)
					else
						enemy:AddNewModifier(caster, self, "icebreaker__modifier_frozen", {
							duration = CalcStatus(self:GetSpecialValueFor("frozen_duration"), caster, enemy)
						})
					end
					
					self:PlayEfxHit(enemy)
				end
			end
		end

		if current_radius < blast_radius then
			return tick_interval
		end
	end)
end

-- EFFECTS

	function icebreaker_5__shivas:PlayEfxActive(blast_radius, blast_duration, blast_speed)
		local caster = self:GetCaster()
		local blast_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(blast_pfx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(blast_pfx, 1, Vector(blast_radius, blast_duration * 1.33, blast_speed))
		ParticleManager:ReleaseParticleIndex(blast_pfx)

		if IsServer() then caster:EmitSound("DOTA_Item.ShivasGuard.Activate") end
	end

	function icebreaker_5__shivas:PlayEfxHit(enemy)
		local caster = self:GetCaster()
		local hit_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
		ParticleManager:SetParticleControl(hit_pfx, 0, enemy:GetAbsOrigin())
		ParticleManager:SetParticleControl(hit_pfx, 1, enemy:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(hit_pfx)
	end