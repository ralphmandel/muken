druid_1_modifier_conversion = class ({})

function druid_1_modifier_conversion:IsHidden()
    return false
end

function druid_1_modifier_conversion:IsPurgable()
    return false
end

-----------------------------------------------------------

function druid_1_modifier_conversion:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.parent:SetTeam(self.caster:GetTeamNumber())
	self.parent:SetOwner(self.caster)
	self.parent:SetControllableByPlayer(self.caster:GetPlayerOwnerID(), true)

	self.bonus_damage = self.ability:GetSpecialValueFor("bonus_damage")
	local caster_int = self.caster:FindModifierByName("_1_INT_modifier")

	if caster_int then
		self.bonus_damage = math.floor(self.bonus_damage * (1 + caster_int:GetSpellAmp()))
	end
end

function druid_1_modifier_conversion:OnRefresh(kv)
end

function druid_1_modifier_conversion:OnRemoved(kv)
	if IsValidEntity(self.parent) then
		if self.parent:IsAlive() then
			self.parent:ForceKill(false)
		end
	end
end

------------------------------------------------------------

function druid_1_modifier_conversion:CheckState()
	local state = {
		[MODIFIER_STATE_DOMINATED] = true
	}

	return state
end

function druid_1_modifier_conversion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_HEAL_RECEIVED
	}

	return funcs
end

function druid_1_modifier_conversion:GetModifierPreAttack_BonusDamage(keys)
	return self.bonus_damage
end

function druid_1_modifier_conversion:OnHealReceived(keys)
    if keys.gain <= 0 then return end

    if keys.inflictor ~= nil and keys.unit == self.parent then
        self:Popup(keys.unit, math.floor(keys.gain))
    end
end

--------------------------------------------------------------------------------

function druid_1_modifier_conversion:Popup(target, amount)
    self:PopupNumbers(target, "heal", Vector(0, 255, 0), 2.0, amount, 10, 0)
end

function druid_1_modifier_conversion:PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
    local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target) -- target:GetOwner()
    
     
    local digits = 0
    if number ~= nil then
        digits = #tostring(number)
    end
    if presymbol ~= nil then
        digits = digits + 1
    end
    if postsymbol ~= nil then
        digits = digits + 1
    end

    if number < 10 then digits = 2 end
    if number > 9 and number < 100 then digits = 3 end
    if number > 99 then digits = 4 end

    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end