-- Source control: vocal_reset_a
-- File: TEEE-EMMEDIA.tosc

-- CONFIG
local VALUE = 0.5
local SLIDER_NAME = 'slider_1_17'
local SOLO_BUTTON = 'toggle_1_21'
local SOLO_FEEDBACK = 'toggle_1_21_yellow_bg'
local MUTE_BUTTON = 'toggle_1_13'
local MUTE_FEEDBACK = 'toggle_1_13_red_bg'

function onValueChanged(key)
  if key == 'x' and self.values.x == 1 then
    -- Set slider
    local slider = root:findByName(SLIDER_NAME, true)
    if slider then
      slider.values.x = VALUE
      sendMIDI(slider.messages.MIDI[1]:data())
    end
    
    -- Reset solo only if on
    local soloFeedback = root:findByName(SOLO_FEEDBACK, true)
    if soloFeedback and soloFeedback.properties.color.a > 0.1 then
      local solo = root:findByName(SOLO_BUTTON, true)
      if solo then
        local data = solo.messages.MIDI[1]:data()
        sendMIDI({ data[1], data[2], 127 })
      end
    end
    
    -- Reset mute only if on
    local muteFeedback = root:findByName(MUTE_FEEDBACK, true)
    if muteFeedback and muteFeedback.properties.color.a > 0.1 then
      local mute = root:findByName(MUTE_BUTTON, true)
      if mute then
        local data = mute.messages.MIDI[1]:data()
        sendMIDI({ data[1], data[2], 0 })
        sendMIDI({ data[1], data[2], 127 })
      end
    end
  end
end
