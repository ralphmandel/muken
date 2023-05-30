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

	RemoveBonus(self.ability, "_1_STR", self.parent)
	RemoveBonus(self.ability, "_2_MND", self.parent)
	RemoveBonus(self.ability, "_1_CON", self.parent)
	RemoveBonus(self.ability, "_1_AGI", self.parent)
	RemoveBonus(self.ability, "_2_LCK", self.parent)
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
	if keys.unit ~= self.parent then return end
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
  local damage_return = self.ability:GetSpecialValueFor("special_damage_return")
  if damage_return <= 0 then return end

	if keys.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
		local damageTable = {
			damage = keys.damage * damage_return * 0.01,
			damage_type = keys.damage_type,
			attacker = self.caster,
			victim = keys.attacker,
			ability = self.ability,
			damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
		}

		if IsServer() then keys.attacker:EmitSound("DOTA_Item.BladeMail.Damage") end
		ApplyDamage(damageTable)
	end
end


function druid_4_modifier_form:OnAttackLanded(keys)
  if keys.attacker ~= self.parent then return end

  if self.stun_duration > 0 then
    keys.target:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
      duration = CalcStatus(self.stun_duration, self.caster, keys.target)
    })
  end

  if self.break_duration > 0 then
    self.luck_stack = self.luck_stack + 1
    RemoveBonus(self.ability, "_2_LCK", self.parent)
    AddBonus(self.ability, "_2_LCK", self.parent, self.ability:GetSpecialValueFor("lck") + self.luck_stack, 0, nil)

    if BaseStats(self.parent).has_crit then
      keys.target:AddNewModifier(self.caster, self.ability, "_modifier_break", {
        duration = CalcStatus(self.break_duration, self.caster, keys.target)
      })
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
		enemy:AddNewModifier(self.caster, self.ability, "_modifier_fear", {
			duration = CalcStatus(fear_duration, self.caster, enemy)
		})
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