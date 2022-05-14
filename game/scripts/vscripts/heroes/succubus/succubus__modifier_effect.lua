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

	Timers:CreateTimer((0.2), function()
		self:PlayEfxAmbient("particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_feet_ambient.vpcf", "")
		self:PlayEfxAmbient("particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_whip_ambient.vpcf", "attach_whip_end")
	end)
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

function succubus__modifier_effect:PlayEfxAmbient(ambient, attach) 
	local effect_cast = ParticleManager:CreateParticle(ambient, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, attach, Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)
end