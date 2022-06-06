shadow_u_modifier_passive = class({})

function shadow_u_modifier_passive:IsHidden()
	return true
end

function shadow_u_modifier_passive:IsPurgable()
	return false
end

-----------------------------------------------------------

function shadow_u_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if self.parent:IsIllusion() then return end
	if IsServer() then self:OnIntervalThink(FrameTime()) end
end

function shadow_u_modifier_passive:OnRefresh(kv)
end

function shadow_u_modifier_passive:OnRemoved()
end

-----------------------------------------------------------

function shadow_u_modifier_passive:OnIntervalThink()
	if self.parent:IsIllusion() then return end
	if self.ability:IsCooldownReady() == false then return end

	-- UP 4.41
	if self.ability:GetRank(41) == false then
		self:StartIntervalThink(FrameTime())
		return
	end

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, -1,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		0, false
	)

	for _,enemy in pairs(enemies) do
		if enemy:HasModifier("shadow_0_modifier_toxin") then
			AddFOWViewer(self.caster:GetTeamNumber(), enemy:GetOrigin(), 75, 0.2, true)
		end
	end

	self:StartIntervalThink(FrameTime())
end