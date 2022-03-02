bocuse_1_modifier_bleed = class({})

--------------------------------------------------------------------------------
function bocuse_1_modifier_bleed:IsPurgable()
	return true
end

function bocuse_1_modifier_bleed:IsHidden()
	return false
end

function bocuse_1_modifier_bleed:IsDebuff()
	return true
end

function bocuse_1_modifier_bleed:GetTexture()
	return "bleeding"
end

--------------------------------------------------------------------------------

function bocuse_1_modifier_bleed:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.degen = self.ability:GetSpecialValueFor("degen")
	local slow = self.ability:GetSpecialValueFor("slow")
	local intervals = self.ability:GetSpecialValueFor("intervals")
	local bleed_dps = self.ability:GetSpecialValueFor("bleed_dps")
	bleed_dps = bleed_dps * intervals

	self:PlayEfxStart()

    -- UP 1.4
    if self.ability:GetRank(4) then
        self.degen = self.degen + 25
    end

	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = bleed_dps,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_HPLOSS,
		ability = self.ability
	}

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = slow})
	self:StartIntervalThink(intervals)
end

function bocuse_1_modifier_bleed:OnRefresh(kv)
end

function bocuse_1_modifier_bleed:OnRemoved()
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

--------------------------------------------------------------------------------

function bocuse_1_modifier_bleed:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
    }
    return funcs
end

function bocuse_1_modifier_bleed:GetModifierHealAmplify_PercentageTarget()
    return -self.degen
end

function bocuse_1_modifier_bleed:GetModifierHPRegenAmplify_Percentage(keys)
    return -self.degen
end

function bocuse_1_modifier_bleed:OnIntervalThink()
	local apply_damage = math.floor(ApplyDamage(self.damageTable))
	if apply_damage > 0 then self:PopupBleed(apply_damage) end
end

--------------------------------------------------------------------------------

function bocuse_1_modifier_bleed:GetEffectName()
	return "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_thirst_owner.vpcf"
end

function bocuse_1_modifier_bleed:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function bocuse_1_modifier_bleed:PopupBleed(amount)
    local pfxPath = "particles/bocuse/bocuse_msg.vpcf"
	local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_OVERHEAD_FOLLOW, self.parent)
    
    local digits = 1
    if amount ~= nil then
        digits = digits + #tostring(amount)
    end

    ParticleManager:SetParticleControl(pidx, 3, Vector(0, tonumber(amount), 3))
    ParticleManager:SetParticleControl(pidx, 4, Vector(1, digits, 0))
    --ParticleManager:SetParticleControl(pidx, 3, Vector(100, 25, 40))
end

function bocuse_1_modifier_bleed:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Hero_LifeStealer.OpenWounds") end
end