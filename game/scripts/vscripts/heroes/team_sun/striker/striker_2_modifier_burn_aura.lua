striker_2_modifier_burn_aura = class({})

function striker_2_modifier_burn_aura:IsHidden() return true end
function striker_2_modifier_burn_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function striker_2_modifier_burn_aura:IsAura()
	return true
end

function striker_2_modifier_burn_aura:GetModifierAura()
	return "striker_2_modifier_burn_aura_effect"
end

function striker_2_modifier_burn_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("special_burn_radius")
end

function striker_2_modifier_burn_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function striker_2_modifier_burn_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_2_modifier_burn_aura:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then
		self:StartIntervalThink(FrameTime())
		self:PlayEfxStart(self:GetAuraRadius())
	end
end

function striker_2_modifier_burn_aura:OnRefresh(kv)
end

function striker_2_modifier_burn_aura:OnRemoved()
	if IsServer() then self.parent:StopSound("Hero_Batrider.Firefly.loop") end
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_2_modifier_burn_aura:OnIntervalThink()
	GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), 175, true)
	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function striker_2_modifier_burn_aura:GetEffectName()
	return "particles/econ/items/ember_spirit/ember_ti9/ember_ti9_flameguard.vpcf"
end

function striker_2_modifier_burn_aura:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function striker_2_modifier_burn_aura:PlayEfxStart(radius)
    if IsServer() then
        self.parent:EmitSound("Hero_Inquisitor.Shield.Fire")
        self.parent:EmitSound("Hero_Batrider.Firefly.loop")
    end
end