bloodstained_4_modifier_blood = class({})

function bloodstained_4_modifier_blood:IsHidden() return true end
function bloodstained_4_modifier_blood:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_4_modifier_blood:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	local blood_percent = self.ability:GetSpecialValueFor("blood_percent") * 0.01
	self.damage = math.ceil(kv.damage * blood_percent)
end

function bloodstained_4_modifier_blood:OnRefresh(kv)
end

function bloodstained_4_modifier_blood:OnRemoved()
	if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, true) end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------