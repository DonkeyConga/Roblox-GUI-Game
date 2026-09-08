--!strict
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local RemoteController = require(script.Parent.RemoteController)
local MainUI = require(script.Parent.UI.MainUI)
local OverheadTitle = require(script.Parent.UI.OverheadTitle)

MainUI.Init(player, RemoteController)
OverheadTitle.Init(Players)
