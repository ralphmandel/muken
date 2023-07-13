ancient_3_modifier_efx_hands = class({})

function ancient_3_modifier_efx_hands:IsHidden() return true end
function ancient_3_modifier_efx_hands:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_3_modifier_efx_hands:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.time = self:GetRemainingTime()

	if IsServer() then
		self:PlayEfxStart()
		self:StartIntervalThink(0.1)
	end
end

function ancient_3_modifier_efx_hands:OnRefresh(kv)
end

function ancient_3_modifier_efx_hands:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_3_modifier_efx_hands:OnIntervalThink()
	local elapsedTime = self:GetElapsedTime()
	local total = math.floor((elapsedTime / self.time) * 100)
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(total, 0, 0 ))
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function ancient_3_modifier_efx_hands:PlayEfxStart()
	local string = "particles/ancient/ancient_aura_hands.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(1, 0, 0 ))
	self:AddParticle(self.effect_cast, false, false, -1, false, false)
end