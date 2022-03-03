shadow_3_modifier_stun = class({})

function shadow_3_modifier_stun:IsPurgable()
	return true
end

function shadow_3_modifier_stun:IsHidden()
	return false
end

-------------------------------------------------------------------

function shadow_3_modifier_stun:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.distance = kv.distance
end

function shadow_3_modifier_stun:OnRefresh(kv)
	self.distance = kv.distance
end

function shadow_3_modifier_stun:OnRemoved()
end

-------------------------------------------------------------------

function shadow_3_modifier_stun:DeclareFunctions()
    local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
    }
 
    return funcs
end

function shadow_3_modifier_stun:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end

	if keys.target:HasModifier("strider_1_modifier_spirit") == false
	and keys.target:IsIllusion() then
		keys.target:Kill(self.ability, self.caster)
		self:Destroy()
		return
	end

	keys.target:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
		duration = self.ability:CalcStatus(self.distance / 550, self.caster, keys.target)
	})

	self:Destroy()
end