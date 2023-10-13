Config = {}

Config.UseTarget = true                                       -- (true | false)
Config.CommandName = 'resetlicense'                           -- Command to reset a players license meta back to false. (permit | driver | cdl | bike)


Config.PaymentType = 'cash'                                   -- (cash | bank) What account to use for payment

Config.Locations = {  -- Coords and Ped to Spawn
  [1] = {
    pedModel = `s_m_y_cop_01`, 
    coords = vector4(vector4(440.99, -978.85, 30.69, 179.72)),
    blip = {
      showblip = true,
      blipsprite = 313,
      blipscale = 0.7,
      blipcolor = 1,
      label = 'Firearm Test'
    }
  },
}

Config.GiveItem = true                                      -- (true | false) If false then player will have to go to city hall to get the licenses



Config.Amount = {
    ['theoritical'] = 150000,                                     --theoretical test payment amount(If Config.DriversTest = false then the theoritical test will go to the drivers test amount.)
}