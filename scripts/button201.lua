-- Source control: button201
-- File: TEEE-EMMEDIA.tosc

-- CONFIG
local SLIDER_NAME = 'crossfader'
local VALUE = 0.5

function onValueChanged(key)
  if key == 'x' and self.values.x == 1 then
    local slider = root:findByName(SLIDER_NAME, true)
    if not slider then return end
    slider.values.x = VALUE
    sendMIDI(slider.messages.MIDI[1]:data())
  end
end
