-- Source control: group
-- File: TEEE-EMMEDIA.tosc

-- Source control: group
-- File: TEEE-EMMEDIA.tosc

-- Source control: group
-- File: TEEE-EMMEDIA.tosc

-- CONFIG
local alphaOff = 0.0
local alphaSet = 0.6
local baseColors = {}

-- Preset colors for toggles
local presetColors = {
  yellow = { r = 1.0, g = 0.9, b = 0.0 },
  red = { r = 1.0, g = 0.2, b = 0.2 },
  green = { r = 0.2, g = 1.0, b = 0.2 },
  violet = { r = 0.8, g = 0.0, b = 1.0 }, blue = { r = 0.0, g = 0.7, b = 1.0 }
}

function findControl(name)
  return searchChildren(root, name)
end

function searchChildren(parent, name)
  for i = 1, #parent.children do
    local child = parent.children[i]
    if child.name == name then
      return child
    end
    if #child.children > 0 then
      local found = searchChildren(child, name)
      if found then return found end
    end
  end
  return nil
end

function handleFeedback(prefix, num, deck, val)
  local baseName = prefix .. deck .. '_' .. num
  local shapeName = baseName .. '_bg'
  
--  print('[handleFeedback] prefix=' .. prefix .. ' num=' .. num .. ' deck=' .. deck .. ' val=' .. val)
--  print('[handleFeedback] Looking for shape: ' .. shapeName)
  
  local shape = findControl(shapeName)
  
  if shape then
    print('[handleFeedback] FOUND shape: ' .. shapeName)
    
    if not baseColors[baseName] then
      local btn = findControl(baseName)
      if btn then
        local c = btn.properties.color
        baseColors[baseName] = { r = c.r, g = c.g, b = c.b }
--        print('[handleFeedback] Cached color from: ' .. baseName)
      else
        print('[handleFeedback] WARNING: Button not found: ' .. baseName)
      end
    end
    
    local bc = baseColors[baseName]
    if bc then
      local newAlpha = val == 127 and alphaSet or alphaOff
--      print('[handleFeedback] Setting alpha=' .. newAlpha .. ' for ' .. shapeName)
      shape.properties.color = Color(bc.r, bc.g, bc.b, newAlpha)
    else
--      print('[handleFeedback] WARNING: No cached color for ' .. baseName)
    end
  else
--    print('[handleFeedback] NOT FOUND shape: ' .. shapeName)
  end
end

function handleToggleFeedback(num, deck, val)
  local baseName = 'toggle_' .. deck .. '_' .. num
  print('feedback ' .. baseName)
  
  for colorName, rgb in pairs(presetColors) do
    local shapeName = baseName .. '_' .. colorName .. '_bg'
    local shape = findControl(shapeName)
    if shape then
      print('shapeName ' .. shapeName)
      shape.properties.color = Color(rgb.r, rgb.g, rgb.b, val == 127 and alphaSet or alphaOff)
    else 
--      print('shapeName not found ' .. shapeName)
    end
  end
end

function onReceiveMIDI(message)
  local msgType = math.floor(message[1] / 16) * 16
  local channel = (message[1] % 16) + 1
  local cc  = message[2]
  local val = message[3]

  print('[MIDI] ch=' .. channel .. ' cc=' .. cc .. ' val=' .. val)

  if msgType == 0xB0 and (channel == 15 or channel == 16) then
    local deck = channel == 15 and 1 or 2

--    print('[onReceiveMIDI] MATCHED: cc=' .. cc .. ' val=' .. val .. ' deck=' .. deck)

    -- Cues: CC 81-88
    if cc >= 81 and cc <= 88 then
--      print('[onReceiveMIDI] CUE triggered')
      handleFeedback('cue_', cc - 80, deck, val)
    end

    -- Loops: CC 91-98
    if cc >= 91 and cc <= 98 then
--      print('[onReceiveMIDI] LOOP triggered')
      handleFeedback('loop_', cc - 90, deck, val)
    end

    -- Toggles
    handleToggleFeedback(cc, deck, val)
  end
end




function initializeBackgrounds()
  print('[initializeBackgrounds] Clearing all cue and loop backgrounds...')
  
  for deck = 1, 2 do
    -- Clear cues (1-8)
    for num = 1, 8 do
      local cueName = 'cue_' .. deck .. '_' .. num .. '_bg'
      local cueShape = findControl(cueName)
      if cueShape then
        local c = cueShape.properties.color
        cueShape.properties.color = Color(c.r, c.g, c.b, 0.0)
      end
    end
    
    -- Clear loops (1-8)
    for num = 1, 8 do
      local loopName = 'loop_' .. deck .. '_' .. num .. '_bg'
      local loopShape = findControl(loopName)
      if loopShape then
        local c = loopShape.properties.color
        loopShape.properties.color = Color(c.r, c.g, c.b, 0.0)
      end
    end
  end
  
  print('[initializeBackgrounds] Complete')
end



-- XY <-> Fader sync sets
-- Each set maps two CCs on a channel to an XY pad and two faders.
-- When either CC is received, both the fader and XY axis are updated together.
local xyFaderSets = {
  -- Deck 1 (Left)
  set1 = { channel = 1, xy = "xy-fx-l-1", faderX = "fader256", ccX = 66, faderY = "fader257", ccY = 67 },
  set2 = { channel = 1, xy = "xy-fx-l-2", faderX = "fader258", ccX = 71, faderY = "fader259", ccY = 72 },
  set3 = { channel = 1, xy = "xy-fx-l-3", faderX = "fader260", ccX = 76, faderY = "fader261", ccY = 77 },
  -- Deck 2 (Right)
  set4 = { channel = 2, xy = "xy-fx-r-1", faderX = "fader245", ccX = 66, faderY = "fader251", ccY = 67 },
  set5 = { channel = 2, xy = "xy-fx-r-2", faderX = "fader252", ccX = 71, faderY = "fader253", ccY = 72 },
  set6 = { channel = 2, xy = "xy-fx-r-3", faderX = "fader254", ccX = 76, faderY = "fader255", ccY = 77 },
}

function handleXYFaderSync(cc, channel, val)
  local norm = val / 127
  for _, cfg in pairs(xyFaderSets) do
    if channel == cfg.channel then
      if cc == cfg.ccX then
        local xy = findControl(cfg.xy)
        local fader = findControl(cfg.faderX)
        if xy    then xy.values.x    = norm end
        if fader then fader.values.x = norm end
      elseif cc == cfg.ccY then
        local xy = findControl(cfg.xy)
        local fader = findControl(cfg.faderY)
        if xy    then xy.values.y    = norm end
        if fader then fader.values.x = norm end
      end
    end
  end
end

-- Run initialization on startup
initializeBackgrounds()
