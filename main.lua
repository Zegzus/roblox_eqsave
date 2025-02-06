local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local dataStore = DataStoreService:GetDataStore("EqDataStore")

local function saveData(player)
	local eqFolder = player:FindFirstChild("eq")

	if eqFolder then
		local data = {}

		for _, item in ipairs(eqFolder:GetChildren()) do
			if item:IsA("IntValue") then
				table.insert(data, {name = item.Name, value = item.Value})
			end
		end

		local jsonData = HttpService:JSONEncode(data)

		local success, errorMessage = pcall(function()
			dataStore:SetAsync(player.UserId .. "_EqData", jsonData)
		end)

	end
end

local function loadData(player)
	local success, result = pcall(function()
		return dataStore:GetAsync(player.UserId .. "_EqData")
	end)

	if success then
		if result then
			local data = HttpService:JSONDecode(result)
			local eqFolder = player:FindFirstChild("eq")

			if eqFolder then
				for _, item in ipairs(data) do
					local intValue = eqFolder:FindFirstChild(item.name)
					if not intValue then
						intValue = Instance.new("IntValue")
						intValue.Name = item.name
						intValue.Parent = eqFolder
					end
					if intValue:IsA("IntValue") then
						intValue.Value = item.value
					end
				end
			end
		end
	end
end

local function ensureEqFolderExists(player)
	local eqFolder = player:FindFirstChild("eq")
	if not eqFolder then
		eqFolder = Instance.new("Folder")
		eqFolder.Name = "eq"
		eqFolder.Parent = player
	end
end

Players.PlayerAdded:Connect(function(player)
	ensureEqFolderExists(player)
	loadData(player)
end)

Players.PlayerRemoving:Connect(function(player)
	saveData(player)
end)
