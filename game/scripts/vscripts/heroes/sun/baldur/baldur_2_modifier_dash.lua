baldur_2_modifier_dash = class ({})

function baldur_2_modifier_dash:IsHidden() return true end
function baldur_2_modifier_dash:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function baldur_2_modifier_dash:OnCreated(kv)
  self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.target = EntIndexToHScript(kv.target)
  self.damage = kv.damage
  self.stun_duration = kv.stun_duration
	self.trigger = false

	local vector = (self.target:GetAbsOrigin() - self.parent:GetAbsOrigin()):Normalized()
	self.parent:SetForwardVector(vector)
	self.angle = self.parent:GetForwardVector():Normalized()
	self.distance = (self.ability:GetCastRange(self.parent:GetOrigin(), self.target) + 200) / self:GetDuration()

	if IsServer() then
		self:StartIntervalThink(FrameTime())
		self:PlayEfxStart()
	end
end

function baldur_2_modifier_dash:OnRefresh(kv)
end

function baldur_2_modifier_dash:OnRemoved()
end

function baldur_2_modifier_dash:OnDestroy()
	if not IsServer() then return end
	
	ResolveNPCPositions(self.parent:GetAbsOrigin(), 128)

	if self.trigger == false then
    if self.parent:IsCommandRestricted() == false then
      self.parent:MoveToPosition(self.parent:GetOrigin())
    end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function baldur_2_modifier_dash:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}
	return state
end

function baldur_2_modifier_dash:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING
	}

	return funcs
end

function baldur_2_modifier_dash:GetModifierDisableTurning()
	return 1
end

function baldur_2_modifier_dash:OnIntervalThink()
	self:HorizontalMotion(self.parent, FrameTime())
end

function baldur_2_modifier_dash:HorizontalMotion(unit, time)
	if not IsServer() then return end

	local pos = unit:GetAbsOrigin()
	GridNav:DestroyTreesAroundPoint(pos, 80, false)
	local pos_p = self.angle * self.distance
	local next_pos = GetGroundPosition(pos + pos_p,unit)
	unit:SetAbsOrigin(next_pos)

	if self.target then
		if IsValidEntity(self.target) then
      local enemies = FindUnitsInRadius(
        self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, 95,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE, 0, false
      )
    
      for _,enemy in pairs(enemies) do
        if self.target ~= enemy then
          if TargetHasModifierByAbility(enemy, "_modifier_stun", self.ability) == false then
            ApplyBash(enemy, self.ability, self.stun_duration, self.damage, false)
          end
        end
      end

			if CalcDistanceBetweenEntityOBB(self.parent, self.target) <= 100 then
        AddModifier(self.parent, self.ability, "baldur_2_modifier_impact", {duration = 0.3}, false)

        if self.parent:IsCommandRestricted() == false then
          self.parent:MoveToTargetToAttack(self.target)
        end

				self.trigger = true
				self:Destroy()
			end
		end
	end
end

-- EFFECTS -----------------------------------------------------------

function baldur_2_modifier_dash:GetEffectName()
	return "particles/bald/bald_dash/bald_dash.vpcf"
end

function baldur_2_modifier_dash:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function baldur_2_modifier_dash:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Bald.Dash") end
end