mana_burn_modifier = class({})

function mana_burn_modifier:IsHidden()
	return false
end

function mana_burn_modifier:IsPurgable()
    return false
end

function mana_burn_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.burned_mana = self.ability:GetManaCost(self.ability:GetLevel())
	self.slow = self.ability:GetSpecialValueFor("slow")
	self.record = {}
end

function mana_burn_modifier:OnRefresh( kv )
end

function mana_burn_modifier:OnRemoved()
end

--------------------------------------------------------------------------------------------------------------------------

function mana_burn_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
	}

	return funcs
end

function mana_burn_modifier:OnAttack(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:GetMana() < self.burned_mana then return end

	self.parent:SpendMana(self.burned_mana, self.ability)
	table.insert(self.record, keys.record)
end

function mana_burn_modifier:GetModifierProcAttack_Feedback(keys)
	if self.parent:PassivesDisabled() then return end
	if keys.target:IsMagicImmune() then return end

	for i = #self.record, 1, -1 do
		if self.record[i] == keys.record then
			table.remove(self.record, i)
			self:InflictBurn(keys.target)
			break
		end
	end
end

function mana_burn_modifier:InflictBurn(target)
  RemoveAllModifiersByNameAndAbility(target, "_modifier_percent_movespeed_debuff", self.ability)

	target:AddNewModifier(self.caster, self.ability, "_modifier_percent_movespeed_debuff", {
		percent = self.slow,
		duration = CalcStatus(1.5, self.caster, target)
	})
	
	local burned_mana = self.burned_mana
	if burned_mana > target:GetMana() then burned_mana = target:GetMana() end

	if burned_mana > 0 then
		target:Script_ReduceMana(burned_mana, self.ability)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, burned_mana, self.caster)

		local damageTable = {
			damage = burned_mana,
			damage_type = DAMAGE_TYPE_MAGICAL,
			attacker = self.caster,
			victim = target,
			ability = self.ability
		}

		ApplyDamage(damageTable)
	end
end