local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local module = {}

---- Controllers
local DataController

---- Config
local LevelingConfig = require(ReplicatedStorage.SharedSource.Datas.LevelingConfig)

---- Utilities
local RebirthHelpers = require(ReplicatedStorage.SharedSource.Utilities.Levels.RebirthHelpers)

---- UI References
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainScreenGui = nil
local levelFrames = {}

---- UI Constants
local UI_CONFIG = {
	ScreenGuiName = "LevelSystemUI",
	MainFrameSize = UDim2.new(0, 350, 0, 250),
	MainFramePosition = UDim2.new(0, 20, 0, 20),
	LevelFrameHeight = 80,
	ProgressBarHeight = 8,
	Colors = {
		Background = Color3.fromRGB(25, 25, 25),
		Frame = Color3.fromRGB(45, 45, 45),
		Text = Color3.fromRGB(255, 255, 255),
		ExpBar = Color3.fromRGB(100, 200, 100),
		ExpBarBG = Color3.fromRGB(50, 50, 50),
		LevelUp = Color3.fromRGB(255, 215, 0),
	},
}

---- Utils

-- Create the main UI structure
function module:BuildMainUI()
	-- Remove existing UI if it exists
	if mainScreenGui then
		mainScreenGui:Destroy()
	end

	-- Create main ScreenGui
	mainScreenGui = Instance.new("ScreenGui")
	mainScreenGui.Name = UI_CONFIG.ScreenGuiName
	mainScreenGui.ResetOnSpawn = false
	mainScreenGui.Parent = playerGui

	-- Create main frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UI_CONFIG.MainFrameSize
	mainFrame.Position = UI_CONFIG.MainFramePosition
	mainFrame.BackgroundColor3 = UI_CONFIG.Colors.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = mainScreenGui

	-- Add corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = mainFrame

	-- Add title icon
	local titleIcon = Instance.new("ImageLabel")
	titleIcon.Name = "TitleIcon"
	titleIcon.Size = UDim2.new(0, 32, 0, 32)
	titleIcon.Position = UDim2.new(0, 8, 0, 4)
	titleIcon.BackgroundTransparency = 1
	titleIcon.Image = "rbxassetid://102080561024780"
	titleIcon.ScaleType = Enum.ScaleType.Fit
	titleIcon.Parent = mainFrame

	-- Add title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(0.7, -40, 0, 40)
	titleLabel.Position = UDim2.new(0, 45, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Character Levels"
	titleLabel.TextColor3 = UI_CONFIG.Colors.Text
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.Parent = mainFrame

	-- Add close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 35, 0, 35)
	closeButton.Position = UDim2.new(1, -40, 0, 2.5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "X"
	closeButton.TextColor3 = UI_CONFIG.Colors.Text
	closeButton.TextSize = 20
	closeButton.Font = Enum.Font.SourceSansBold
	closeButton.Parent = mainFrame

	-- Add corner radius to close button
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeButton

	-- Add hover effect to close button
	local originalCloseColor = closeButton.BackgroundColor3
	local hoverCloseColor = Color3.fromRGB(230, 70, 70)

	closeButton.MouseEnter:Connect(function()
		closeButton.BackgroundColor3 = hoverCloseColor
	end)

	closeButton.MouseLeave:Connect(function()
		closeButton.BackgroundColor3 = originalCloseColor
	end)

	-- Close button functionality
	closeButton.MouseButton1Click:Connect(function()
		mainScreenGui.Enabled = false
	end)

	-- No global rebirth button - each level type will have its own

	-- Create scroll frame for level displays
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "LevelScrollFrame"
	scrollFrame.Size = UDim2.new(1, -20, 1, -60)
	scrollFrame.Position = UDim2.new(0, 10, 0, 50)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = mainFrame

	-- Add UIListLayout to scroll frame
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.Name
	listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = scrollFrame

	-- Update canvas size when content changes
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
	end)

	-- Build individual level frames
	self:BuildLevelFrames()
end

-- Build individual level display frames
function module:BuildLevelFrames()
	if not mainScreenGui then
		return
	end

	local scrollFrame = mainScreenGui.MainFrame.LevelScrollFrame
	levelFrames = {}

	-- Clear existing frames
	for _, child in pairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") and child.Name:sub(-10) == "LevelFrame" then
			child:Destroy()
		end
	end

	-- Get all level types from config
	local allData = self:_GetLevelController():GetAllLevelData()

	for levelType, data in pairs(allData) do
		local levelFrame = self:CreateLevelFrame(levelType, data)
		levelFrame.Parent = scrollFrame
		levelFrames[levelType] = levelFrame
	end
end

-- Create a single level display frame
function module:CreateLevelFrame(levelType, data)
	local levelFrame = Instance.new("Frame")
	levelFrame.Name = levelType .. "LevelFrame"
	levelFrame.Size = UDim2.new(1, 0, 0, UI_CONFIG.LevelFrameHeight)
	levelFrame.BackgroundColor3 = UI_CONFIG.Colors.Frame
	levelFrame.BorderSizePixel = 0

	-- Add corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = levelFrame

	-- Level type name label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(0, 120, 0, 25)
	nameLabel.Position = UDim2.new(0, 10, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = data.Name or levelType
	nameLabel.TextColor3 = UI_CONFIG.Colors.Text
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextSize = 16
	nameLabel.Parent = levelFrame

	-- Level display label
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelLabel"
	levelLabel.Size = UDim2.new(0, 100, 0, 25)
	levelLabel.Position = UDim2.new(1, -110, 0, 5)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = "Lv. " .. (data.Level or 1)
	levelLabel.TextColor3 = UI_CONFIG.Colors.Text
	levelLabel.TextXAlignment = Enum.TextXAlignment.Right
	levelLabel.Font = Enum.Font.SourceSans
	levelLabel.TextSize = 16
	levelLabel.Parent = levelFrame

	-- Rebirth display label
	local rebirthLabel = Instance.new("TextLabel")
	rebirthLabel.Name = "RebirthLabel"
	rebirthLabel.Size = UDim2.new(0, 150, 0, 20)
	rebirthLabel.Position = UDim2.new(0, 10, 0, 30)
	rebirthLabel.BackgroundTransparency = 1
	rebirthLabel.Text = self:_GetRebirthText(levelType, data)
	rebirthLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	rebirthLabel.TextXAlignment = Enum.TextXAlignment.Left
	rebirthLabel.Font = Enum.Font.SourceSansBold
	rebirthLabel.TextSize = 14
	rebirthLabel.Parent = levelFrame

	-- Experience progress bar background
	local progressBG = Instance.new("Frame")
	progressBG.Name = "ProgressBarBG"
	progressBG.Size = UDim2.new(1, -20, 0, UI_CONFIG.ProgressBarHeight)
	progressBG.Position = UDim2.new(0, 10, 1, -UI_CONFIG.ProgressBarHeight - 18)
	progressBG.BackgroundColor3 = UI_CONFIG.Colors.ExpBarBG
	progressBG.BorderSizePixel = 0
	progressBG.Parent = levelFrame

	-- Progress bar corner
	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(0, 4)
	progressCorner.Parent = progressBG

	-- Experience progress bar
	local progressBar = Instance.new("Frame")
	progressBar.Name = "ProgressBar"
	progressBar.Size = UDim2.new(0, 0, 1, 0)
	progressBar.Position = UDim2.new(0, 0, 0, 0)
	progressBar.BackgroundColor3 = UI_CONFIG.Colors.ExpBar
	progressBar.BorderSizePixel = 0
	progressBar.Parent = progressBG

	-- Progress bar corner
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 4)
	barCorner.Parent = progressBar

	-- Experience text label
	local expLabel = Instance.new("TextLabel")
	expLabel.Name = "ExpLabel"
	expLabel.Size = UDim2.new(0.6, -10, 0, 15)
	expLabel.Position = UDim2.new(0, 10, 1, -33)
	expLabel.BackgroundTransparency = 1
	expLabel.Text = string.format("%d/%d %s", data.Exp or 0, data.MaxExp or 100, data.ExpName or "EXP")
	expLabel.TextColor3 = UI_CONFIG.Colors.Text
	expLabel.TextXAlignment = Enum.TextXAlignment.Left
	expLabel.Font = Enum.Font.SourceSans
	expLabel.TextSize = 12
	expLabel.Parent = levelFrame

	-- Rebirth button for this level type (only show if rebirth is enabled)
	if RebirthHelpers.IsRebirthEnabled(levelType) then
		local rebirthButton = Instance.new("TextButton")
		rebirthButton.Name = "RebirthButton"
		rebirthButton.Size = UDim2.new(0.35, 0, 0, 20)
		rebirthButton.Position = UDim2.new(0.63, 0, 1, -52)
		rebirthButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
		rebirthButton.Text = RebirthHelpers.GetRebirthButtonText(levelType)
		rebirthButton.TextColor3 = Color3.fromRGB(0, 0, 0)
		rebirthButton.TextSize = 11
		rebirthButton.Font = Enum.Font.SourceSansBold
		rebirthButton.Parent = levelFrame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = rebirthButton

		local btnStroke = Instance.new("UIStroke")
		btnStroke.Color = Color3.fromRGB(200, 170, 0)
		btnStroke.Thickness = 1.5
		btnStroke.Parent = rebirthButton

		-- Button click handler - opens rebirth UI for this specific level type
		rebirthButton.MouseButton1Click:Connect(function()
			local LevelController = self:_GetLevelController()
			if LevelController then
				LevelController:ShowRebirthUI(levelType)
			end
		end)
	end

	return levelFrame
end

-- Update all level displays
function module:UpdateAllDisplays()
	if not mainScreenGui then
		return
	end

	local allData = self:_GetLevelController():GetAllLevelData()

	for levelType, data in pairs(allData) do
		if levelFrames[levelType] then
			self:UpdateLevelDisplay(levelType, data)
		else
			-- Create new frame if it doesn't exist
			local scrollFrame = mainScreenGui.MainFrame.LevelScrollFrame
			local newFrame = self:CreateLevelFrame(levelType, data)
			newFrame.Parent = scrollFrame
			levelFrames[levelType] = newFrame
		end
	end
end

-- Update a specific level display
function module:UpdateLevelDisplay(levelType, data)
	local levelFrame = levelFrames[levelType]
	if not levelFrame then
		return
	end

	-- Update level label
	local levelLabel = levelFrame:FindFirstChild("LevelLabel")
	if levelLabel then
		local formattedLevel = self:_GetLevelController().GetComponent:GetFormattedLevel(levelType)
		levelLabel.Text = "Lv. " .. formattedLevel
	end

	-- Update rebirth label
	local rebirthLabel = levelFrame:FindFirstChild("RebirthLabel")
	if rebirthLabel then
		rebirthLabel.Text = self:_GetRebirthText(levelType, data)
	end

	-- Update exp label
	local expLabel = levelFrame:FindFirstChild("ExpLabel")
	if expLabel then
		local formattedExp = self:_GetLevelController().GetComponent:GetFormattedExp(levelType)
		expLabel.Text = formattedExp
	end

	-- Update progress bar
	local progressBar = levelFrame:FindFirstChild("ProgressBarBG"):FindFirstChild("ProgressBar")
	if progressBar then
		local progress = self:_GetLevelController().GetComponent:GetProgressPercent(levelType)

		-- Animate progress bar
		local tween = TweenService:Create(
			progressBar,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.new(progress, 0, 1, 0) }
		)
		tween:Play()
	end
end

-- Show level up effect
function module:ShowLevelUpEffect(levelType, newLevel)
	local levelFrame = levelFrames[levelType]
	if not levelFrame then
		return
	end

	-- Create level up notification
	local notification = Instance.new("TextLabel")
	notification.Name = "LevelUpNotification"
	notification.Size = UDim2.new(1, 0, 1, 0)
	notification.Position = UDim2.new(0, 0, 0, 0)
	notification.BackgroundColor3 = UI_CONFIG.Colors.LevelUp
	notification.BackgroundTransparency = 0.2
	notification.Text = "LEVEL UP!"
	notification.TextColor3 = Color3.fromRGB(0, 0, 0)
	notification.TextScaled = true
	notification.Font = Enum.Font.SourceSansBold
	notification.Parent = levelFrame

	-- Add corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = notification

	-- Animate level up effect
	notification.BackgroundTransparency = 1
	notification.TextTransparency = 1

	local showTween = TweenService:Create(
		notification,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.2, TextTransparency = 0 }
	)

	local hideTween = TweenService:Create(
		notification,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ BackgroundTransparency = 1, TextTransparency = 1 }
	)

	showTween:Play()
	showTween.Completed:Connect(function()
		task.wait(1)
		hideTween:Play()
		hideTween.Completed:Connect(function()
			notification:Destroy()
		end)
	end)

	-- Flash the level frame
	local originalColor = levelFrame.BackgroundColor3
	local flashTween = TweenService:Create(
		levelFrame,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true),
		{ BackgroundColor3 = UI_CONFIG.Colors.LevelUp }
	)

	flashTween:Play()
	flashTween.Completed:Connect(function()
		levelFrame.BackgroundColor3 = originalColor
	end)
end

-- Toggle UI visibility
function module:ToggleUI()
	if mainScreenGui then
		mainScreenGui.Enabled = not mainScreenGui.Enabled
	end
end

-- Helper to get rebirth text
function module:_GetRebirthText(levelType, data)
	local displayName = RebirthHelpers.GetRebirthDisplayName(levelType)
	if displayName == "" then
		return ""
	end
	local rebirthCount = data.Rebirths or 0
	return string.format("⭐ %s: %d", displayName, rebirthCount)
end

-- Helper to get LevelController reference
function module:_GetLevelController()
	return Knit.GetController("LevelController")
end

function module.Start()
	-- No-op
end

function module.Init()
	DataController = Knit.GetController("DataController")
end

return module
