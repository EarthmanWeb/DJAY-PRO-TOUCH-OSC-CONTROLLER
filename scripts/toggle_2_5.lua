-- Source control: toggle_2_5
-- File: TEEE-EMMEDIA.tosc

function onValueChanged()
--  print('[toggle_2_5_violet_bg] value=' .. self.values.x)
  
  if self.values.x == 1 then
--    print('[toggle_2_5_violet_bg] Button pressed')
    local toggle_1_5_violet_bg = root:findByName('toggle_1_5_violet_bg', true)
    
  if toggle_1_5_violet_bg then
--      print('[keysync_2_bg] Found toggle_1_5_violet_bg.properties.color.a =' .. toggle_1_5_violet_bg.properties.color.a )
      
      if toggle_1_5_violet_bg.properties.color.a > 0.1 then
--        print('[keysync_1] Sending MIDI')
        sendMIDI({ 0xB0, 5, 127 })
        sendMIDI({ 0xB0, 5, 0 })
        
      end
    else
--      print('[toggle_1_5_violet_bg] toggle_1_5_violet_bg NOT FOUND')
    end
  end
end
