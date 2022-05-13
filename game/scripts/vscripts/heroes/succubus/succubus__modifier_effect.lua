succubus__modifier_effect = class ({})

function succubus__modifier_effect:IsHidden()
    return true
end

function succubus__modifier_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function succubus__modifier_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.activity = "dagger_twirl"
	self.model = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana.vmdl"
	self.parent:SetOriginalModel(self.model)
	self:PlayEfxAmbient()
end

function succubus__modifier_effect:OnRefresh(kv)
end

function succubus__modifier_effect:OnRemoved(kv)
end

------------------------------------------------------------

function succubus__modifier_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function succubus__modifier_effect:GetModifierModelChange()
	return self.model 
end

function succubus__modifier_effect:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound("Hero_QueenOfPain.ProjectileImpact") end
end

function succubus__modifier_effect:GetAttackSound(keys)
    return ""
end

function succubus__modifier_effect:GetActivityTranslationModifiers(keys)
    return self.activity
end

function succubus__modifier_effect:ChangeActivity(string)
    self.activity = string
end

function succubus__modifier_effect:PlayEfxAmbient()
	local string = "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_feet_ambient.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)
	local string2 = "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_whip_ambient.vpcf"
	local effect_cast2 = ParticleManager:CreateParticle(string2, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast2, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControlEnt(effect_cast2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), true)
	self:AddParticle(effect_cast2, false, false, -1, false, false)
end