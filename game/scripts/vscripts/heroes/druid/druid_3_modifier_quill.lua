druid_3_modifier_quill = class({})

function druid_3_modifier_quill:IsHidden()
	return false
end

function druid_3_modifier_quill:IsPurgable()
	return true
end

function druid_3_modifier_quill:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_3_modifier_quill:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then
		self:SetStackCount(1)
	end
end

function druid_3_modifier_quill:OnRefresh(kv)
	if IsServer() then
		self:IncrementStackCount()
	end
end

function druid_3_modifier_quill:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_3_modifier_quill:OnStackCountChanged(old)
	self:ApplyQuillDamage(self:GetStackCount())

	if self:GetStackCount() >= 3 then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
			duration = CalcStatus(1, self.caster, self.parent)
		})

		self:Destroy()
	end
end

-- UTILS -----------------------------------------------------------

function druid_3_modifier_quill:ApplyQuillDamage(stack)
	ApplyDamage({
		attacker = self.caster, victim = self.parent, ability = self.ability,
		damage = 45 + (stack * 15), damage_type = DAMAGE_TYPE_PHYSICAL
	})
end
-- EFFECTS -----------------------------------------------------------

function druid_3_modifier_quill:GetEffectName()
	return "particles/units/heroes/hero_bristleback/bristleback_quill_spray_hit_creep.vpcf"
end

function druid_3_modifier_quill:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end