druid_4_modifier_form = class({})

function druid_4_modifier_form:IsHidden() return false end
function druid_4_modifier_form:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_4_modifier_form:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.stun_delay = false
  self.luck_stack = 0

  self.parent:AddNewModifier(self.caster, self.ability, "_modifier_percent_movespeed_buff", {
    percent = self.ability:GetSpecialValueFor("ms_percent")
  })
  
	self:HideItens(true)

	local group = {[1] = "0", [2] = "1", [3] = "2"}
	self.parent:SetMaterialGroup(group[kv.form])
	self.parent:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	self.parent:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
  self.ability:SetActivated(false)
  self.ability:EndCooldown()
  self.ability:SetCurrentAbilityCharges(1)

	if IsServer() then self:PlayEfxStart() end
end

function druid_4_modifier_form:OnRefresh(kv)
end

function druid_4_modifier_form:OnRemoved()
	if IsServer() then self:PlayEfxEnd() end

	RemoveBonus(self.ability, "_1_STR", self.parent)
	RemoveBonus(self.ability, "_2_MND", self.parent)
	RemoveBonus(self.ability, "_1_CON", self.parent)
	RemoveBonus(self.ability, "_1_AGI", self.parent)
	RemoveBonus(self.ability, "_2_LCK", self.parent)

  local mod = self.parent:FindAllModifiersByName("_modifier_percent_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

  self:HideItens(false)
	self.parent:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
  self.ability:SetActivated(true)
  self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
  self.ability:SetCurrentAbilityCharges(0)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_4_modifier_form:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_PRE_ATTACK,
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function druid_4_modifier_form:GetModifierPreAttack(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound("Hero_OgreMagi.PreAttack") end
end

function druid_4_modifier_form:GetModifierAttackRangeOverride()
  return 130
end

function druid_4_modifier_form:GetModifierModelChange()
	return "models/items/lone_druid/true_form/dark_wood_true_form/dark_wood_true_form.vmdl"
end

function druid_4_modifier_form:OnAttackLanded(keys)
  if keys.attacker ~= self.parent then return end
  local stun_duration = self.ability:GetSpecialValueFor("special_stun_duration")
  local break_duration = self.ability:GetSpecialValueFor("special_break_duration")

  if stun_duration > 0 then
    if self.stun_delay == false then
      self.stun_delay = true
      if IsServer() then self:StartIntervalThink(self.ability:GetSpecialValueFor("special_stun_interval")) end
      keys.target:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
        duration = CalcStatus(stun_duration, self.caster, keys.target)
      })
    end
  end

  if break_duration > 0 then
    self.luck_stack = self.luck_stack + 1
    RemoveBonus(self.ability, "_2_LCK", self.parent)
    AddBonus(self.ability, "_2_LCK", self.parent, self.ability:GetSpecialValueFor("lck") + self.luck_stack, 0, nil)

    if BaseStats(self.parent).has_crit then
      keys.target:AddNewModifier(self.caster, self.ability, "_modifier_break", {
        duration = CalcStatus(break_duration, self.caster, keys.target)
      })
    end
  end
end

function druid_4_modifier_form:OnIntervalThink()
  self.stun_delay = false
  if IsServer() then self:StartIntervalThink(-1) end
end

-- UTILS -----------------------------------------------------------

function druid_4_modifier_form:HideItens(bool)
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics == nil then return end
  if BaseHeroMod(self.parent) == nil then return end

	for i = 1, #cosmetics.cosmetic, 1 do
		cosmetics:HideCosmetic(cosmetics.cosmetic[i]:GetModelName(), bool)
	end

	if bool then
		BaseHeroMod(self.parent):ChangeSounds("Hero_LoneDruid.TrueForm.PreAttack", nil, "Hero_LoneDruid.TrueForm.Attack")
	else
		BaseHeroMod(self.parent):LoadSounds()
	end
end

-- EFFECTS -----------------------------------------------------------

function druid_4_modifier_form:PlayEfxStart(bFear)
	local string = "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	local string_2 = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
	local shake = ParticleManager:CreateParticle(string_2, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(shake, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(shake, 1, Vector(500, 0, 0))

  local string_4 = "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf"
  local particle2 = ParticleManager:CreateParticle(string_4, PATTACH_ABSORIGIN_FOLLOW, self.parent)
  ParticleManager:SetParticleControl(particle2, 0, self.parent:GetOrigin())
  ParticleManager:ReleaseParticleIndex(particle2)

	if IsServer() then self.parent:EmitSound("Hero_Lycan.Shapeshift.Cast") end
end

function druid_4_modifier_form:PlayEfxEnd()
	local string = "particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then self.parent:EmitSound("General.Illusion.Destroy") end
end