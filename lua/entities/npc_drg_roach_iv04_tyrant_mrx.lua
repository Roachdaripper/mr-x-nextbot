if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Mr. X DrGBase"
ENT.Category = "RE2 Nextbots"
ENT.Models = {"models/roach/re2/tyrant_drg1.mdl"}
ENT.BloodColor = DONT_BLEED
ENT.CollisionBounds = Vector(17.5, 17.5, 90)
ENT.RagdollOnDeath = false

-- Stats --
ENT.SpawnHealth = 5000
ENT.ShoveResistance = true
ENT.DamageMultipliers = {}

-- AI --
ENT.MeleeAttackRange = 50
ENT.ReachEnemyRange = 50
ENT.AvoidEnemyRange = 0

-- Relationships --
ENT.Factions = {"FACTION_MRX"}
ENT.Frightening = true

-- Movements/animations --
ENT.WalkSpeed = 105
ENT.WalkAnimation = "0200"
ENT.RunSpeed = 155
ENT.RunAnimation = "0500"
ENT.IdleAnimation = "0000"
ENT.JumpAnimation = "1500"

-- Climbing --
ENT.ClimbLedges = true
ENT.ClimbLedgesMaxHeight = 300
ENT.LedgeDetectionDistance = 50
ENT.ClimbProps = true
ENT.ClimbLadders = true
ENT.LaddersUpDistance = 40
ENT.ClimbSpeed = 70
ENT.ClimbUpAnimation = "ladder_l"
ENT.ClimbAnimRate = 1
ENT.ClimbOffset = Vector(-15, 0, 0)

-- Detection --
ENT.EyeBone = "Head"
ENT.EyeOffset = Vector(5, 0, 2)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionPrompt = true
ENT.PossessionMovement = POSSESSION_MOVE_CUSTOM
ENT.PossessionViews = {
  {
    offset = Vector(0, 30, 20),
    distance = 100
  }
}
ENT.PossessionBinds = {
  [IN_ATTACK] = {
    {
      coroutine = true,
      onkeydown = function(self)
        self:Turn(self:GetPos() + self:PossessorNormal())
        self:FaceTowards(self:GetPos() + self:PossessorNormal())
        self["Punch"..math.random(2)](self)
      end
    }
  },
  [IN_ATTACK2] = {
    {
      coroutine = true,
      onkeydown = function(self)
        self:Turn(self:GetPos() + self:PossessorNormal())
        self:FaceTowards(self:GetPos() + self:PossessorNormal())
        self["Punch"..math.random(3, 4)](self)
      end
    }
  },
  [IN_JUMP] = {
    {
      coroutine = true,
      onkeydown = function(self)
        self:Turn(self:GetPos() + self:PossessorNormal())
        self:FaceTowards(self:GetPos() + self:PossessorNormal())
        local ent = self:GetClosestEnemy()
        if IsValid(ent) and ent:IsPlayer() then
          self:Grab(ent)
        else self:Grab() end
      end
    }
  }
}

if SERVER then

  -- Helpers --

  function ENT:snd(a,b)
		timer.Simple(b,function()
			if !IsValid(self) then return end
			self:EmitSound(a)
			self:EmitSound("re2/em6200/foley_long"..math.random(2)..".mp3")
		end)
	end

  -- Init/Think --

  function ENT:CustomInitialize()
    self:SetDefaultRelationship(D_HT)
    self:AddPlayersRelationship(D_HT, 2)
    self:SequenceEvent("ladder_l", 0.2, function()
      self:snd("re2/em6200/climb"..math.random(2)..".mp3",15/30)
    end)
    self:SequenceEvent("ladder_r", 0.25, function()
      self:snd("re2/em6200/climb"..math.random(2)..".mp3",15/30)
    end)
    self.ShotOffHat = false
    self:SetAttack("3000", true)
    self:SetAttack("3001", true)
    self:SetAttack("3002", true)
    self:SetAttack("3003", true)
  end
  function ENT:CustomThink()
    self:RemoveAllDecals()
    if self:IsPossessed() then
      self:DirectPoseParametersAt(self:PossessorTrace().HitPos, "aim_pitch", "aim_yaw", self:EyePos())
    elseif self:HasEnemy() and self:IsInSight(self:GetEnemy()) then
      self:DirectPoseParametersAt(self:GetEnemy():GetPos(), "aim_pitch", "aim_yaw", self:EyePos())
    else self:DirectPoseParametersAt(nil, "aim_pitch", "aim_yaw", self:EyePos()) end
  end

  -- Attacks --

  local attackSounds = {
    "re2/em6200/attack_hit1.mp3",
    "re2/em6200/attack_hit2.mp3",
    "re2/em6200/attack_hit3.mp3",
    "re2/em6200/attack_hit4.mp3",
    "re2/em6200/attack_hit5.mp3"
  }
  local function OnAttack(self, hit)
    if #hit == 0 then return end
    self:EmitSound(attackSounds[math.random(#attackSounds)])
  end

  function ENT:Punch1()
    self:snd("re2/em6200/attack_swing"..math.random(5)..".mp3",0.1)
    self:snd("re2/em6200/attack_swing"..math.random(5)..".mp3",0.5)
    self:snd("re2/em6200/step"..math.random(5)..".mp3",2.6)
    self:Attack({
      damage = 50,
      delay = 1,
      viewpunch = Angle(40, 0, 0)
    }, OnAttack)
    self:PlaySequenceAndMove("3000")
  end
  function ENT:Punch2()
    self:snd("re2/em6200/attack_swing"..math.random(5)..".mp3",0.1)
    self:snd("re2/em6200/attack_swing"..math.random(5)..".mp3",0.5)
    self:snd("re2/em6200/step"..math.random(5)..".mp3",2.8)
    self:snd("re2/em6200/step"..math.random(5)..".mp3",3.2)
    self:Attack({
      damage = 50,
      delay = 1,
      viewpunch = Angle(40, 0, 0)
    }, OnAttack)
    self:PlaySequenceAndMove("3001")
  end
  function ENT:Punch3()
    self:snd("re2/em6200/attack_swing"..math.random(5)..".mp3",0.1)
    self:snd("re2/em6200/step"..math.random(5)..".mp3",2)
    self:snd("re2/em6200/step"..math.random(5)..".mp3",2.4)
    self:Attack({
      damage = 30,
      delay = 0.5,
      viewpunch = Angle(20, 20, 0)
    }, OnAttack)
    self:PlaySequenceAndMove("3002")
  end
  function ENT:Punch4()
    self:snd("re2/em6200/attack_swing"..math.random(5)..".mp3",0.1)
    self:snd("re2/em6200/step"..math.random(5)..".mp3",2)
    self:snd("re2/em6200/step"..math.random(5)..".mp3",2.6)
    self:Attack({
      damage = 30,
      delay = 0.5,
      viewpunch = Angle(20, -20, 0)
    }, OnAttack)
    self:PlaySequenceAndMove("3003")
  end
  function ENT:Punch()
    self["Punch"..math.random(4)](self)
  end
  function ENT:Grab(ent)
    local grabbed = false
    local succeed = false
    self:snd("re2/em6200/attack_swing"..math.random(5)..".mp3",0)
    self:snd("re2/em6200/step"..math.random(5)..".mp3",13/30)
    self:snd("re2/em6200/attack_swing"..math.random(5)..".mp3",13/30)
    self:PlaySequenceAndMove("ragdoll_grabA", 1, function(cycle)
      if grabbed or cycle < 0.5 then return end
      grabbed = true
      if not IsValid(ent) then return end
      if self:GetHullRangeSquaredTo(ent) > 50^2 then return end
      succeed = true
      self.attachment=ents.Create("obj_ragdoll_attachment_body_mrx")
      self.attachment.model = ent:GetModel()
      self.attachment:SetPos(self:GetPos())
      self.attachment:SetParent(self)
      self.attachment:Spawn()
      self:DeleteOnRemove(self.attachment)
      if ent:IsPlayer() then
        ent:SetPos(self:GetPos() + (self:GetForward()*60) + Vector(0,0,60))
        ent:KillSilent()
      else
        SafeRemoveEntity(ent)
      end
    end)
    if succeed then
      self:snd("physics/body/body_medium_impact_soft"..math.random(5,7)..".wav",0)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",3/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",8/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",15/30)
      self:PlaySequenceAndMove("ragdoll_grabB")
      self:snd("re2/em6200/step"..math.random(5)..".mp3",8/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",13/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",19/30)
      self:Timer(27/30,function()
        self:EmitSound("physics/body/body_medium_break"..math.random(2,3)..".wav",511,100)
        ParticleEffectAttach("blood_advisor_puncture",PATTACH_POINT_FOLLOW,self,3)
        for i=1,math.random(5,10) do ParticleEffectAttach("blood_impact_red_01",PATTACH_POINT_FOLLOW,self,3) end
        self.attachment.CanDetach = true
        self.attachment.doll:Fire("fadeandremove",1,10)
        if (ent:IsPlayer() and !ent:Alive()) then
          ent:ScreenFade(SCREENFADE.IN,Color(255,0,0,255),0.3,0.2)
          ent:EmitSound("player/pl_pain"..math.random(5,7)..".wav",511,100)
        end
      end)
      self:PlaySequenceAndMove("ragdoll_grabC")
    end
  end

  -- Downed --

  function ENT:Shock(duration)
    local fx = EffectData()
		fx:SetEntity(self)
		fx:SetOrigin(self:LocalToWorld(Vector(0,0,50)))
		fx:SetStart(self:LocalToWorld(Vector(0,0,50)))
		fx:SetScale(1)
		fx:SetMagnitude(10)
		for i=1,math.Round(162/30,1)*10 do
			timer.Simple(0.1*i,function()
				if !IsValid(self) then return end
				self:EmitSound("ambient/energy/spark"..math.random(1,6)..".wav")
				util.Effect("teslahitboxes",fx)
			end)
		end
    self:snd("re2/em6200/step"..math.random(6)..".mp3",6/30)
		self:snd("re2/em6200/step"..math.random(6)..".mp3",14/30)
		self:snd("re2/em6200/foley_long"..math.random(2)..".mp3",43/30)
		self:snd("re2/em6200/foley_long"..math.random(2)..".mp3",43/30)
		self:snd("re2/em6200/foley_long"..math.random(2)..".mp3",43/30)
		self:snd("darksouls/npc/fsb.frpg_c2300/s230012302.wav.mp3",5.4)
    self:PlaySequenceAndMove("2251")
    ParticleEffect("hunter_projectile_explosion_1",self:LocalToWorld(Vector(0,0,50)),Angle(0,0,0),nil)
    self:snd("re2/em6200/step"..math.random(6)..".mp3",44/30)
		self:snd("re2/em6200/land.mp3",72/30)
		self:snd("re2/em6200/foley_long"..math.random(2)..".mp3",72/30)
		self:snd("re2/em6200/foley_long"..math.random(2)..".mp3",72/30)
		self:snd("re2/em6200/foley_long"..math.random(2)..".mp3",72/30)
    self:PlaySequenceAndMove("2252")
    self:OneKnee(duration)
  end

  function ENT:Stun(duration)
    self:snd("re2/em6200/step"..math.random(6)..".mp3",18/30)
		self:snd("re2/em6200/land.mp3",43/30)
		self:snd("re2/em6200/foley_long"..math.random(2)..".mp3",43/30)
		self:snd("re2/em6200/foley_long"..math.random(2)..".mp3",43/30)
		self:snd("re2/em6200/foley_long"..math.random(2)..".mp3",43/30)
    self:PlaySequenceAndMove("2200")
    self:OneKnee(duration)
  end

  function ENT:OneKnee(duration)
    if isnumber(duration) and duration > 0 then
      self:SetHealthRegen(math.ceil((self:GetMaxHealth()-self:Health())/duration))
    end
    self:ResetSequence("2201")
    self:SetPlaybackRate(1)
    while self:Health() < self:GetMaxHealth() do
      self:YieldCoroutine(false)
    end
    self:snd("re2/em6200/foley_long"..math.random(2)..".mp3",0)
  	self:snd("re2/em6200/foley_adjust_hat"..math.random(2)..".mp3",40/30)
  	self:snd("re2/em6200/step"..math.random(6)..".mp3",83/30)
  	self:snd("re2/em6200/foley_adjust_hat"..math.random(2)..".mp3",83/30)
  	self:snd("re2/em6200/step"..math.random(6)..".mp3",121/30)
  	self:snd("re2/em6200/foley_long"..math.random(2)..".mp3",121/30)
    self:PlaySequenceAndMove("2202")
    self:SetHealthRegen(0)
  end

  -- AI --

  function ENT:ShouldRun()
    return self:HasEnemy() and self.ShotOffHat
  end

  function ENT:OnMeleeAttack(enemy)
    for i = 1, 1000 do self:FaceTowards(enemy) end
    --[[if enemy:IsPlayer() and math.random(5) == 1 then self:Grab(enemy)
    else self:Punch() end]]
    self:Punch()
    if self:HasEnemy() and self:Visible(self:GetEnemy()) then
      self:Turn(self:GetEnemy():GetPos())
    end
  end
  function ENT:OnNewEnemy(enemy)
    self:CallInCoroutine(function(self, delay)
      if delay > 0.1 then return end
      if not IsValid(enemy) then return end
      if not self:Visible(enemy) then return end
      self:Turn(enemy:GetPos())
    end)
  end
  function ENT:OnEnemyChange(oldenemy, newenemy)
    if not IsValid(oldenemy) or (oldenemy:IsPlayer() and not oldenemy:Alive()) then
      self:OnNewEnemy(newenemy)
    end
  end
  function ENT:OnLastEnemy(enemy)
    if not IsValid(enemy) then return end
    self:AddPatrolPos(enemy:GetPos(), 1)
  end

  function ENT:OnReachedPatrol(pos)
    self:Wait(math.random(3, 7))
  end

  function ENT:OnIdle()
    if not navmesh.IsLoaded() then return end
    local players = player.GetAll()
    table.sort(players, function()
      return math.random(2 == 1)
    end)
    local ply = players[1]
    local pos = ply:GetPos() + Vector(math.random(-1, 1)*500, math.random(-1, 1)*500, 0)
    self:AddPatrolPos(navmesh.GetNearestNavArea(pos):GetClosestPointOnArea(pos))
  end

  -- Animations --

  function ENT:Turn(pos, subs)
    if self:IsDown() then return end
    local direction = self:CalcPosDirection(pos, subs)
    if direction == "W" then
      self:snd("re2/em6200/step"..math.random(5)..".mp3",20/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",33/30)
      self:PlaySequenceAndMove("turn_90left")
      self.LastTurn = CurTime()
    elseif direction == "E" then
      self:snd("re2/em6200/step"..math.random(5)..".mp3",20/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",33/30)
      self:PlaySequenceAndMove("turn_90right")
      self.LastTurn = CurTime()
    elseif direction == "S" and math.random(2) == 1 then
      self:snd("re2/em6200/step"..math.random(5)..".mp3",33/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",50/30)
      self:PlaySequenceAndMove("turn_180left")
      self.LastTurn = CurTime()
    elseif direction == "S" then
      self:snd("re2/em6200/step"..math.random(5)..".mp3",33/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",50/30)
      self:PlaySequenceAndMove("turn_180right")
      self.LastTurn = CurTime()
    end
  end

  function ENT:OnLandOnGround()
    self:CallInCoroutine(function(self, delay)
      if delay > 0.1 then return end
      self:snd("re2/em6200/step"..math.random(5)..".mp3",0)
      self:PlaySequenceAndMove("1750")
    end)
  end

  function ENT:OnSpawn()
    local tr = util.TraceLine({
			start=self:GetPos()+Vector(0,0,5),
			endpos=self:GetPos()+Vector(0,0,50000),
			filter=self
		})
		if !tr.HitSky then
			ParticleEffect("strider_wall_smash",tr.HitPos,Angle(0,0,0),nil)
			ParticleEffect("strider_small_spray",tr.HitPos,Angle(0,0,0),nil)
			ParticleEffect("strider_impale_ground",tr.HitPos,Angle(0,0,0),nil)
			ParticleEffect("strider_headbeating_01",tr.HitPos,Angle(0,0,0),nil)
			ParticleEffect("strider_goop_01e",tr.HitPos,Angle(0,0,0),nil)
			ParticleEffect("strider_brain_open_01b",tr.HitPos,Angle(0,0,0),nil)
			self:EmitSound("explode_4",511,100)
		end
		timer.Simple(31/30,function()if !IsValid(self) then return end self:EmitSound("re2/em6200/land.mp3",511,100)end)
		self:PlaySequenceAndMove("nzu_intro_fall")
		self:snd("re2/em6200/step"..math.random(5)..".mp3",18/30)
		self:snd("re2/em6200/step"..math.random(5)..".mp3",33/30)
		self:snd("re2/em6200/step"..math.random(5)..".mp3",40/30)
		self:PlaySequenceAndMove("nzu_intro_land")
  end

  -- Misc --

  function ENT:OnCombineBall(ball)
    ball:Fire("explode", 0)
    return true
  end

  -- Damage --

  function ENT:OnTakeDamage(dmg)
    if dmg:IsDamageType(DMG_BLAST) then dmg:ScaleDamage(10) end
    if IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsPlayer() then
			local hitgroup = dmg:GetAttacker():GetEyeTrace().HitGroup
			if hitgroup == HITGROUP_HEAD then
        if not self.ShotOffHat then
          self:SetBodygroup(2,1)
  				local hat = ents.Create("prop_physics")
  				hat:SetModel("models/roach/re2/tyrant_hat.mdl")
  				hat:SetPos(self:GetAttachment(2).Pos)
  				hat:SetAngles(self:GetAngles())
  				hat:Spawn()
  				hat:SetCollisionGroup(COLLISION_GROUP_WEAPON)
  				self:DeleteOnRemove(hat)
  				local phys = hat:GetPhysicsObject()
  				phys:SetVelocity((self:GetForward()*-150) + (self:GetUp()*150))
  				phys:AddAngleVelocity(Vector(0, 500, 0))
  				self.ShotOffHat = true
        end
        return 2
			end
    end
  end

  function ENT:OnFatalDamage()
    return true
  end
  function ENT:OnDowned(dmg)
    if dmg:IsDamageType(DMG_SHOCK) then
      self:Shock(30)
    else self:Stun(30) end
  end

  -- Possession --

  function ENT:PossessionControls(forward, backward, right, left)
    local direction = self:GetPos()
    if forward then direction = direction + self:PossessorForward()
    elseif backward then direction = direction - self:PossessorForward() end
    if right then direction = direction + self:PossessorRight()
    elseif left then direction = direction - self:PossessorRight() end
    if direction ~= self:GetPos() then
      self:Turn(direction, true)
      self:MoveTowards(direction)
    end
  end

  -- Climbing --

  function ENT:OnStartClimbing(ladder, height)
    if not isvector(ladder) then
      self:snd("re2/em6200/step"..math.random(5)..".mp3",12/30)
      self:snd("re2/em6200/climb"..math.random(2)..".mp3",25/30)
      self:snd("re2/em6200/climb"..math.random(2)..".mp3",45/30)
      self:PlaySequenceAndMoveAbsolute("ladder_start", 1, function()
        if isvector(ladder) then
          self:FaceTowards(ladder)
        else self:FaceTowards(ladder:GetBottom()) end
      end)
      self.RightLadder = false
      self:LoopTimer(0.5, function()
        if not self:IsClimbing() then return false end
        self.RightLadder = not self.RightLadder
        if self.RightLadder then
          self.ClimbUpAnimation = "ladder_r"
        else
          self.ClimbUpAnimation = "ladder_l"
        end
      end)
    else return true end
  end
  function ENT:WhileClimbing(ladder, left)
    if left < 100 then return true end
  end
  function ENT:OnStopClimbing()
    if self.RightLadder then
      self:snd("re2/em6200/climb"..math.random(2)..".mp3",13/30)
      self:snd("re2/em6200/land.mp3",31/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",32/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",34/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",49/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",60/30)
      self:PlaySequenceAndMoveAbsolute("ladder_finish_r")
    else
      self:snd("re2/em6200/climb"..math.random(2)..".mp3",13/30)
      self:snd("re2/em6200/land.mp3",31/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",32/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",34/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",49/30)
      self:snd("re2/em6200/step"..math.random(5)..".mp3",60/30)
      self:PlaySequenceAndMoveAbsolute("ladder_finish_l")
    end
  end
  function ENT:CustomClimbing(ledge, height)
    self:FaceTo(ledge)
    self:PlayClimbSequence("drg_climb", 206.75, height)
  end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
