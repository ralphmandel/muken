bocuse_x1_modifier_debuff = class ({})

function bocuse_x1_modifier_debuff:IsHidden()
    return true
end

function bocuse_x1_modifier_debuff:IsPurgable()
    return false
end

function bocuse_x1_modifier_debuff:IsDebuff()
    return true
end

-----------------------------------------------------------

function bocuse_x1_modifier_debuff:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

    local slow = self.ability:GetSpecialValueFor("slow")
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = slow})
    self:PlayEfxStart()
end

function bocuse_x1_modifier_debuff:OnRefresh(kv)
end

function bocuse_x1_modifier_debuff:OnRemoved(kv)
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

------------------------------------------------------------

function bocuse_x1_modifier_debuff:PlayEfxStart()
    if IsServer() then self.parent:EmitSound("Hero_Bristleback.ViscousGoo.Target") end
end

function bocuse_x1_modifier_debuff:GetEffectName()
	return "particles/bocuse/bocuse_roux_debuff.vpcf"
end

function bocuse_x1_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end