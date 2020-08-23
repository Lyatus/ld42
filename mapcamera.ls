(set self.start (fun (do
  (set self.camera (self.entity.require_camera))
  (set self.input (self.entity.require_input|.context))
  (set self.ui_hover_sound (self.entity.add_audio_source))
  (set self.ui_select_sound (self.entity.add_audio_source))
  (self.ui_hover_sound.stream "audio/ui_hover.wav")
  (self.ui_select_sound.stream "audio/ui_select2.wav")

  (local gui)
  ; Create background
  (create_background self.entity "texture/map.png?comp=bc1")

  ; Create oases
  (foreach i oasis oases (do
    (local is_attainable (< (oasis_distance oases:current_oasis oasis) oasis_max_distance))
    (local is_current (= current_oasis i))
    (local is_target (= target_oasis i))
    (local is_destroyed (< oasis.x sandstorm_position))

    (set gui (self.entity.add_gui))
    (set oasis.gui gui)
    (gui.material|.parent "material/gui_image.ls")
    (gui.material|.texture 'tex "texture/oasis.png?comp=bc3")
    (gui.viewport_anchor oasis.x oasis.y)
    (gui.anchor 0.5 0.5)

    (set gui (self.entity.add_gui))
    (set oasis.heal_gui gui)
    (gui.material|.parent "material/gui_image.ls")
    (gui.viewport_anchor oasis.x oasis.y)
    (gui.material|.texture 'tex "texture/no_heal.png")
    (gui.anchor 0.5 1)
    (gui.offset 0 -15)

    (if (and is_attainable (not is_current) (not is_destroyed)) (do
      (set gui (self.entity.add_gui))
      (gui.material|.parent "material/gui_text.ls")
      (gui.viewport_anchor oasis.x oasis.y)
      (gui.anchor 0.5 1)
      (local duration (oasis_deadline oasis))
      (local duration_text (time_format duration))
      (local duration_y_offset -20)
      (if (> oasis.heal 0) (-= duration_y_offset 65))
      (if is_target (-= duration_y_offset 40))
      (gui.offset 0 duration_y_offset)
      (gui.material|.text duration_text)
      (gui.scale 20 20)
    ))

    (if is_target (do
      (set gui (self.entity.add_gui))
      (gui.material|.parent "material/gui_image.ls")
      (gui.material|.texture 'tex "texture/safezone.png")
      (gui.viewport_anchor oasis.x oasis.y)
      (gui.anchor 0.5 1)
      (gui.offset 0 -20)
    ))
  ))

  ; Create sandstorm
  (set gui (self.entity.add_gui))
  (gui.material|.parent "material/gui_image.ls")
  (gui.material|.texture 'tex "texture/sandstorm.png?comp=bc3")
  (gui.viewport_anchor sandstorm_position 0.5)
  (gui.anchor 1 0.5)
  (gui.scale background_scale background_scale)

  ; Create tutorial
  (set gui (self.entity.add_gui))
  (gui.material|.parent "material/gui_image.ls")
  (gui.material|.texture 'tex "texture/map_tuto.png")
  (gui.viewport_anchor 0.5 0.95)
  (gui.anchor 0.5 1)

  ; Create health gui
  (create_health_display self.entity)

  ; Create debug gui
  (create_debug_display self.entity)
)))
(set self.goto (fun i (do
  (self.ui_select_sound.play)
  (set self.event (fun (do)))
  (set self.timer 0.75)
  (set self.update (fun (do
    (-= self.timer delta)
    (if (< self.timer 0)
      (goto_oasis selected_oasis))
  )))
)))
(set self.update (fun (do
  (local prev_selected_oasis selected_oasis)
  (set selected_oasis -1)
  (foreach i oasis oases (do
    (local px (* (window_width) oasis.x))
    (local py (* (window_height) oasis.y))
    (if (and
        (<> current_oasis i)
        (< (oasis_distance oases:current_oasis oasis) oasis_max_distance)
        (< (- px 16) (mouse_x) (+ px 16))
        (< (- py 16) (mouse_y) (+ py 16)))
      (set selected_oasis i))
  ))

  ; Gather joystick input
  (local axis_x 0)
  (local axis_y 0)
  (local button_pressed false)
  (foreach device _ (get_devices) (do
    (+= axis_x (device.get_axis 'GamepadLeftStickX))
    (-= axis_y (device.get_axis 'GamepadLeftStickY)) ; Invert because stick Y+ is up
    (set button_pressed (or button_pressed (device.get_button 'GamepadFaceBottom)))
  ))
  (local joy_dir (normalize (vec axis_x axis_y 0)))
  (if (> (length joy_dir) 0) (do
    (local best_value 0)
    (foreach i oasis oases (if (<> current_oasis i) (do
      (local dx (- oasis.x oases:current_oasis.x))
      (local dy (- oasis.y oases:current_oasis.y))
      (local value (dot joy_dir (normalize (vec dx dy 0))))
      (if (and
          (> value best_value)
          (< (oasis_distance oases:current_oasis oasis) oasis_max_distance)) (do
        (set selected_oasis i)
        (set best_value value)))
    )))
    (if (and button_pressed (>= selected_oasis 0))
      (self.goto selected_oasis))
  ))

  ; Update oases GUIs
  (foreach i oasis oases (do
    (local is_attainable (< (oasis_distance oases:current_oasis oasis) oasis_max_distance))
    (local is_current (= current_oasis i))
    (local is_target (= target_oasis i))
    (local is_destroyed (< oasis.x sandstorm_position))
    (local is_selected (= selected_oasis i))
    (local texture_name "oasis")
    (if is_destroyed (+= texture_name "_destroyed")
      (do ; Else
        (if is_target (+= texture_name "_target"))
        (if is_current (+= texture_name "_current"))
        (if (not is_attainable) (+= texture_name "_disabled"))
        (if is_selected (+= texture_name "_selected"))
    ))
    (oasis.gui.material|.texture 'tex (+ "texture/" texture_name ".png"))

    (if (and (not is_current) (not is_destroyed)) (switch oasis.heal
      1 (oasis.heal_gui.material|.texture 'tex (+ "texture/heal_1.png"))
      2 (oasis.heal_gui.material|.texture 'tex (+ "texture/heal_2.png"))
      3 (oasis.heal_gui.material|.texture 'tex (+ "texture/heal_3.png"))
      (oasis.heal_gui.material|.texture 'tex (+ "texture/no_heal.png"))
    ))
  ))

  ; Play interaction sounds
  (if (and (>= selected_oasis 0) (<> selected_oasis prev_selected_oasis))
    (self.ui_hover_sound.play))

  (if (and debug (self.input.get_raw_button_pressed 'R))
    (engine_clear_and_read "startup.ls"))
  (if (and (>= selected_oasis 0) (self.input.get_raw_button_pressed 'MouseLeft))
    (self.goto selected_oasis))

  (display_debug)
)))
