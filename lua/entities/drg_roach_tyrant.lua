if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Mr. X"
ENT.Category = "RE2 Nextbots"
ENT.Models = {"models/roach/re2/tyrant_drg1.mdl"}
ENT.BloodColor = BLOOD_COLOR_MECH
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
ENT.UseWalkframes = true
ENT.WalkAnimation = "0200"
ENT.RunAnimation = "0500"
ENT.IdleAnimation = "0000"
ENT.JumpAnimation = "1000"

-- Climbing --
ENT.ClimbLedges = true
ENT.ClimbLedgesMaxHeight = 300
ENT.LedgeDetectionDistance = 20
ENT.ClimbProps = true
ENT.ClimbLadders = true
ENT.LaddersUpDistance = 40
ENT.ClimbSpeed = 70
ENT.ClimbUpAnimation = "ladder_l"
ENT.ClimbAnimRate = 1
ENT.ClimbOffset = Vector(-15, 0, 0)

-- Detection --
ENT.EyeBone = "head"
ENT.EyeOffset = Vector(10, 0, 1)
ENT.EyeAngle = Angle(0, 0, 0)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_CUSTOM
ENT.PossessionViews = {
	{
		offset = Vector(0, 30, 20),
		distance = 100
	},
	{
		offset = Vector(7.5, 0, 0),
		distance = 0,
		eyepos = true
	}
}
ENT.PossessionBinds = {
	[IN_ATTACK] = {
		{
			coroutine = true,
			onkeydown = function(self)
				self:Turn(self:GetPos() + self:PossessorNormal())
				self:FaceTowards(self:GetPos() + self:PossessorNormal())
				self:PlaySequenceAndMove("300"..math.random(0,3))
			end
		}
	},
	[IN_ATTACK2] = {
		{
			coroutine = true,
			onkeydown = function(self)
				self:Turn(self:GetPos() + self:PossessorNormal())
				self:FaceTowards(self:GetPos() + self:PossessorNormal())
				local ent = self:GetClosestEnemy()
				self:Grab(ent)
			end
		}
	},
	[IN_RELOAD] = {
		{
			coroutine = false,
			onkeydown = function(self)
				if not self:GetCooldown("MRXTaunt") then return end
				if self:GetCooldown("MRXTaunt") == 0 then
					self:SetCooldown("MRXTaunt", 3)
					self:Taunt()
				end
			end
		}
	}
}

if SERVER then

  -- Helpers --

function ENT:snd(a)
	self:EmitSound(a)
	self:EmitSound("re2/em6200/foley_long"..math.random(2)..".mp3")
end

-- Init/Think --

function ENT:CustomInitialize()
	self:SetDefaultRelationship(D_HT)
	self:AddPlayersRelationship(D_HT, 2)
	self.ShotOffHat = false
	self.CanAttack = true
	self:SetAttack("3000", true)
	self:SetAttack("3001", true)
	self:SetAttack("3002", true)
	self:SetAttack("3003", true)
	
	--// sequence events for ez sound playback
	local function stepsnd() self:snd("re2/em6200/step"..math.random(6)..".mp3") end
	
	self:SequenceEvent("ladder_l", 0.2, function()self:snd("re2/em6200/climb"..math.random(2)..".mp3")end)
	self:SequenceEvent("ladder_r", 0.25, function()self:snd("re2/em6200/climb"..math.random(2)..".mp3")end)
	
	self:SequenceEvent("3000",{0.028301886792453,0.14150943396226},function()self:snd("re2/em6200/attack_swing"..math.random(5)..".mp3")end)
	self:SequenceEvent("3000",{0.056603773584906,0.23584905660377, 0.75471698113208},stepsnd)
	self:SequenceEvent("3000",0.25471698113208,function()
		self:Attack({
			damage = self:IsPossessed() and 800 or 50,
			viewpunch = Angle(40, 0, 0),
			type = DMG_CLUB,
		}, function(self, hit)
			if #hit == 0 then return end 
			self:EmitSound("re2/em6200/attack_hit"..math.random(5)..".mp3")
			local ent = self:GetClosestEnemy()
			if ent:IsNPC() or (math.random(1,5) <= 3) then
				self:Taunt()
			end
		end)
	end)
	
	self:SequenceEvent("3001",{0.027522935779817,0.13761467889908},function()self:snd("re2/em6200/attack_swing"..math.random(5)..".mp3")end)
	self:SequenceEvent("3001",{0.055045871559633,0.22935779816514, 0.75229357798165,0.88990825688073},stepsnd)
	self:SequenceEvent("3001",0.24770642201835,function()
		self:Attack({
			damage = self:IsPossessed() and 800 or 50,
			viewpunch = Angle(40, 0, 0),
			type = DMG_CLUB,
		}, function(self, hit)
			if #hit == 0 then return end 
			self:EmitSound("re2/em6200/attack_hit"..math.random(5)..".mp3")
			local ent = self:GetClosestEnemy()
			if ent:IsNPC() or (math.random(1,5) <= 3) then
				self:Taunt()
			end
		end)
	end)
	
	self:SequenceEvent("3002",0.03448275862069,function()self:snd("re2/em6200/attack_swing"..math.random(5)..".mp3")end)
	self:SequenceEvent("3002",{0.11494252873563,0.2183908045977,0.5632183908046,0.74712643678161},stepsnd)
	self:SequenceEvent("3002",0.17241379310345,function()
		self:Attack({
			damage = self:IsPossessed() and 800 or 30,
			viewpunch = Angle(20, 20, 0),
			type = DMG_CLUB,
		}, function(self, hit)
			if #hit == 0 then return end 
			self:EmitSound("re2/em6200/attack_hit"..math.random(5)..".mp3")
			local ent = self:GetClosestEnemy()
			if ent:IsNPC() or (math.random(1,5) <= 3) then
				self:Taunt()
			end
		end)
	end)
	
	self:SequenceEvent("3003",0.035294117647059,function()self:snd("re2/em6200/attack_swing"..math.random(5)..".mp3")end)
	self:SequenceEvent("3003", {0.082352941176471, 0.2, 0.64705882352941, 0.88235294117647},stepsnd)
	self:SequenceEvent("3003",0.14117647058824,function()
		self:Attack({
			damage = self:IsPossessed() and 800 or 30,
			viewpunch = Angle(20, -20, 0),
			type = DMG_CLUB,
		}, function(self, hit)
			if #hit == 0 then return end 
			self:EmitSound("re2/em6200/attack_hit"..math.random(5)..".mp3")
			local ent = self:GetClosestEnemy()
			if ent:IsNPC() or (math.random(1,5) <= 3) then
				self:Taunt()
			end
		end)
	end)
	
	self:SequenceEvent("ragdoll_grabA",{0, 0.23214285714286},function()self:snd("re2/em6200/attack_swing"..math.random(5)..".mp3")end)
	self:SequenceEvent("ragdoll_grabA",{0.23214285714286,0.41071428571429,0.96428571428571},stepsnd)
	self:SequenceEvent("ragdoll_grabB",{0.039473684210526,0.078947368421053,0.19736842105263},stepsnd)
	self:SequenceEvent("ragdoll_grabC",{0.053333333333333, 0.086666666666667, 0.12666666666667},stepsnd)
		
	self:SequenceEvent("2200",0.2647058823529,stepsnd)
	self:SequenceEvent("2200",0.63235294117647,function()
		self:snd("re2/em6200/land.mp3")
		for i=1,3 do self:snd("re2/em6200/foley_long"..math.random(2)..".mp3")end
	end)
	self:SequenceEvent("2202",0.29197080291971,function()self:snd("re2/em6200/foley_adjust_hat"..math.random(2)..".mp3")end)
	self:SequenceEvent("2202",{0.60583941605839,0.88321167883212},stepsnd)
	
	self:SequenceEvent("2251",{0.03680981595092, 0.085889570552147},stepsnd)
	self:SequenceEvent("2251",0.2638036809816,function()for i=1,3 do self:snd("re2/em6200/foley_long"..math.random(2)..".mp3")end end)
	self:SequenceEvent("2252",0.46315789473684,stepsnd)
	self:SequenceEvent("2252",0.75789473684211,function()
		self:snd("re2/em6200/land.mp3")
		for i=1,3 do self:snd("re2/em6200/foley_long"..math.random(2)..".mp3")end
	end)
	
	self:SequenceEvent("turn_90left",{20/42, 33/42},stepsnd)
	self:SequenceEvent("turn_90right",{20/42, 33/42},stepsnd)
	self:SequenceEvent("turn_180left",{33/65,50/65},stepsnd)
	self:SequenceEvent("turn_180right",{33/65, 50/65},stepsnd)
	
	self:SequenceEvent("nzu_intro_fall",{31/49},function()self:snd("re2/em6200/land.mp3")end)
	self:SequenceEvent("nzu_intro_land",{18/54, 33/54, 40/54},stepsnd)
	
	self:SequenceEvent("9050",{13/119, 19/119, 101/119, 116/119},stepsnd)
	self:SequenceEvent("9060",{10/115, 16/115, 96/115, 112/115},stepsnd)
	self:SequenceEvent("9061",{17/110, 25/110, 91/110, 106/110},stepsnd)
	
	self:SequenceEvent("ladder_start",12/53,stepsnd)
	self:SequenceEvent("ladder_start",{25/53, 45/53},function(self,cycle)self:snd("re2/em6200/climb"..math.random(2)..".mp3")end)
	
	self:SequenceEvent("ladder_finish_l",{32/72,34/72,49/72,60/72},stepsnd)
	self:SequenceEvent("ladder_finish_l",13/72,function(self,cycle)self:snd("re2/em6200/climb"..math.random(2)..".mp3")end)
	self:SequenceEvent("ladder_finish_l",31/72,function(self,cycle)self:snd("re2/em6200/land.mp3")end)
	
	self:SequenceEvent("ladder_finish_r",{32/72,34/72,49/72,60/72},stepsnd)
	self:SequenceEvent("ladder_finish_r",13/72,function(self,cycle)self:snd("re2/em6200/climb"..math.random(2)..".mp3")end)
	self:SequenceEvent("ladder_finish_r",31/72,function(self,cycle)self:snd("re2/em6200/land.mp3")end)
	
	self:SequenceEvent("g_taunt2",12/54,function(self,cycle)self:snd("re2/em6200/foley_taunt"..math.random(2)..".mp3")end)
	self:SequenceEvent("g_taunt2",20/54,function(self,cycle)self:snd("re2/em6200/land.mp3")end)
	
	self:SequenceEvent("drg_climb",{17/100, 34/100, 37/100},function(self,cycle)self:snd("re2/em6200/climb"..math.random(2)..".mp3")end)
	self:SequenceEvent("drg_climb",72/100,function(self,cycle)self:snd("re2/em6200/land.mp3")end)
	self:SequenceEvent("drg_climb",55/100,stepsnd)
	self:SequenceEvent("drg_vault_barricade",{18/63,20/63,45/63},stepsnd)
	
	self:SequenceEvent("9200",{6/84, 13/84, 20/84, 53/84, 70/84, 83/84},stepsnd)
	self:SequenceEvent("9201",{7/76,13/76,57/76,71/76},stepsnd)
	--// sequence events for ez sound playback
end

function ENT:DoorCode(door)
	local doorseq,doordur = self:LookupSequence("9200")
	local doorseq2,doordur2 = self:LookupSequence("9201")
	if IsValid(door) and door:GetClass() == "prop_door_rotating" then
	-- self:CallInCoroutine(function(self, delay)
	-- if delay > 0.1 then return end
		self.CanOpenDoor = false
		self.CanAttack = false
		self:SetNotSolid(true)
		door:SetNotSolid(true)
			-- find ourselves to know which side of the door we're on
			local fwd = door:GetPos()+door:GetForward()*5
			local bck = door:GetPos()-door:GetForward()*5
			local pos = self:GetPos()
			local fuck_double_doors1 = door:GetKeyValues()
			local fuck_double_doors2 = nil
			if isstring(fuck_double_doors1.slavename) and fuck_double_doors1.slavename != "" then
				fuck_double_doors2 = ents.FindByName(fuck_double_doors1.slavename)[1]
			end

			if fwd:DistToSqr(pos) < bck:DistToSqr(pos) then -- entered from forward
				self:SetNotSolid(true)
				door:SetNotSolid(true)
				if isentity(fuck_double_doors2) then
					self:SetPos(door:GetPos()+(door:GetForward()*50)+(door:GetRight()*-50))
				else
					self:SetPos(door:GetPos()+(door:GetForward()*80)+(door:GetRight()*-32))
				end
				local ang = door:GetAngles()
				ang:RotateAroundAxis(Vector(0,0,1),180)
				self:SetAngles(ang)
			elseif bck:DistToSqr(pos) < fwd:DistToSqr(pos) then -- entered from backward
				self:SetNotSolid(true)
				door:SetNotSolid(true)
				if isentity(fuck_double_doors2) then
					self:SetPos(door:GetPos()+(door:GetForward()*-50)+(door:GetRight()*-50))
				else
					self:SetPos(door:GetPos()+(door:GetForward()*-80)+(door:GetRight()*-12))
				end
				local a = (door:GetAngles())
				a:Normalize()
				self:SetAngles(a)
			end
			-- find ourselves to know which side of the door we're on
			if (fwd:DistToSqr(pos) < bck:DistToSqr(pos)) or (bck:DistToSqr(pos) < fwd:DistToSqr(pos)) then

				self:SetNotSolid(true)
				door:SetNotSolid(true)
				door:Fire("setspeed",500)

				if isentity(fuck_double_doors2) then
					fuck_double_doors2:SetNotSolid(true)
					fuck_double_doors2:Fire("setspeed",500)

					self:Timer(7/30,function()
						self:EmitSound("doors/vent_open3.wav",511,math.random(50,80))
						door:Fire("openawayfrom",self:GetName())
						fuck_double_doors2:Fire("openawayfrom",self:GetName())
					end)
					self:Timer(doordur2,function()
						door:Fire("setspeed",100)
						door:Fire("close")
						fuck_double_doors2:Fire("setspeed",100)
						fuck_double_doors2:Fire("close")
						self:Timer(1,function()
							door:SetNotSolid(false)
							fuck_double_doors2:SetNotSolid(false)
							self.CanOpenDoor = true
							self.CanAttack = true
							self.CanFlinch = false
							self:SetNotSolid(false)
						end)
					end)
					-- self:PlaySequenceAndMoveAbsolute("9201")
					self:PlaySequenceAndMove("9201")
				else
					self:Timer(0.5,function()
						if !IsValid(self) then return end
						self:EmitSound("doors/vent_open3.wav",511,math.random(50,80))
						door:Fire("openawayfrom",self:GetName())
					end)
					self:Timer(doordur,function()
						if !IsValid(self) then return end
						door:Fire("setspeed",100)
						door:Fire("close")
						self:Timer(0.2,function()
							door:SetNotSolid(false)
							if !IsValid(self) then return end
							self.CanOpenDoor = true
							self.CanAttack = true
							self.CanFlinch = false
							self:SetNotSolid(false)
						end)
					end)
					-- self:PlaySequenceAndMoveAbsolute("9200")
					self:PlaySequenceAndMove("9200")
				end
			else
				self:Timer(1,function()
					door:SetNotSolid(false)
					self:Timer(1,function()
						if !IsValid(self) then return end
						self.CanOpenDoor = true
					end)
					if !IsValid(self) then return end
					self.CanAttack = true
					self.CanFlinch = false
					self:SetNotSolid(false)
				end)
			end
	-- end)
	end
end

function ENT:OnContact(ent)
	if self.CanAttack and (ent != self:GetEnemy()) and (ent:IsPlayer() or ent:IsNPC()) then
		self.CanAttack = false
		local velocity = Vector(0, 150, 50)
		local right = self:GetPos()+self:GetRight()*1
		local left = self:GetPos()-self:GetRight()*1
		local pos = ent:GetPos()
		if left:DistToSqr(pos) < right:DistToSqr(pos) then
			self:PlaySequence("g_puntR")
			self:Timer(0.4,function()
				local dmg = DamageInfo()
				dmg:SetDamage(100000)
				dmg:SetDamageForce(self:GetRight()* -velocity)
				dmg:SetDamageType(DMG_CLUB)
				dmg:SetAttacker(self)
				dmg:SetReportedPosition(self:GetPos())

				ent:SetVelocity(self:GetRight()* -velocity)
				ent:TakeDamageInfo(dmg)

				self:EmitSound("re2/em6200/attack_hit"..math.random(5)..".mp3",511,100)
			end)
		else
			self:PlaySequence("g_puntL2")
			self:Timer(0.4,function()
				local dmg = DamageInfo()
				dmg:SetDamage(100000)
				dmg:SetDamageForce(self:GetRight()*velocity)
				dmg:SetDamageType(DMG_CLUB)
				dmg:SetAttacker(self)
				dmg:SetReportedPosition(self:GetPos())

				ent:SetVelocity(self:GetRight()* velocity)
				ent:TakeDamageInfo(dmg)

				self:EmitSound("re2/em6200/attack_hit"..math.random(5)..".mp3",511,100)
			end)
		end
		self:Timer(1.4,function()self.CanAttack = true end)
	end
end

function ENT:Taunt()
	self:PlaySequence("g_taunt"..math.random(3))
end

function ENT:CustomThink()
	self:RemoveAllDecals()
	if self:IsPossessed() then
		self:DirectPoseParametersAt(self:PossessorTrace().HitPos, "aim_pitch", "aim_yaw", self:EyePos())
	elseif self:HasEnemy() and self:IsInSight(self:GetEnemy()) then
		self:DirectPoseParametersAt(self:GetEnemy():GetPos(), "aim_pitch", "aim_yaw", self:EyePos())
	else self:DirectPoseParametersAt(nil, "aim_pitch", "aim_yaw", self:EyePos()) end
end

function ENT:Grab(ent)
	local grabbed = false
	local succeed = false
	self:PlaySequenceAndMove("ragdoll_grabA", 1, function(self, cycle)
		if grabbed or cycle < 0.28571428571429 then return end
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
		return true
	end)
	if succeed then
		self:PlaySequenceAndMove("ragdoll_grabB")
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

function ENT:Shock(duration)
	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetOrigin(self:LocalToWorld(Vector(0,0,50)))
	fx:SetStart(self:LocalToWorld(Vector(0,0,50)))
	fx:SetScale(1)
	fx:SetMagnitude(10)
	for i=1,math.Round(162/30,1)*10 do
		self:Timer(0.1*i,function()
			if !IsValid(self) then return end
			self:EmitSound("ambient/energy/spark"..math.random(1,6)..".wav")
			util.Effect("teslahitboxes",fx)
		end)
	end
	self:PlaySequenceAndMove("2251")
	self:snd("darksouls/npc/fsb.frpg_c2300/s230012302.wav.mp3")
	ParticleEffect("hunter_projectile_explosion_1",self:LocalToWorld(Vector(0,0,50)),Angle(0,0,0),nil)
	self:PlaySequenceAndMove("2252")
	self:OneKnee(duration)
end
function ENT:Stun(duration)
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
	self:snd("re2/em6200/foley_long"..math.random(2)..".mp3")
	self:PlaySequenceAndMove("2202")
	self:SetHealthRegen(0)
end

function ENT:ShouldRun()
	return self:HasEnemy() and self.ShotOffHat
end
function ENT:OnMeleeAttack(enemy)
	if !self.CanAttack then return end
	for i = 1, 1000 do self:FaceTowards(enemy) end
	self:PlaySequenceAndMove("300"..math.random(0,3))
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

function ENT:Turn(pos, subs)
	if self:IsDown() then return end
	local direction = self:CalcPosDirection(pos, subs)
	if direction == "W" then
		self:PlaySequenceAndMove("turn_90left")
		self.LastTurn = CurTime()
	elseif direction == "E" then
		self:PlaySequenceAndMove("turn_90right")
		self.LastTurn = CurTime()
	elseif direction == "S" and math.random(2) == 1 then
		self:PlaySequenceAndMove("turn_180left")
		self.LastTurn = CurTime()
	elseif direction == "S" then
		self:PlaySequenceAndMove("turn_180right")
		self.LastTurn = CurTime()
	end
end

function ENT:OnLandOnGround()
	self:CallInCoroutine(function(self, delay)
	if delay > 0.1 then return end
		self:snd("re2/em6200/land.mp3")
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
	self:PlaySequenceAndMove("nzu_intro_fall")
	self:PlaySequenceAndMove("nzu_intro_land")
end

local function combineballcode(self)
	for k,ball in pairs(ents.FindInSphere(self:LocalToWorld(Vector(0,0,75)), 50)) do
		if IsValid(ball) and ball:GetClass() == "prop_combine_ball" then
			local dmg = DamageInfo()
			dmg:SetAttacker(IsValid(ball:GetOwner()) and ball:GetOwner() or ball)
			dmg:SetInflictor(ball)
			dmg:SetDamageType(DMG_BLAST)
			dmg:SetDamage(1)
			
			self:TakeDamageInfo(dmg)
			ball:Fire("explode", 0)
		end
		if IsValid(ball) and ball:GetClass() == "prop_door_rotating" then
			self:DoorCode(ball)
		end
	end
end
function ENT:OnChaseEnemy(enemy)
	combineballcode(self)
end
function ENT:OnPossession() 
	combineballcode(self)
end

-- Damage --

function ENT:OnTakeDamage(dmg)
	if dmg:IsDamageType(DMG_BLAST) then 
		dmg:ScaleDamage(3)
	end
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
		if hitgroup == HITGROUP_RIGHTARM and dmg:GetDamage() > 100 then
			self.CanAttack = false
			self:PlaySequence("g_flinchR")
			self:Timer(65/30, function() self.CanAttack=true end)
		end
		if hitgroup == HITGROUP_LEFTARM and dmg:GetDamage() > 100 then
			self.CanAttack = false
			self:PlaySequence("g_flinchL")
			self:Timer(65/30, function() self.CanAttack=true end)
		end
	end
end
function ENT:AfterTakeDamage(dmg,delay)
	if dmg:IsDamageType(DMG_BLAST) then 
		local flinch = math.random(1,3)
		if flinch == 1 then
			self:snd("re2/em6200/foley"..math.random(3)..".mp3")
			self:PlaySequenceAndMove("9050")
		elseif flinch == 2 then
			self:snd("re2/em6200/foley"..math.random(3)..".mp3")
			self:PlaySequenceAndMove("9060")
		elseif flinch == 3 then
			self:snd("re2/em6200/foley"..math.random(3)..".mp3")
			self:PlaySequenceAndMove("9061")
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

function ENT:OnStartClimbing(ladder, height,down)
	if down then return end
	if not isvector(ladder) then
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
		self:PlaySequenceAndMoveAbsolute("ladder_finish_r")
	else
		self:PlaySequenceAndMoveAbsolute("ladder_finish_l")
	end
end

function ENT:CustomClimbing(climb, height)
	if isvector(climb) then self:FaceTo(climb) else self:FaceTo(climb:GetBottom()) end
	
	self:PlayClimbSequence("drg_climb",height)
end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
