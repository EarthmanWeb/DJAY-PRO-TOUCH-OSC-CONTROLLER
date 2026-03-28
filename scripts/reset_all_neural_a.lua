-- Source control: reset_all_neural_a
-- File: TEEE-EMMEDIA.tosc

-- CONFIG
local VALUE = 0.5
local STEMS = {
  {
    slider = 'slider_1_14',
    solo = 'toggle_1_19',
    solo_feedback = 'toggle_1_19_yellow_bg',
    mute = 'toggle_1_10',
    mute_feedback = 'toggle_1_10_red_bg'
  },
  {
    slider = 'slider_1_16',
    solo = 'toggle_1_20',
    solo_feedback = 'toggle_1_20_yellow_bg',
    mute = 'toggle_1_12',
    mute_feedback = 'toggle_1_12_red_bg'
  },
  {
    slider = 'slider_1_17',
    solo = 'toggle_1_21',
    solo_feedback = 'toggle_1_21_yellow_bg',
    mute = 'toggle_1_13',
    mute_feedback = 'toggle_1_13_red_bg'
  }
}

function resetSolo(stem)
  local feedback = root:findByName(stem.solo_feedback, true)
  if feedback and feedback.properties.color.a > 0.1 then
    local btn = root:findByName(stem.solo, true)
    if btn then
      local data = btn.messages.MIDI[1]:data()
      sendMIDI({ data[1], data[2], 127 })
    end
  end
end

function resetMute(stem)
  local feedback = root:findByName(stem.mute_feedback, true)
  if feedback and feedback.properties.color.a > 0.1 then
    local btn = root:findByName(stem.mute, true)
    if btn then
      local data = btn.messages.MIDI[1]:data()
      sendMIDI({ data[1], data[2], 0 })
      sendMIDI({ data[1], data[2], 127 })
    end
  end
end

function setSlider(stem)
  local slider = root:findByName(stem.slider, true)
  if slider then
    slider.values.x = VALUE
    sendMIDI(slider.messages.MIDI[1]:data())
  end
end

function onValueChanged(key)
  if key == 'x' and self.values.x == 1 then
    for _, stem in ipairs(STEMS) do
      setSlider(stem)
      resetSolo(stem)
      resetMute(stem)
    end
  end
end
