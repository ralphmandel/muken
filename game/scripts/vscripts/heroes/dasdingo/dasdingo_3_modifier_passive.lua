dasdingo_3_modifier_passive = class({})

function dasdingo_3_modifier_passive:IsHidden()
	return true
end

function dasdingo_3_modifier_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function dasdingo_3_modifier_passive:OnRefresh(kv)
end

function dasdingo_3_modifier_passive:OnRemoved()
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function dasdingo_3_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:PassivesDisabled() then return end

	local duration = self.ability:GetSpecialValueFor("duration")

	-- UP 3.42
	if self.ability:GetRank(42) then
		if RandomInt(1, 100) <= 10
		and keys.target:IsAlive() then
			keys.target:AddNewModifier(self.caster, self.ability, "dasdingo_3_modifier_hex", {
				duration = self.ability:CalcStatus(duration, self.caster, keys.target)
			})
	
			self:PlayEfxStart(keys.target)
		end
	end
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_passive:PlayEfxStart(target)
	local particle_cast = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound("Hero_Lion.Voodoo") end
end