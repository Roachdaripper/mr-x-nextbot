
AddCSLuaFile()
ENT.Type = "nextbot"
----------------------------------------------
local class = "npc_roach_iv04_tyrant_mrx_bt"
ENT.Base     = "base_nextbot"
ENT.Spawnable= true
ENT.Category = "nZombies Unlimited"
ENT.Author = "Roach"

list.Set("NPC", class, {
	Name = "Mr. X Behaviour Tree",
	Class = class,
	Category = "RE2 Nextbots"
})
if CLIENT then
	language.Add(class,"Mr. X")
end

-- Essentials --
ENT.Model = "models/roach/re2/tyrant_v6.mdl"
ENT.health = 500000

if SERVER then

	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetMaxHealth(self.health)
		self:SetHealth(self.health)
		self:SetCollisionBounds(Vector(-15, -15, 0), Vector(15, 15, 80))
		self.SightMemory = {}
	end

	function ENT:Think()
		self.Target = self:FindClosestTarget()
		self:NextThink(0.5)
		return true
	end

	function ENT:RunBehaviour()
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

	function ENT:FindClosestTarget()
		if GetConVar("ai_ignoreplayers"):GetBool() then return nil end
		local players = player.GetAll()
		table.sort(players, function(ply1, ply2)
			return self:GetRangeSquaredTo(ply1) > self:GetRangeSquaredTo(ply2)
		end)
		local target
		for i, ply in ipairs(players) do
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
		self:ResetSequence("0500")
		self.loco:SetDesiredSpeed(155)
		local path = Path("Follow")
		while IsValid(self.Target) do
			path:Compute(self, self.Target:GetPos())
			path:Update(self)
			coroutine.yield()
		end
	end

	-- Patrolling --

	function ENT:Patrol()
		print("mr x starting to patrol")
		self:ResetSequence("0200")
		self.loco:SetDesiredSpeed(105)
		while not IsValid(self.Target) do
			self:Investigate()
			coroutine.yield()
		end
	end

	function ENT:Investigate()
		print("mr x investigating to new pos")
		local ply = player.GetAll()[math.random(1,#player.GetAll())]
		local pos = ply:GetPos() + Vector(math.random(-1, 1)*1000, math.random(-1, 1)*1000, 0)
		local path = Path("Follow")
		path:Compute(self, pos)
		while IsValid(path) do
			if IsValid(self.Target) then return end
			path:Update(self)
			coroutine.yield()
		end
		self:ResetSequence("0000")
		coroutine.wait(2)
	end

	-- Memory --

	function ENT:AddToMemory(ent)
		self.SightMemory[ent:GetCreationID()] = CurTime()
	end

	function ENT:HasInMemory(ent)
		if self.SightMemory[ent:GetCreationID()] == nil then return false end
		return CurTime() < self.SightMemory[ent:GetCreationID()] + 5 -- Mr x will keep chasing you 5 seconds after he lost visual contact
	end

	function ENT:IsInSight(ent)
		if not self:Visible(ent) then return false end
		local pos, ang = self:GetBonePosition(179)
		local deg = math.deg(math.acos((self:GetPos()+self:GetForward()-pos):GetNormalized():Dot((ent:WorldSpaceCenter()-pos):GetNormalized())))
		return deg <= 75
	end

end
