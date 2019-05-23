
AddCSLuaFile()
ENT.Type = "nextbot"
----------------------------------------------
local class = "npc_roach_iv04_drg_tyrant_mrx"
ENT.Base     = "base_nextbot"
ENT.Spawnable= true
ENT.Category = "nZombies Unlimited"
ENT.Author = "Roach"

list.Set("NPC", class, {
	Name = "Mr. X V2",
	Class = class,
	Category = "RE2 Nextbots"
})
if CLIENT then
	language.Add(class,"Mr. X")
end

-- Essentials --
ENT.Model = "models/roach/re2/tyrant_v6.mdl"
ENT.health = 500000
ENT.AllyNPCTable = {
	"npc_zombie"
}

ENT.FieldOfView = 150 -- sight field of view
ENT.KeepChasing = 30 -- how many seconds after having lost a player

if SERVER then

	local MrX_LIST = {}

	-- Misc --

	function ENT:rnd(a)
		return math.random(1,a)
	end
	function ENT:snd(a,b)
		timer.Simple(b,function()
			if !IsValid(self) then return end
			self:EmitSound(a)
			self:EmitSound("re2/em6200/foley_long"..self:rnd(2)..".mp3")
		end)
	end

	-- Init --

	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetMaxHealth(self.health)
		self:SetHealth(self.health)
		self:SetCollisionBounds(Vector(-15, -15, 0), Vector(15, 15, 80))
		for i=3, 117 do self:ManipulateBoneJiggle(i, 1) end
		self.SightMemory = {}
		self.LastTurn = -1
		table.insert(MrX_LIST, self)
	end

	function ENT:OnRemove()
		table.RemoveByValue(MrX_LIST, self)
	end

	function ENT:Think()
		self:RefreshTarget()
		self:NextThink(0.5)
		return true
	end

	function ENT:RunBehaviour()
		self:OnSpawn()
		while true do
			if IsValid(self.Target) then
				self:ChaseTarget()
			else
				self:Patrol()
			end
			coroutine.yield()
		end
	end

	-- Targetting --

	function ENT:GetTarget()
		return self.Target
	end
	function ENT:HaveTarget()
		return IsValid(self.Target)
	end

	function ENT:RefreshTarget()
		self.Target = self:FindClosestTarget()
	end

	function ENT:FindClosestTarget()
		if GetConVar("ai_ignoreplayers"):GetBool() then return nil end
		local players = player.GetAll()
		table.sort(players, function(ply1, ply2)
			return self:GetRangeSquaredTo(ply1) > self:GetRangeSquaredTo(ply2)
		end)
		local target
		for i, ply in ipairs(players) do
			if not ply:Alive() then continue end
			local memory = self:HasInMemory(ply)
			local IsInSight = self:IsInSight(ply)
			if not memory and not IsInSight then continue end
			if IsInSight then self:AddToMemory(ply) end
			target = ply
		end
		return target
	end

	-- Chase target --

	function ENT:ChaseTarget()
		print("mr x chasing target")
		local path = Path("Follow")
		path:SetGoalTolerance(20)
		path:SetMinLookAheadDistance(300)
		while self:HaveTarget() do
			--[[self:ResetSequence("0500")
			self.loco:SetDesiredSpeed(155)]]
			self:ResetSequence("0200")
			self.loco:SetDesiredSpeed(105)
			path:Compute(self, self.Target:GetPos())
			self:UpdatePath(path)
			if self:GetRangeSquaredTo(self.Target) < 50^2 then
				self:Attack()
			end
			coroutine.yield()
		end
	end

	-- Patrolling --

	function ENT:Patrol()
		print("mr x starting to patrol")
		while not self:HaveTarget() do
			self:Investigate()
			coroutine.yield()
		end
	end

	function ENT:Investigate()
		print("mr x investigating to new pos")
		local ply = player.GetAll()[math.random(1,#player.GetAll())]
		local pos = ply:GetPos() + Vector(math.random(-1, 1)*1000, math.random(-1, 1)*1000, 0)
		pos = navmesh.GetNearestNavArea(pos):GetClosestPointOnArea(pos)
		if pos == nil then return self:Investigate() end
		local path = Path("Follow")
		path:SetGoalTolerance(20)
		path:SetMinLookAheadDistance(300)
		local success = path:Compute(self, pos)
		while IsValid(path) do
			if self:HaveTarget() then return end
			self:ResetSequence("0200")
			self.loco:SetDesiredSpeed(105)
			self:UpdatePath(path)
			if not success and path:GetCurrentGoal().distanceFromStart == path:LastSegment().distanceFromStart then break
			else coroutine.yield() end
		end
		self:Idle()
	end

	function ENT:Idle()
		print("mr x idles")
		self:ResetSequence("0000")
		local delay = CurTime() + 5
		while CurTime() < delay and not self:HaveTarget() do
			coroutine.yield()
		end
	end

	-- Memory --

	function ENT:AddToMemory(ent)
		self.SightMemory[ent:GetCreationID()] = CurTime()
	end

	function ENT:HasInMemory(ent)
		if self.SightMemory[ent:GetCreationID()] == nil then return false end
		return CurTime() < self.SightMemory[ent:GetCreationID()] + self.KeepChasing -- Mr x will keep chasing you 5 seconds after he lost visual contact
	end

	-- Sight --

	function ENT:IsInSight(ent)
		if not self:Visible(ent) then return false end
		local pos, ang = self:GetBonePosition(179)
		local deg = math.deg(math.acos((self:GetPos()+self:GetForward()-pos):GetNormalized():Dot((ent:WorldSpaceCenter()-pos):GetNormalized())))
		return deg <= self.FieldOfView/2
	end

	-- Hearing --

	function ENT:HeardSound(ply, sound)
		-- ply is the player that made a sound, sound is the sound table, return true if mr x heard the sound
	end

	hook.Add("EntityEmitSound", "MrXNextbotOnSound", function(sound)
		if not IsValid(sound.Entity) or not sound.Entity:IsPlayer() then return end
		for i, ent in ipairs(MrX_LIST) do
			if ent:HeardSound(sound.Entity, sound) then ent:AddToMemory(sound.Entity) end
		end
	end)

	-- Attack --

	function ENT:Helper_Attack(victim,delay,sequence,damage,damageradius,hitsound)
		local v = victim

		if (IsValid(v) and (v:IsPlayer() && v:Alive())) then
			if not (v:IsValid() && v:Health() > 0) then return end
			timer.Simple(delay,function()
				if !IsValid(self) then return end
				if !IsValid(v) then return end
				for k,ent in pairs(ents.FindInSphere(self:LocalToWorld(Vector(damageradius,0,0)),damageradius)) do
					if table.HasValue(self.AllyNPCTable,ent:GetClass()) then
						ent:TakeDamage(10000,self)
						if IsValid(self) then
							self:EmitSound(hitsound)
							self.CanTaunt = true
						end
					end
				end
				if self:GetRangeTo(v:GetPos()) > damageradius then return end
				self:EmitSound(hitsound)
				v:TakeDamage(damage,self)
				v:ViewPunch(Angle(-300,0,0))
				if math.random(1,5) <= 3 then
					self.CanTaunt = true
				end
				--
			end)
			if sequence != "" then
				self:PlaySequenceAndWait(sequence)
				--[[if self:ShouldTurn() then
					self:Turn()
				end]]
			end
		end
	end

	function ENT:Attack()
		print("mr x attack")
		local v = self.Target
		if not IsValid(v) then return end
		for i = 1, 1000 do self.loco:FaceTowards(v:GetPos()) end
		local rm = math.random(1,4)
		if rm == 1 then
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0.1)
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0.5)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",2.6)
			self:Helper_Attack(v,1,"3000",50,96,"re2/em6200/attack_hit"..self:rnd(5)..".mp3")
		elseif rm == 2 then
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0.1)
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0.5)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",2.8)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",3.2)
			self:Helper_Attack(v,1,"3001",50,96,"re2/em6200/attack_hit"..self:rnd(5)..".mp3")
		elseif rm == 3 then
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0.1)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",2)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",2.4)
			self:Helper_Attack(v,0.6,"3002",30,96,"re2/em6200/attack_hit"..self:rnd(5)..".mp3")
		elseif rm == 4 then
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0.1)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",2)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",2.6)
			self:Helper_Attack(v,0.6,"3003",30,96,"re2/em6200/attack_hit"..self:rnd(5)..".mp3")
		end
		if not IsValid(v) or not v:Alive() then self.SightMemory[v:GetCreationID()] = nil end
		self:RefreshTarget()
		--[[elseif rm == 5 then -- grab
			self.Grab_IsGrabbing = true

			self:SetSequence("ragdoll_grabA")
				self:SetCycle(0)
				self:SetPlaybackRate(1)
				self:ResetSequenceInfo()
			self.loco:SetDesiredSpeed(0)

			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",13/30)
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",13/30)
			timer.Simple(15/30, function()
				if self:GetRangeTo(v:GetPos()) < 100 then
					self.Grab_DidSucceed = true

					self.attachment=ents.Create("obj_ragdoll_attachment_body_mrx")
					self.attachment.model = v:GetModel()
					self.attachment:SetPos(self:GetPos())
					self.attachment:SetParent(self)
					self.attachment:Spawn()
					self:DeleteOnRemove(self.attachment)

					if v:IsPlayer() then
						v:SetPos(self:GetPos() + (self:GetForward()*60) + Vector(0,0,60))
						v:KillSilent()
					else
						SafeRemoveEntity(v)
					end
				end
			end)
			coroutine.wait(17/30)
			if self.Grab_DidSucceed then
				self:snd("physics/body/body_medium_impact_soft"..math.random(5,7)..".wav",0)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",3/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",8/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",15/30)
				self:PlaySequenceAndWait("ragdoll_grabB")
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",8/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",13/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",19/30)
				timer.Simple(27/30,function()
					self:EmitSound("physics/body/body_medium_break"..math.random(2,3)..".wav",511,100)
					ParticleEffectAttach("blood_advisor_puncture",PATTACH_POINT_FOLLOW,self,3)
					for i=1,math.random(5,10) do ParticleEffectAttach("blood_impact_red_01",PATTACH_POINT_FOLLOW,self,3) end
					self.attachment.CanDetach = true
					self.attachment.doll:Fire("fadeandremove",1,10)
					if (v:IsPlayer() and !v:Alive()) then
						v:ScreenFade(SCREENFADE.IN,Color(255,0,0,255),0.3,0.2)
						v:EmitSound("player/pl_pain"..math.random(5,7)..".wav",511,100)
					end
				end)
				self:PlaySequenceAndWait("ragdoll_grabC")
				if self:ShouldTurn() then
					self:Turn()
				end

				self.Grab_DidSucceed = false
				self.Grab_IsGrabbing = false
				self:CustomIdle()
			else
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",6/30)
				coroutine.wait(1)
				self.Grab_IsGrabbing = false
				self:ResetSequence(self.WalkAnim)
				self.loco:SetDesiredSpeed(self.Speed)
			end
		end]]
	end

	-- Turn --

	--[[function ENT:ShouldTurn(pos)
		pos = pos or self:GetTarget():GetPos()
		local turn = false
		local ang1 = self:GetAngles()
		local ang2 = IsValid(self:GetTarget()) and self:GetTarget():GetAngles() or pos:Angle()
		local ydif = math.AngleDifference(ang1.y, ang2.y)
		local seq
		if ydif < 0 then ydif = ydif +360 end
		if ydif <= 45 or ydif >= 315 then
			turn = true
		elseif ydif <= 135 and ydif >= 45 then
			turn = true
		elseif ydif <= 315 and ydif >= 235 then
			turn = true
		end

		if turn == false then
			self.loco:SetDesiredSpeed(self.Speed)
			self:ResetSequence(self.WalkAnim)
		end
		return turn
	end

	function ENT:Turn(pos)
		if self.IsTurning then return end

		self.IsTurning = true
			pos = pos or self:GetTarget():GetPos()
			local ang1 = self:GetAngles()
			local ang2 = IsValid(self:GetTarget()) and self:GetTarget():GetAngles() or pos:Angle()
			local ydif = math.AngleDifference(ang1.y, ang2.y)
			local seq
			if ydif < 0 then ydif = ydif +360 end
			if ydif <= 45 or ydif >= 315 then
				local random = math.random(1,2)
				local seq
				if random == 1 then
					seq = "turn_180left"
				elseif random == 2 then
					seq = "turn_180right"
				end
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",33/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",50/30)
				self:PlaySequenceAndSetAngles(seq)
				self:ResetSequence(self.WalkAnim)
				self.loco:SetDesiredSpeed(self.Speed)
			elseif ydif <= 135 and ydif >= 45 then
				--Left
				seq = "turn_90left"
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",20/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",33/30)
				self:PlaySequenceAndSetAngles(seq)
				self:ResetSequence(self.WalkAnim)
				self.loco:SetDesiredSpeed(self.Speed)
			elseif ydif <= 315 and ydif >= 235 then
				--Right
				seq = "turn_90right"
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",20/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",33/30)
				self:PlaySequenceAndSetAngles(seq)
				self:ResetSequence(self.WalkAnim)
				self.loco:SetDesiredSpeed(self.Speed)
			end
		-- self.Isturning = false
	end]]

	-- OnSpawn --

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
		self:PlaySequenceAndWait("nzu_intro_fall")

		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",18/30)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",33/30)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",40/30)
		self:PlaySequenceAndWait("nzu_intro_land")

		self.CanAttack = true
	end

	-- Custom Update that turns when necessary --

	function ENT:CalcPosDirection(pos)
	  local angle = math.AngleDifference(self:GetAngles().y + 202.5, (pos - self:GetPos()):Angle().y) + 180
	  local direction = "N"
	  if angle > 45 and angle <= 90 then direction = "NE"
	  elseif angle > 90 and angle <= 135 then direction = "E"
	  elseif angle > 135 and angle <= 180 then direction = "SE"
	  elseif angle > 180 and angle <= 225 then direction = "S"
	  elseif angle > 225 and angle <= 270 then direction = "SW"
	  elseif angle > 270 and angle <= 315 then direction = "W"
	  elseif angle > 315 and angle <= 360 then direction = "NW" end
	  return direction, angle
	end

	function ENT:UpdatePath(path, pos)
		pos = pos or self:GetPos() + path:GetCurrentGoal().forward
		local direction = self:CalcPosDirection(pos)
		if CurTime() > self.LastTurn + 3 and not string.find(direction, "N") then
			if direction == "W" then
				print("mr x turn left 90")
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",20/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",33/30)
				self:PlaySequenceAndSetAngles("turn_90left")
				self.LastTurn = CurTime()
			elseif direction == "E" then
				print("mr x turn right 90")
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",20/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",33/30)
				self:PlaySequenceAndSetAngles("turn_90right")
				self.LastTurn = CurTime()
			elseif direction == "SW" then
				print("mr x turn left 180")
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",33/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",50/30)
				self:PlaySequenceAndSetAngles("turn_180left")
				self.LastTurn = CurTime()
			elseif direction == "SE" then
				print("mr x turn right 180")
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",33/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",50/30)
				self:PlaySequenceAndSetAngles("turn_180right")
				self.LastTurn = CurTime()
			elseif math.random(2) == 1 then return self:UpdatePath(path, self:GetPos() + self:GetRight() - self:GetForward())
			else return self:UpdatePath(path, self:GetPos() - self:GetRight() - self:GetForward()) end
		end
		return path:Update(self)
	end

	function ENT:PlaySequenceAndSetAngles(anim)
		self.loco:SetDesiredSpeed(0)
		self:SetSequence(anim)
		self:SetCycle(0)
		self:SetPlaybackRate(1)
		self:ResetSequenceInfo()
			local seq,dur = self:LookupSequence(anim)
			local ga,gb,gc = self:GetSequenceMovement(seq,0,1)
			if not ga then print("ga failed") return end -- The animation has no locomotion or it's invalid or we failed in some other way.

			local ang = self:GetAngles()
			local gd_prev = 0

			for i=1,dur*100 do
				timer.Simple(0.01*i,function()
					if !IsValid(self) then return end
					local gd_cur = self:GetCycle()
					local ga2,gb2,gc2 = self:GetSequenceMovement(seq,gd_prev,gd_cur)
					gd_prev = gd_cur

					if (not ga2) or (gd_cur==0) then return end
					self:SetAngles(self:LocalToWorldAngles(gc2))
				end)
			end
		coroutine.wait(dur)
	end

	-- Detect attacker --

	function ENT:OnInjured(dmg)
		if IsValid(dmg:GetAttacker()) then
			self:AddToMemory(dmg:GetAttacker())
			self:RefreshTarget()
		end
	end

end
