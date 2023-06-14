fleaman_1_modifier_gesture = class({})

function fleaman_1_modifier_gesture:IsHidden() return true end
function fleaman_1_modifier_gesture:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_1_modifier_gesture:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:OnIntervalThink() end
end

function fleaman_1_modifier_gesture:OnRefresh(kv)
end

function fleaman_1_modifier_gesture:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function fleaman_1_modifier_gesture:OnIntervalThink()
	if self.parent:IsMoving() or self.parent:IsAttacking() then
		self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
	end

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------