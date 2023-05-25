# Maximum and minimum PWM values.
OUT_MAX = 255
OUT_MIN = 0

def map_value(value, input_steps, reverse=false)
  # Map it to a 0-1 range first.
  fraction = value / input_steps.to_f

  # Reverse if needed.
  fraction = 1 - fraction if reverse
  
  # Map to the output range
  value = (fraction * OUT_MAX).floor
  
  # Clamp within the range just in case.
  value = OUT_MAX if value > OUT_MAX
  value = OUT_MIN if value < OUT_MIN
  value
end

def map_red(pot_value)
  # Red full on at low end.
  return OUT_MAX if pot_value < 171
  
  # Red fades out from 171-341
  if (171..341).include? pot_value
    return map_value(pot_value - 171, 170, true)
  end
  
  # Red full off in the middle third.
  return OUT_MIN if (342..682).include? pot_value
  
  # Red fades in from 683-853
  if (683..853).include? pot_value
    return map_value(pot_value - 683, 170, false)
  end
  
  # Red full on at high end.
  return OUT_MAX if pot_value > 853
end

def map_green(pot_value)
  # Green fades in from 0-171
  if (0..170).include? pot_value
    return map_value(pot_value, 170, false)
  end

  # Green full on from 1/6 to 1/2.
  return OUT_MAX if (171..511).include? pot_value
  
  # Green fades out from 512-682
  if (512..682).include? pot_value
    return map_value(pot_value - 512, 170, true)
  end
  
  # Geen full off above 2/3.
  return OUT_MIN if pot_value > 682
end

def map_blue(pot_value)
  # Blue full off until 1/3
  return OUT_MIN if pot_value < 342
  
  # Blue fades in from 342-512 (170 steps)
  if (342..542).include? pot_value
    return map_value(pot_value - 342, 170, false)
  end
  
  # Blue full on from 513 to 852
  return OUT_MAX if (513..852).include? pot_value

  # Blue fades out from 853-1023 (170 steps)
  if (853..1023).include? pot_value
    return map_value(pot_value - 853, 170, true)
  end
end
