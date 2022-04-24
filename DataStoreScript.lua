----- @九六七
local Players = game:GetService("Players");
local ReplicatedStorage  = game:GetService("ReplicatedStorage");
local ServerScriptService = game:GetService("ServerScriptService");
local ServerStorage = game:GetService("ServerStorage");

local DataService = game:GetService("DataStoreService");
local DataKey = DataService:GetDataStore("player.package.points");
local UpdateRemote = ReplicatedStorage:WaitForChild("RemoteUpdate");
local AutoSave = true

local function DataSetup(Client, DataType)
	if not Client then
		return
	end

	local Success = pcall(function()
		if DataType == "Joined" and not Client:FindFirstChild("Data") then
			local DataFolder = Instance.new("Configuration", Client)
			DataFolder.Name = "Data"
			
			local Points = Instance.new("NumberValue", DataFolder)
			Points.Name = "Points"
			Points.Value = DataKey:GetAsync("data.package-"..Client.UserId.."-points") or 50 -- Starter Points Is 50
			
			while wait(10) do -- Get Points Every 10 Seconds
				Points.Value = Points.Value + 10
				UpdateRemote:FireClient(Client, "update.points", Points.Value)
			end
			
			Points.Value = Points.Value + 10
		end
	
		if DataType == "Leaving" then
			local PcallSave = pcall(function()
				if Client:FindFirstChild("Data") and Client:FindFirstChild("Data"):IsA("Configuration") then
					local Points = Client:FindFirstChild("Data"):WaitForChild("Points")
					DataKey:SetAsync("data.package-"..Client.UserId.."-points", Points.Value)
				end
			end)
			
			if PcallSave then
				Client:FindFirstChild("Data"):Destroy()
			end
		end
	end)
	
	if Sucess then
		--warn("Got his data")
	end
end

local PlayerJoin = function(Client)
	DataSetup(Client, "Joined")
	
	Client.CharacterAdded:Connect(function(Character)
		Character:FindFirstChild("Health"):Destroy()
	end)
end

local PlayerLeft = function(Client)
	DataSetup(Client, "Leaving")
end

Players.PlayerAdded:Connect(PlayerJoin)
Players.PlayerRemoving:Connect(PlayerLeft)