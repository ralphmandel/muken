item_rare_lacerator = class({})
LinkLuaModifier("item_rare_lacerator_mod_passive", "items/item_rare_lacerator_mod_passive", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------

function item_rare_lacerator:GetIntrinsicModifierName()
	return "item_rare_lacerator_mod_passive"
end

function item_rare_lacerator:Spawn()
	self.stacks = 0
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