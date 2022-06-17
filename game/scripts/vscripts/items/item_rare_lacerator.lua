item_rare_lacerator = class({})
LinkLuaModifier("item_rare_lacerator_mod_passive", "items/item_rare_lacerator_mod_passive", LUA_MODIFIER_MOTION_NONE)

function item_rare_lacerator:CalcStatus(duration, caster, target)
    local time = duration
	local base_stats_caster = nil
	local base_stats_target = nil

    if caster ~= nil then
		base_stats_caster = caster:FindAbilityByName("base_stats")
	end

	if target ~= nil then
		base_stats_target = target:FindAbilityByName("base_stats")
	end

	if caster == nil then
		if target ~= nil then
			if base_stats_target then
				local value = base_stats_target.stat_total["RES"] * 0.7
				local calc = (value * 6) / (1 +  (value * 0.06))
				time = time * (1 - (calc * 0.01))
			end
		end
	else
		if target == nil then
			if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
		else
			if caster:GetTeamNumber() == target:GetTeamNumber() then
				if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
			else
				if base_stats_caster and base_stats_target then
					local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
					if value > 0 then
						local calc = (value * 6) / (1 +  (value * 0.06))
						time = time * (1 + (calc * 0.01))
					else
						value = -1 * value
						local calc = (value * 6) / (1 +  (value * 0.06))
						time = time * (1 - (calc * 0.01))
					end
				end
			end
		end
	end

    if time < 0 then time = 0 end
    return time
end

function item_rare_lacerator:AddBonus(string, target, const, percent, time)
	local base_stats = target:FindAbilityByName("base_stats")
	if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
end

function item_rare_lacerator:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

-----------------------------------------------------------

function item_rare_lacerator:GetIntrinsicModifierName()
	return "item_rare_lacerator_mod_passive"
end

function item_rare_lacerator:OnAbilityPhaseStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()

		self.phase_double_edge_pfx = ParticleManager:CreateParticle("particles/econ/items/centaur/centaur_ti9/centaur_double_edge_phase_ti9.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(self.phase_double_edge_pfx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControlForward(self.phase_double_edge_pfx, 0, (target:GetOrigin() - caster:GetOrigin()):Normalized())
		ParticleManager:SetParticleControl(self.phase_double_edge_pfx, 3, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.phase_double_edge_pfx, 4, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.phase_double_edge_pfx, 9, caster:GetAbsOrigin())
	end

	return true
end

function item_rare_lacerator:OnAbilityPhaseInterrupted()
	if self.phase_double_edge_pfx then
		ParticleManager:DestroyParticle(self.phase_double_edge_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.phase_double_edge_pfx)
	end
end

function item_rare_lacerator:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb(self) then return end

	local particle_edge_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_edge_fx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_edge_fx, 1, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_edge_fx, 2, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_edge_fx, 3, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_edge_fx, 4, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_edge_fx, 5, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_edge_fx, 9, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_edge_fx)

	if IsServer() then target:EmitSound("Hero_PhantomAssassin.CoupDeGrace") end
end