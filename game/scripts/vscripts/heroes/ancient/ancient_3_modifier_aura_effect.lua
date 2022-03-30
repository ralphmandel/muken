ancient_3_modifier_aura_effect = class({})

function ancient_3_modifier_aura_effect:IsHidden()
	return false
end

function ancient_3_modifier_aura_effect:IsPurgable()
	return false
end

-----------------------------------------------------------

function ancient_3_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local slow = self.ability:GetSpecialValueFor("slow")

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = slow})
end

function ancient_3_modifier_aura_effect:OnRefresh(kv)
end

function ancient_3_modifier_aura_effect:OnRemoved(kv)
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-----------------------------------------------------------

function ancient_3_modifier_aura_effect:PlayEfxStart()
	-- local special = (self.ability:GetLevel() - 1) * 10
	-- local string = "particles/dasdingo/dasdingo_aura.vpcf"
	-- local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	-- ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	-- ParticleManager:SetParticleControl(effect_cast, 3, Vector(special, 0, 0 ))

	-- self:AddParticle(effect_cast, false, false, -1, false, false)

	-- if IsServer() then self.parent:EmitSound("Hero_Pangolier.TailThump.Cast") end
end