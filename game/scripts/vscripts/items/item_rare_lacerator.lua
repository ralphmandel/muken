item_rare_lacerator = class({})
LinkLuaModifier("item_rare_lacerator_mod_passive", "items/item_rare_lacerator_mod_passive", LUA_MODIFIER_MOTION_NONE)

function item_rare_lacerator:CalcStatus(duration, caster, target)
	local time = duration
	local caster_int = nil
	local caster_mnd = nil
	local target_res = nil

	if caster ~= nil then
		caster_int = caster:FindModifierByName("_1_INT_modifier")
		caster_mnd = caster:FindModifierByName("_2_MND_modifier")
	end

	if target ~= nil then
		target_res = target:FindModifierByName("_2_RES_modifier")
	end

	if caster == nil then
		if target ~= nil then
			if target_res then time = time * (1 - target_res:GetStatus()) end
		end
	else
		if target == nil then
			if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
		else
			if caster:GetTeamNumber() == target:GetTeamNumber() then
				if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
			else
				if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
				if target_res then time = time * (1 - target_res:GetStatus()) end
			end
		end
	end

	if time < 0 then time = 0 end
	return time
end

function item_rare_lacerator:AddBonus(string, target, const, percent, time)
	local att = target:FindAbilityByName(string)
	if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
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