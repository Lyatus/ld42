(set self.start (fun (do
  (self.entity.require_name|.set "camera")
  (set self.transform (self.entity.require_transform))
  (if (not menu) (set self.vehicle_transform (entity_get "vehicle" |.require_transform)))
  (set self.camera (self.entity.require_camera))
  (self.entity.require_audio_listener)
  (local gui)
  (if menu (do
    ; Create background
    (create_background self.entity "texture/startscreen.png?comp=bc3")

    ; Create press start text
    (set gui (self.entity.add_gui))
    (gui.material|.parent "material/gui_image.ls")
    (gui.material|.texture 'tex "texture/startscreen_pressstart.png")
    (gui.viewport_anchor 0.5 0.7)
    (gui.anchor 0.5 0.5)

    ; Place camera
    (self.transform.set_position (vec 0 0 15))
  ) (do ; Race
    ; Create vignette
    (create_background self.entity "texture/vignette.png?comp=bc3")

    ; Create timer
    (set gui (self.entity.add_gui))
    (set self.timer_gui gui)
    (gui.material|.parent "material/gui_text.ls")
    (gui.material|.font "font/novaround.ttf")
    (gui.viewport_anchor 0.5 0)
    (gui.anchor 0.5 0)
    (gui.offset 0 62)
    (gui.scale 25 25)

    ; Create race bar
    (set gui (self.entity.add_gui))
    (gui.material|.parent "material/gui_image.ls")
    (gui.material|.texture 'tex "texture/race_bar.png?comp=bc3")
    (gui.viewport_anchor 0.5 0)
    (gui.anchor 0.5 0)
    (gui.offset 0 100)

    ; Create race arrow
    (set gui (self.entity.add_gui))
    (set self.arrow_gui gui)
    (gui.material|.parent "material/gui_image.ls")
    (gui.material|.texture 'tex "texture/race_arrow.png?comp=bc3")
    (gui.viewport_anchor 0.5 0)
    (gui.anchor 0.5 0)
    (gui.offset 0 100)

    (create_health_display self.entity)
  ))

  ; Create debug gui
  (create_debug_display self.entity)
)))
(set self.late_update (fun (do
  ; Update camera field of view to match current speed
  (self.camera.perspective (+ 60 (* current_speed 0.085)) 3 4150) ; TWEAK: Relation between speed and FOV

  (if menu (do
    (self.transform.move_absolute (vec 0 (* current_speed delta) 0))
  ) (do
    ; Set camera position relative to vehicle
    (local vehicle_pos (self.vehicle_transform.get_position))
    (self.transform.set_position (vec
      (* (vehicle_pos.x) 0.8)
      (- (vehicle_pos.y) 10)
      (+ 10 (* (- (vehicle_pos.z) 10) 0.5))))

    ; Update GUI
    (local time_left (- race_timer (- (now) race_start)))
    (local draw_timer (or (> time_left (time 6)) (> (% time_left 0.5) 0.25)))
    (self.timer_gui.material|.text (if draw_timer (time_format time_left) ""))
    (local progression (- 1 (/ race_distance race_start_distance)))
    (self.arrow_gui.offset (- (* progression 270) 140) 100)
  ))
  (display_debug)
)))
(set self.event (fun e (do
  (if e.pressed (switch e.button
    'R (engine_clear_and_read "startup.ls")
    (if menu (engine_clear_and_read "map.ls"))
  ))
)))
