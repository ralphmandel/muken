druid_u_modifier_conversion = class({})

function druid_u_modifier_conversion:IsHidden()
	return false
end

function druid_u_modifier_conversion:IsPurgable()
	return false
end

function druid_u_modifier_conversion:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_u_modifier_conversion:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.parent:SetTeam(self.caster:GetTeamNumber())
	self.parent:SetOwner(self.caster)
	self.parent:SetControllableByPlayer(self.caster:GetPlayerOwnerID(), true)

	self.ability:AddUnit(self.parent)
	self:PlayEfxStart()
end

function druid_u_modifier_conversion:OnRefresh(kv)
end

function druid_u_modifier_conversion:OnRemoved()
	if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end
	if IsServer() then self.parent:EmitSound("Creature.Kill") end
	
	self.ability:RemoveUnit(self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_u_modifier_conversion:CheckState()
	local state = {
		[MODIFIER_STATE_DOMINATED] = true
	}

	return state
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_u_modifier_conversion:PlayEfxStart()
	self.effect_cast = ParticleManager:CreateParticle("particles/druid/druid_skill1_convert.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Druid.Finish") end
end