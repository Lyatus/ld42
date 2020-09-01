(input_map [
  ; Gamepad
  {
    'name 'XAxis
    'axis 'GamepadLeftStickX
  }
  {
    'name 'YAxis
    'axis 'GamepadLeftStickY
  }
  {
    'name 'Throttle
    'button 'GamepadRightTrigger
  }
  {
    'name 'Throttle
    'button 'GamepadLeftTrigger
    'multiplier -1
  }
  {
    'name 'Continue
    'axis 'GamepadFaceBottom
  }

  ; Keyboard movememt
  {
    'name 'XAxis
    'button 'A ; Left
    'multiplier -1
  }
  {
    'name 'XAxis
    'button 'Q ; Left
    'multiplier -1
  }
  {
    'name 'XAxis
    'button 'D ; Right
  }
  {
    'name 'YAxis
    'button 'W ; Forward
    'multiplier -1
  }
  {
    'name 'YAxis
    'button 'Z ; Forward
    'multiplier -1
  }
  {
    'name 'YAxis
    'button 'S ; Backward
  }

  ; Keyboard throttle
  {
    'name 'Throttle
    'button 'W ; Forward
  }
  {
    'name 'Throttle
    'button 'Z ; Forward
  }
  {
    'name 'Throttle
    'button 'S ; Backward
    'multiplier -1
  }

  ; Keyboard misc
  {
    'name 'Continue
    'button 'Enter
  }
  {
    'name 'Continue
    'button 'Space
  }
  {
    'name 'Continue
    'button 'MouseLeft
  }
  {
    'name 'Restart
    'button 'R
  }
])
