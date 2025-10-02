-- Level System Tester Parts
-- Creates testing parts in Workspace for server-side level testing
-- Per the original Level System plan

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Wait for Knit to start
repeat
	task.wait()
until Knit.OnStart
Knit.OnStart():await()

-- Get LevelService
local LevelService = Knit.GetService("LevelService")

-- Cooldown tracking (per-player)
local playerCooldowns = {}
local COOLDOWN_TIME = 2 -- seconds

-- Helper function to check cooldown
local function isOnCooldown(player, partName)
	local playerData = playerCooldowns[player.UserId]
	if not playerData then
		playerCooldowns[player.UserId] = {}
		return false
	end

	local lastUse = playerData[partName]
	if not lastUse then
		return false
	end

	return (tick() - lastUse) < COOLDOWN_TIME
end

-- Helper function to set cooldown
local function setCooldown(player, partName)
	if not playerCooldowns[player.UserId] then
		playerCooldowns[player.UserId] = {}
	end
	playerCooldowns[player.UserId][partName] = tick()
end

-- Create tester folder
local testerFolder = workspace:FindFirstChild("LevelSystem_Testers")
if not testerFolder then
	testerFolder = Instance.new("Folder")
	testerFolder.Name = "LevelSystem_Testers"
	testerFolder.Parent = workspace
end

-- Clear existing parts
testerFolder:ClearAllChildren()

-- Tester part configurations
local testerConfigs = {
	-- Row 1 - Basic EXP (z = 0)
	{
		name = "+1_EXP",
		color = Color3.fromRGB(100, 255, 100),
		position = Vector3.new(10, 5, 0),
		action = function(player)
			LevelService:AddExp(player, 1, "levels")
			print(string.format("[LevelTester] %s gained 1 EXP", player.Name))
		end,
	},
	{
		name = "+100_EXP",
		color = Color3.fromRGB(100, 200, 255),
		position = Vector3.new(15, 5, 0),
		action = function(player)
			LevelService:AddExp(player, 100, "levels")
			print(string.format("[LevelTester] %s gained 100 EXP", player.Name))
		end,
	},
	{
		name = "+EnoughToLevel",
		color = Color3.fromRGB(255, 200, 100),
		position = Vector3.new(20, 5, 0),
		action = function(player)
			-- Get current level data to calculate EXP needed
			local levelData = LevelService:GetAllTypesData(player)
			if levelData and levelData.levels then
				local needed = levelData.levels.MaxExp - levelData.levels.Exp + 1
				LevelService:AddExp(player, needed, "levels")
				print(string.format("[LevelTester] %s gained %d EXP (enough to level)", player.Name, needed))
			else
				print(string.format("[LevelTester] Could not get level data for %s", player.Name))
			end
		end,
	},
	{
		name = "-1_EXP",
		color = Color3.fromRGB(255, 100, 100),
		position = Vector3.new(25, 5, 0),
		action = function(player)
			LevelService:LoseExp(player, 1, "levels")
			print(string.format("[LevelTester] %s lost 1 EXP", player.Name))
		end,
	},
	{
		name = "Set_EXP",
		color = Color3.fromRGB(200, 100, 255),
		position = Vector3.new(30, 5, 0),
		action = function(player)
			-- Set to a predefined amount for testing
			local targetExp = 500
			local levelData = LevelService:GetAllTypesData(player)
			if levelData and levelData.levels then
				local currentExp = levelData.levels.Exp
				local expToAdd = targetExp - currentExp
				LevelService:AddExp(player, expToAdd, "levels")
				print(string.format("[LevelTester] Set %s EXP to %d", player.Name, targetExp))
			else
				print(string.format("[LevelTester] Could not get level data for %s", player.Name))
			end
		end,
	},
	-- Row 2 - Other Types (z = 12)
	{
		name = "+50_Honor",
		color = Color3.fromRGB(255, 150, 150),
		position = Vector3.new(10, 5, 12),
		action = function(player)
			LevelService:AddExp(player, 50, "ranks")
			print(string.format("[LevelTester] %s gained 50 Honor", player.Name))
		end,
	},
	{
		name = "+SP_Stages",
		color = Color3.fromRGB(150, 255, 150),
		position = Vector3.new(15, 5, 12),
		action = function(player)
			LevelService:AddExp(player, 75, "stages")
			print(string.format("[LevelTester] %s gained 75 SP", player.Name))
		end,
	},
	{
		name = "+TP_Tiers",
		color = Color3.fromRGB(150, 150, 255),
		position = Vector3.new(20, 5, 12),
		action = function(player)
			LevelService:AddExp(player, 25, "tiers")
			print(string.format("[LevelTester] %s gained 25 TP", player.Name))
		end,
	},
	-- Row 3 - Rebirths (z = 24)
	{
		name = "+1_Rebirth_Levels",
		color = Color3.fromRGB(255, 215, 0),
		position = Vector3.new(10, 5, 24),
		action = function(player)
			LevelService:AddRebirth(player, 1, "levels")
			print(string.format("[LevelTester] %s +1 Rebirth (levels)", player.Name))
		end,
	},
	{
		name = "+1_Ascension_Ranks",
		color = Color3.fromRGB(138, 43, 226),
		position = Vector3.new(15, 5, 24),
		action = function(player)
			LevelService:AddRebirth(player, 1, "ranks")
			print(string.format("[LevelTester] %s +1 Ascension (ranks)", player.Name))
		end,
	},
	{
		name = "Reset_Level_Levels",
		color = Color3.fromRGB(255, 69, 0),
		position = Vector3.new(20, 5, 24),
		action = function(player)
			LevelService:ResetLevel(player, "levels")
			print(string.format("[LevelTester] Reset Level (levels) for %s", player.Name))
		end,
	},
	{
		name = "Set_Rebirth_Count",
		color = Color3.fromRGB(255, 105, 180),
		position = Vector3.new(25, 5, 24),
		action = function(player)
			-- Set to 5 rebirths for testing
			LevelService:SetRebirthCount(player, 5, "levels")
			print(string.format("[LevelTester] Set Rebirth Count to 5 for %s (levels)", player.Name))
		end,
	},
	{
		name = "Perform_Rebirth_Levels",
		color = Color3.fromRGB(0, 255, 255),
		position = Vector3.new(30, 5, 24),
		action = function(player)
			-- Perform rebirth (checks eligibility automatically)
			local success, message = LevelService:PerformRebirth(player, "levels")
			if success then
				print(string.format("[LevelTester] %s successfully rebirthed! %s", player.Name, message))
			else
				warn(string.format("[LevelTester] %s failed to rebirth: %s", player.Name, message))
			end
		end,
	},
	{
		name = "Set_Max_Level_Levels",
		color = Color3.fromRGB(255, 0, 255),
		position = Vector3.new(35, 5, 24),
		action = function(player)
			-- Set level to max (100 for levels) for rebirth testing
			local levelData = LevelService:GetAllTypesData(player)
			if levelData and levelData.levels then
				-- Get config to find max level
				local LevelingConfig = require(ReplicatedStorage.SharedSource.Datas.LevelingConfig)
				local maxLevel = LevelingConfig.Types.levels.MaxLevel or 100
				-- Calculate EXP needed to reach max level
				local currentLevel = levelData.levels.Level
				if currentLevel < maxLevel then
					-- Add enough EXP to level up to max
					for i = currentLevel, maxLevel - 1 do
						local data = LevelService:GetAllTypesData(player)
						if data and data.levels then
							local needed = data.levels.MaxExp - data.levels.Exp + 1
							LevelService:AddExp(player, needed, "levels")
						end
					end
					print(string.format("[LevelTester] Set %s to max level %d (levels)", player.Name, maxLevel))
				else
					print(string.format("[LevelTester] %s already at max level (levels)", player.Name))
				end
			end
		end,
	},
	-- Row 4 - Max Level Setters (z = 36)
	{
		name = "MAX_Level_Levels",
		color = Color3.fromRGB(255, 0, 0),
		position = Vector3.new(10, 5, 36),
		action = function(player)
			local LevelingConfig = require(ReplicatedStorage.SharedSource.Datas.LevelingConfig)
			local maxLevel = LevelingConfig.Types.levels.MaxLevel or 100
			LevelService:SetLevel(player, maxLevel, "levels")
			print(string.format("[LevelTester] Set %s to MAX level %d (levels)", player.Name, maxLevel))
		end,
	},
	{
		name = "MAX_Level_Ranks",
		color = Color3.fromRGB(255, 100, 0),
		position = Vector3.new(15, 5, 36),
		action = function(player)
			local LevelingConfig = require(ReplicatedStorage.SharedSource.Datas.LevelingConfig)
			local maxLevel = LevelingConfig.Types.ranks.MaxLevel or 50
			LevelService:SetLevel(player, maxLevel, "ranks")
			print(string.format("[LevelTester] Set %s to MAX level %d (ranks)", player.Name, maxLevel))
		end,
	},
	{
		name = "MAX_Level_Stages",
		color = Color3.fromRGB(0, 255, 0),
		position = Vector3.new(20, 5, 36),
		action = function(player)
			local LevelingConfig = require(ReplicatedStorage.SharedSource.Datas.LevelingConfig)
			local maxLevel = LevelingConfig.Types.stages.MaxLevel or 75
			LevelService:SetLevel(player, maxLevel, "stages")
			print(string.format("[LevelTester] Set %s to MAX level %d (stages)", player.Name, maxLevel))
		end,
	},
	{
		name = "MAX_Level_Tiers",
		color = Color3.fromRGB(0, 100, 255),
		position = Vector3.new(25, 5, 36),
		action = function(player)
			local LevelingConfig = require(ReplicatedStorage.SharedSource.Datas.LevelingConfig)
			local maxLevel = LevelingConfig.Types.tiers.MaxLevel or 60
			LevelService:SetLevel(player, maxLevel, "tiers")
			print(string.format("[LevelTester] Set %s to MAX level %d (tiers)", player.Name, maxLevel))
		end,
	},
	-- Row 5 - MaxRebirth Testing (z = 48)
	{
		name = "Set_MaxRebirth_Levels",
		color = Color3.fromRGB(255, 215, 0),
		position = Vector3.new(10, 5, 48),
		action = function(player)
			-- Set rebirth count to max (10 for levels)
			local LevelingConfig = require(ReplicatedStorage.SharedSource.Datas.LevelingConfig)
			local maxRebirth = LevelingConfig.Types.levels.MaxRebirth or 10
			LevelService:SetRebirthCount(player, maxRebirth, "levels")
			print(string.format("[LevelTester] Set %s rebirth count to MAX %d (levels)", player.Name, maxRebirth))
		end,
	},
	{
		name = "Try_Add_Rebirth_AtMax",
		color = Color3.fromRGB(255, 69, 0),
		position = Vector3.new(15, 5, 48),
		action = function(player)
			-- Try to add rebirth when already at max (should fail)
			local success = LevelService:AddRebirth(player, 1, "levels")
			if success then
				print(string.format("[LevelTester] Successfully added rebirth to %s (levels)", player.Name))
			else
				print(string.format("[LevelTester] Failed to add rebirth to %s - at max limit (levels)", player.Name))
			end
		end,
	},
	{
		name = "Set_MaxRebirth_Ranks",
		color = Color3.fromRGB(138, 43, 226),
		position = Vector3.new(20, 5, 48),
		action = function(player)
			-- Set ascension count to max (5 for ranks)
			local LevelingConfig = require(ReplicatedStorage.SharedSource.Datas.LevelingConfig)
			local maxRebirth = LevelingConfig.Types.ranks.MaxRebirth or 5
			LevelService:SetRebirthCount(player, maxRebirth, "ranks")
			print(string.format("[LevelTester] Set %s ascension count to MAX %d (ranks)", player.Name, maxRebirth))
		end,
	},
	{
		name = "Try_Rebirth_AtMax",
		color = Color3.fromRGB(255, 0, 0),
		position = Vector3.new(25, 5, 48),
		action = function(player)
			-- Try to rebirth when at max (should fail)
			local canRebirth = LevelService:CanRebirth(player, "levels")
			if canRebirth then
				print(string.format("[LevelTester] %s CAN rebirth (levels)", player.Name))
			else
				print(
					string.format("[LevelTester] %s CANNOT rebirth - at max or not at max level (levels)", player.Name)
				)
			end
		end,
	},
	{
		name = "Try_Set_Beyond_Max",
		color = Color3.fromRGB(255, 105, 180),
		position = Vector3.new(30, 5, 48),
		action = function(player)
			-- Try to set rebirth count beyond max (should cap at max)
			LevelService:SetRebirthCount(player, 999, "levels")
			print(
				string.format(
					"[LevelTester] Attempted to set %s rebirth to 999 (should cap at max) (levels)",
					player.Name
				)
			)
		end,
	},
	{
		name = "Check_Rebirth_Info",
		color = Color3.fromRGB(0, 255, 255),
		position = Vector3.new(35, 5, 48),
		action = function(player)
			-- Display current rebirth count and max for all types
			local LevelingConfig = require(ReplicatedStorage.SharedSource.Datas.LevelingConfig)
			local levelData = LevelService:GetAllTypesData(player)
			if levelData then
				print(string.format("=== [LevelTester] Rebirth Info for %s ===", player.Name))
				for typeName, typeData in pairs(levelData) do
					local typeCfg = LevelingConfig.Types[typeName]
					if typeCfg then
						local maxRebirth = typeCfg.MaxRebirth or "Unlimited"
						local currentRebirths = typeData.Rebirths or 0
						print(string.format("  %s: %d / %s rebirths", typeName, currentRebirths, tostring(maxRebirth)))
					end
				end
				print("=================================")
			end
		end,
	},
}

-- Create tester parts
for _, config in pairs(testerConfigs) do
	local part = Instance.new("Part")
	part.Name = config.name
	part.Size = Vector3.new(4, 6, 4)
	part.Position = config.position
	part.Color = config.color
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = true
	part.Parent = testerFolder

	-- Add a text label above the part
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 200, 0, 50)
	billboardGui.AlwaysOnTop = true
	billboardGui.Adornee = part
	billboardGui.Parent = part

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = config.name
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = 18
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.Parent = billboardGui

	-- Touch detection
	local connection
	connection = part.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				-- Check cooldown
				if isOnCooldown(player, config.name) then
					return
				end

				-- Set cooldown
				setCooldown(player, config.name)

				-- Execute action
				local success, err = pcall(config.action, player)
				if not success then
					print(string.format("[LevelTester] Error with %s: %s", config.name, err))
				end
			end
		end
	end)
end

-- Create instruction sign
local signPart = Instance.new("Part")
signPart.Name = "Instructions"
signPart.Size = Vector3.new(8, 6, 1)
signPart.Position = Vector3.new(0, 5, 18)
signPart.Color = Color3.fromRGB(100, 100, 100)
signPart.Material = Enum.Material.Concrete
signPart.Anchored = true
signPart.CanCollide = false
signPart.Parent = testerFolder

local signGui = Instance.new("SurfaceGui")
signGui.Face = Enum.NormalId.Front
signGui.Parent = signPart

local instructionLabel = Instance.new("TextLabel")
instructionLabel.Size = UDim2.new(1, 0, 1, 0)
instructionLabel.BackgroundTransparency = 1
instructionLabel.Text = [[🎯 LEVEL SYSTEM TESTERS

Row 1 - Basic EXP (levels):
• Green: +1 EXP
• Blue: +100 EXP  
• Orange: Level up amount
• Red: -1 EXP
• Purple: Set EXP to 500

Row 2 - Other Types:
• Pink: +50 Honor (ranks)
• Light Green: +75 SP (stages)
• Light Blue: +25 TP (tiers)

Row 3 - Rebirths:
• Gold: +1 Rebirth (levels)
• Purple: +1 Ascension (ranks)
• Orange-Red: Reset Level (levels)
• Pink: Set Rebirth to 5 (levels)
• Cyan: Perform Rebirth (levels)
• Magenta: Set to Max Level

Row 4 - Max Level Setters:
• Red: MAX Level (levels → 100)
• Orange: MAX Level (ranks → 50)
• Green: MAX Level (stages → 75)
• Blue: MAX Level (tiers → 60)

Row 5 - MaxRebirth Testing:
• Gold: Set MaxRebirth (levels → 10)
• Orange-Red: Try Add at Max
• Purple: Set MaxRebirth (ranks → 5)
• Red: Check Can Rebirth
• Pink: Try Set Beyond Max (999)
• Cyan: Display Rebirth Info

2 second cooldown per player]]

instructionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
instructionLabel.TextScaled = true
instructionLabel.Font = Enum.Font.SourceSans
instructionLabel.TextWrapped = true
instructionLabel.Parent = signGui

print("[LevelTester] Level System tester parts created in Workspace/LevelSystem_Testers")
print("[LevelTester] Touch the parts to test level functionality!")

-- Clean up cooldowns when players leave
Players.PlayerRemoving:Connect(function(player)
	playerCooldowns[player.UserId] = nil
end)
