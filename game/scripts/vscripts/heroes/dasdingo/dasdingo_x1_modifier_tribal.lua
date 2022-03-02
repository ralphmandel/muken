dasdingo_x1_modifier_tribal = class({})

function dasdingo_x1_modifier_tribal:IsHidden()
	return false
end

function dasdingo_x1_modifier_tribal:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function dasdingo_x1_modifier_tribal:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local levels = 0
	local int = self.caster:FindModifierByName("_1_INT_modifier")
	if int then self.parent:CreatureLevelUp(int:GetStackCount()) end

	self.parent:StartGesture(ACT_IDLE)
	self:PlayEfxRegen()
end

function dasdingo_x1_modifier_tribal:OnRefresh( kv )
end

function dasdingo_x1_modifier_tribal:OnRemoved()
	if IsValidEntity(self.parent) then
		if self.parent:IsAlive() then
			self.parent:Kill(self.ability, nil)
		end
	end
end

--------------------------------------------------------------------------------

function dasdingo_x1_modifier_tribal:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}

	return state
end

function dasdingo_x1_modifier_tribal:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_EVENT_ON_HEAL_RECEIVED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}
	return funcs
end

function dasdingo_x1_modifier_tribal:GetModifierAttackSpeedPercentage()
	return 75
end

function dasdingo_x1_modifier_tribal:OnAttack(keys)
	if keys.attacker == self.parent then
		if IsServer() then self.parent:EmitSound("Hero_WitchDoctor_Ward.Attack") end
	end
end

function dasdingo_x1_modifier_tribal:OnAttackLanded(keys)
	if keys.attacker == self.parent then
		if IsServer() then self.parent:EmitSound("Hero_WitchDoctor_Ward.ProjectileImpact") end
	end
end

function dasdingo_x1_modifier_tribal:GetModifierHealAmplify_PercentageTarget(keys)
	return -50
end

function dasdingo_x1_modifier_tribal:OnHealReceived(keys)
    if keys.gain <= 0 then return end

    if keys.inflictor ~= nil and keys.unit == self:GetParent() then
        self:Popup(keys.unit, math.floor(keys.gain))
    end
end


function dasdingo_x1_modifier_tribal:GetAttackSound(keys)
    return ""
end

--------------------------------------------------------------------------------

function dasdingo_x1_modifier_tribal:GetEffectName()
	return "particles/econ/items/witch_doctor/wd_2021_cache/wd_2021_cache_death_ward.vpcf"
end

function dasdingo_x1_modifier_tribal:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function dasdingo_x1_modifier_tribal:PlayEfxRegen()
	local string = "particles/econ/items/juggernaut/jugg_fortunes_tout/jugg_healling_ward_fortunes_tout_hero_heal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 2, self.parent:GetOrigin())
	self:AddParticle(effect_cast, false, false, -1, false, false)
end

function dasdingo_x1_modifier_tribal:Popup(target, amount)
    self:PopupNumbers(target, "heal", Vector(0, 255, 0), 2.0, amount, 10, 0)
end

function dasdingo_x1_modifier_tribal:PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
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