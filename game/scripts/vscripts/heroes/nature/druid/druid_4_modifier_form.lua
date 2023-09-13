druid_4_modifier_form = class({})

function druid_4_modifier_form:IsHidden() return false end
function druid_4_modifier_form:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_4_modifier_form:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  local fear_duration = self.ability:GetSpecialValueFor("special_fear_duration")
  self.stun_duration = self.ability:GetSpecialValueFor("special_stun_duration")
  self.break_duration = self.ability:GetSpecialValueFor("special_break_duration")
  self.luck_stack = 0

  AddModifier(self.parent, self.ability, "_modifier_percent_movespeed_buff", {
    percent = self.ability:GetSpecialValueFor("ms_percent")
  }, false)
  
	self:HideItens(true)

	local group = {[1] = "0", [2] = "1", [3] = "2"}
	self.parent:SetMaterialGroup(group[kv.form])
	self.parent:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	self.parent:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
  self.ability:SetActivated(false)
  self.ability:EndCooldown()
  self.ability:SetCurrentAbilityCharges(1)

  Timers:CreateTimer(0.1, function()
    local heal = self.parent:GetHealthDeficit() * self.ability:GetSpecialValueFor("special_heal") * 0.01
    if heal > 0 then self.parent:Heal(heal, self.ability) end
  end)

	if IsServer() then
    self:ApplyFear(fear_duration)
    self:PlayEfxStart(fear_duration > 0)
  end
end

function druid_4_modifier_form:OnRefresh(kv)
end

function druid_4_modifier_form:OnRemoved()
	if IsServer() then self:PlayEfxEnd() end

	RemoveBonus(self.ability, "STR", self.parent)
	RemoveBonus(self.ability, "MND", self.parent)
	RemoveBonus(self.ability, "CON", self.parent)
	RemoveBonus(self.ability, "AGI", self.parent)
	RemoveBonus(self.ability, "LCK", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_buff", self.ability)

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
    MODIFIER_EVENT_ON_TAKEDAMAGE,
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

function druid_4_modifier_form:OnTakeDamage(keys)
end


function druid_4_modifier_form:OnAttackLanded(keys)
  if keys.attacker ~= self.parent then return end

  AddModifier(keys.target, self.ability, "_modifier_stun", {duration = self.stun_duration}, true)

  if self.break_duration > 0 then
    self.luck_stack = self.luck_stack + 1
    RemoveBonus(self.ability, "LCK", self.parent)
    AddBonus(self.ability, "LCK", self.parent, self.ability:GetSpecialValueFor("lck") + self.luck_stack, 0, nil)

    if BaseStats(self.parent).has_crit then
      AddModifier(keys.target, self.ability, "_modifier_break", {duration = self.break_duration}, true)
    end
  end
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
		BaseHeroMod(self.parent):ChangeSounds("Hero_LoneDruid.TrueForm.PreAttack", "", "Hero_LoneDruid.TrueForm.Attack")
	else
		BaseHeroMod(self.parent):LoadSounds()
	end
end

function druid_4_modifier_form:ApplyFear(fear_duration)
  if fear_duration <= 0 then return end
	
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 350,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,enemy in pairs(enemies) do
    AddModifier(enemy, self.ability, "_modifier_fear", {duration = fear_duration}, true)
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

  if bFear then
    local string_3 = "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf"
    local particle_2 = ParticleManager:CreateParticle(string_3, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(particle_2, 0, self.parent:GetOrigin())
    ParticleManager:ReleaseParticleIndex(particle_2)

    if IsServer() then self.parent:EmitSound("Hero_LoneDruid.SavageRoar.Cast") end
  end

	if IsServer() then self.parent:EmitSound("Hero_Lycan.Shapeshift.Cast") end
end

function druid_4_modifier_form:PlayEfxEnd()
	local string = "particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then self.parent:EmitSound("General.Illusion.Destroy") end
end