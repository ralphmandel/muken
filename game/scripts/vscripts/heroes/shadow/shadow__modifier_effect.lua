shadow__modifier_effect = class ({})

function shadow__modifier_effect:IsHidden()
    return true
end

function shadow__modifier_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function shadow__modifier_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.model = "models/heroes/phantom_assassin/phantom_assassin.vmdl"
	self.parent:SetOriginalModel(self.model)

	Timers:CreateTimer((0.5), function()
		if self.parent then
			if IsValidEntity(self.parent) then
				self.parent:SetModelScale(1)	
			end
		end
	end)
end

function shadow__modifier_effect:OnRefresh(kv)
end

function shadow__modifier_effect:OnRemoved(kv)
end

------------------------------------------------------------

function shadow__modifier_effect:DeclareFunctions()
	local funcs = {
		--MODIFIER_EVENT_ON_ATTACK,		-- Enable for Ranged Heroes
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

-- function shadow__modifier_effect:OnAttack(keys)	-- Enable for Ranged Heroes
-- 	if keys.attacker ~= self.parent then return end
-- 	if IsServer() then self.parent:EmitSound("") end
-- end

function shadow__modifier_effect:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound("Hero_Spectre.Attack") end --Hero_Spectre.Attack.Arcana
end

function shadow__modifier_effect:GetAttackSound(keys)
    return ""
end

function shadow__modifier_effect:GetModifierModelChange()
	return self.model 
end

-----------------------------------------------------------

function shadow__modifier_effect:PlayEfxAmbient(ambient, attach) 
	local effect_cast = ParticleManager:CreateParticle(ambient, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, attach, Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)
end