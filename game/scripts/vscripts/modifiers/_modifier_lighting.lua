_modifier_lighting = class({})

--------------------------------------------------------------------------------
function _modifier_lighting:IsPurgable()
	return true
end

function _modifier_lighting:IsStunDebuff()
	return true
end

function _modifier_lighting:IsHidden()
	return false
end

function _modifier_lighting:GetTexture()
	return "_modifier_lighting"
end

function _modifier_lighting:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_lighting:OnCreated( kv )
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
    self.ability = self:GetAbility()
	local amount = kv.amount

	self:PlayEffects()
	self:PopupThunder(amount)
end

function _modifier_lighting:OnRefresh(kv)
	local parent = self:GetParent()
	local amount = kv.amount

	self:PlayEffects()
	self:PopupThunder(amount)
end
--------------------------------------------------------------------------------

function _modifier_lighting:CheckState()
	local state = {
		[MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function _modifier_lighting:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

---------------------------------------------------------------------------

function _modifier_lighting:PlayEffects()
	local particle_cast = "particles/econ/items/sven/sven_warcry_ti5/sven_warcry_cast_arc_lightning_impact.vpcf"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self.parent )
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        0,
        self.parent,
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        Vector(0,0,0), -- unknown
        true -- unknown, true
    )

    if IsServer() then self.parent:EmitSound("Hero_Zuus.ArcLightning.Target") end
end

function _modifier_lighting:GetStatusEffectName()
	return "particles/status_fx/status_effect_combo_breaker.vpcf"
end

function _modifier_lighting:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function _modifier_lighting:PopupThunder(amount)
    self:PopupNumbers("crit", Vector(255, 255, 0), 3.0, amount, 0, 4)
end

function _modifier_lighting:PopupNumbers(pfx, color, lifetime, number, presymbol, postsymbol)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
    local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    
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