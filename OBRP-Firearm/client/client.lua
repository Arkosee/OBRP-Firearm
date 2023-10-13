QBCore = exports['qb-core']:GetCoreObject()

-------------
-- Variables --
------------
local CurrentTest = nil
local drivingTest = false
local LastCheckPoint = -1
local CurrentCheckPoint = 0

local PlayerData = QBCore.Functions.GetPlayerData()
local pedSpawned = false
local ped = {}
local listen = false



---------------------------------------
            -- FUNCTIONS --
---------------------------------------
local function createBlips()
  if pedSpawned then return end
  for k, v in pairs(Config.Locations) do
    if v.blip.showblip then
      local DMVBlip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
      SetBlipSprite(DMVBlip, v.blip.blipsprite)
      SetBlipScale(DMVBlip, v.blip.blipscale)
      SetBlipDisplay(DMVBlip, 4)
      SetBlipColour(DMVBlip, v.blip.blipcolor)
      SetBlipAsShortRange(DMVBlip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentSubstringPlayerName(v.blip.label)
      EndTextCommandSetBlipName(DMVBlip)
    end
  end
end


local function createPeds()
  if pedSpawned then return end

  for k, v in pairs(Config.Locations) do
    local current = type(v.pedModel) == 'number' and v.pedModel or joaat(v.pedModel)

    RequestModel(current)
    while not HasModelLoaded(current) do
      Wait(0)
    end

    ped[k] = CreatePed(0, current, v.coords.x, v.coords.y, v.coords.z-1, v.coords.w, false, false)
    TaskStartScenarioInPlace(ped[k], v.scenario, 0, true)
    FreezeEntityPosition(ped[k], v.freezePed)
    SetEntityInvincible(ped[k], v.invinciblePed)
    SetBlockingOfNonTemporaryEvents(ped[k], true)

    if Config.UseTarget then
      exports['qb-target']:AddTargetEntity(ped[k], {
        options = {
          {
            label = 'Take Firearm Test',
            icon = 'fa-solid fa-gun',
            action = function ()
              OpenMenu()
            end,
          }
        },
        distance = 2.5
      })
    end
  end
  pedSpawned = true
end

local function deletePeds()
  if not pedSpawned then return end

  for _, v in pairs(ped) do
    DeletePed(v)
  end
  pedSpawned = false
end

function OpenMenu()
  local DMV = {
    {
      header = 'Firearm Training',
      isMenuHeader = true,
    },
    {
      icon = 'fas fa-circle-xmark',
      header = '', txt = 'Close',
      params = {
        event = '',
      },
    },
  }

  if not PlayerData.metadata['licences']['weapon'] then

    DMV[#DMV+1] = {
      header = 'Start Theoritical Test',
      icon = 'fa-solid fa-clipboard-question',
      txt = '$'..Config.Amount['theoritical'],
      params = {
        event = 'OBRP-Firearm:client:StartQuiz',
        args = {
          CurrentTest = 'theoritical'
        }
      }
    }
  end

  exports['qb-menu']:openMenu(DMV)
end

function DrawMissionText(msg, time)
  ClearPrints()
  SetTextEntry_2('STRING')
  AddTextComponentString(msg)
  DrawSubtitleTimed(time, 1)
end

function SetCurrentZoneType(type)
  CurrentZoneType = type
end

function StopTheoryTest(success) 
  CurrentTest = nil
  SendNUIMessage({
    openQuestion = false
  })
  SetNuiFocus(false)
  TriggerServerEvent('OBRP-Firearm:server:TheoryTestResult', success)
end

---------------------------------------
            -- PLAYER EVENTS --
---------------------------------------

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function ()
  PlayerData = QBCore.Functions.GetPlayerData()
  createPeds()
  createBlips()
end)

RegisterNetEvent('QBCore:Client:OnPlyaerUnload', function ()
  deletePeds()
  PlayerData = nil
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function (val)
  PlayerData = val
end)

AddEventHandler('onResourceStart', function (resourceName)
  if GetCurrentResourceName() ~= resourceName then return end
  createBlips()
  createPeds()
end)

AddEventHandler('onResourceStop', function (resourceName)
  if GetCurrentResourceName() ~= resourceName then return end
  deletePeds()
end)

---------------------------------------
            -- NUI Callbacks --
---------------------------------------
RegisterNUICallback('question', function(data, cb)
    SendNUIMessage({
      openSection = 'question'
    })
    cb()
end)

RegisterNUICallback('close', function(data, cb)
    StopTheoryTest(true)
    cb()
end)

RegisterNUICallback('kick', function(data, cb)
    StopTheoryTest(false)
    cb()
end)

---------------------------------------
            -- EVENTS --
---------------------------------------

RegisterNetEvent('OBRP-Firearm:client:StartQuiz', function ()
  
  if PlayerData.money[Config.PaymentType] < Config.Amount['theoritical'] then
    QBCore.Functions.Notify('Not Enough Money in '..Config.PaymentType)
    return
  end
  
  SendNUIMessage({
    Wait(10),
    openQuestion = true
  })

  SetTimeout(200, function ()
      SetNuiFocus(true, true)
  end)
end)