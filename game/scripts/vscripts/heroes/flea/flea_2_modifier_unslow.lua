flea_2_modifier_unslow = class({})

function flea_2_modifier_unslow:IsHidden() return false end
function flea_2_modifier_unslow:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_2_modifier_unslow:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then self:PlayEfxStart() end
end

function flea_2_modifier_unslow:OnRefresh(kv)
	if IsServer() then self.parent:EmitSound("Hero_Dark_Seer.Surge") end
end

function flea_2_modifier_unslow:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_2_modifier_unslow:CheckState()
	local state = {
		[MODIFIER_STATE_UNSLOWABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}

	return state
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function flea_2_modifier_unslow:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_ancient_seal_debuff.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	--ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_OVERHEAD_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Dark_Seer.Surge") end
end