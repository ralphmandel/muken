bald_4_modifier_clean = class({})

function bald_4_modifier_clean:IsHidden() return false end
function bald_4_modifier_clean:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_4_modifier_clean:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.intervals = self.ability:GetSpecialValueFor("intervals")

	if IsServer() then
		self:StartIntervalThink(self.intervals)
		self.parent:EmitSound("DOTA_Item.ComboBreaker")
	end
end

function bald_4_modifier_clean:OnRefresh(kv)
	self.intervals = self.ability:GetSpecialValueFor("intervals")

	if IsServer() then
		self.parent:EmitSound("DOTA_Item.ComboBreaker")
	end
end

function bald_4_modifier_clean:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------


function bald_4_modifier_clean:OnIntervalThink()
	local bRemoveStuns = false
	local radius = self.ability:GetSpecialValueFor("radius")
	if radius > 0 then bRemoveStuns = true end

	local allies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)

	for _,ally in pairs(allies) do
		ally:Purge(false, true, false, bRemoveStuns, false)
		self:PlayEfxPurge(ally)	
	end

	if IsServer() then
		self.parent:EmitSound("DOTA_Item.HotD.Activate")
		self:StartIntervalThink(self.intervals)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bald_4_modifier_clean:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_false_promise.vpcf"
end

function bald_4_modifier_clean:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function bald_4_modifier_clean:PlayEfxPurge(target)
	local string = "particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)
	--if IsServer() then target:EmitSound("DOTA_Item.ArcaneRing.Cast") end
end