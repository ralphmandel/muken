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
	self.parent:Purge(false, true, false, bRemoveStuns, false)

	if IsServer() then
		self:StartIntervalThink(self.intervals)
		self:PlayEfxPurge()
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------
--print("IsDebuff", keys.added_buff:GetName(), keys.added_buff:IsDebuff())

function bald_4_modifier_clean:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_false_promise.vpcf"
end

function bald_4_modifier_clean:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function bald_4_modifier_clean:PlayEfxPurge()
	local string = "particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then self.parent:EmitSound("DOTA_Item.HotD.Activate") end
	--if IsServer() then self.parent:EmitSound("DOTA_Item.ArcaneRing.Cast") end
end