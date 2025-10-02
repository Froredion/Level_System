local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuildProfileTemplate = require(ReplicatedStorage.SharedSource.Utilities.Levels.BuildProfileTemplate_ForLevel)

local ProfileTemplate = {}

ProfileTemplate.Leveling = BuildProfileTemplate.GenerateLevelingData()

return ProfileTemplate
