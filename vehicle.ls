(set self.immunity -1)
(set self.boost 0)
(set self.roll 0)
(set self.start (fun (do
  (self.entity.require_name|.set "vehicle")
  (self.entity.require_primitive|.material|.parent "material/spaceship.ls")
  (self.entity.require_primitive|.scale 0.2)
  (self.entity.require_collider|.box (vec 1 1 1))
  (self.entity.require_primitive|.material|.color 'color immunity_color)

  (set self.vroom (self.entity.add_audio_source))
  (self.vroom.stream "audio/vroom.wav")
  (self.vroom.looping true)
  (self.vroom.play)

  (set self.hit_sound (self.entity.add_audio_source))
  (self.hit_sound.stream "audio/hit.wav")

  ; Create thruster fire
  (local thruster_entity (entity_make))
  (set self.thruster_transform (thruster_entity.require_transform))
  (set self.thruster_primitive (thruster_entity.require_primitive))
  (self.thruster_primitive.material|.parent "material/thruster_fire.ls")
)))
(set self.update (fun (do
  ; Movement values
  (local transform (self.entity.require_transform))
  (local movement (* delta 128))
  (local axis_x 0)
  (local axis_y 0)
  (local axis_z 0)
  (local axis_rot_x 0)
  (local axis_rot_y 0)

  ; Gather joystick input (based on X360 only)
  (foreach device _ (get_devices) (do
    (+= axis_x (device.get_axis 'GamepadLeftStickX))
    (-= axis_z (device.get_axis 'GamepadLeftTrigger))
    (+= axis_z (device.get_axis 'GamepadRightTrigger))
  ))

  ; Gather keyboard input
  (if (or (button_pressed 'Z) (button_pressed 'W)) (+= axis_z 1))
  (if (or (button_pressed 'Q) (button_pressed 'A)) (-= axis_x 1))
  (if (button_pressed 'S) (-= axis_z 1))
  (if (button_pressed 'D) (+= axis_x 1))

  ; Execute input
  (if (> (abs axis_x) 0.1) (transform.move_absolute (vec (* axis_x movement) 0 0)))
  (+= self.roll (* axis_x 0.1))

  ; Update speed base on race_distance, boost and input
  (set current_speed (+ base_speed (* 128 axis_z)))
  (if (< race_distance 128)
    (*= current_speed (/ race_distance 128)))
  (set current_speed (max current_speed min_speed))
  (-= self.boost delta)
  (if (> self.immunity -1)
    (set current_speed (min current_speed (+ base_speed (* 128 (max 0 (- self.immunity)))))))

  ; Move forward
  (transform.move_absolute (vec 0 (* current_speed delta) 0))

  ; Update race distance
  (-= race_distance (* delta current_speed))
  (if (<= race_distance 0) (do
    (set race_end (now))
    (+= sandstorm_position (* (- race_end race_start) sandstorm_speed))
    (engine_clear_and_read "map.ls")
  ))

  ; Update race timer
  (if (<= race_timer (- (now) race_start))
    (engine_clear_and_read "gameover.ls"))

  ; Playground limits
  (local position (transform.get_position))
  (set position (vec
    (clamp (position.x) -64 64)
    (position.y)
    (clamp (position.z) 5 16)))
  (transform.set_position position)

  ; Rotation effects
  (*= self.roll 0.8)
  (transform.set_rotation (vec 0 0 1) (/ 3.14 2))
  (transform.rotate_absolute (vec 0 -1 0) (+ self.roll (* (position.x) 0.005)))

  ; Update immunity
  (-= self.immunity delta)
  (local fragshader (if (< self.immunity 0) "staticmesh" "color"))
  (self.entity.require_primitive|.material|.pipeline (+ ".inline?fragment=shader/" fragshader ".frag&vertex=shader/staticmesh.vert"))

  ; Update thruster fire
  (self.thruster_transform.copy transform)
  (self.thruster_transform.move_absolute (vec 0 -2.9 0))
  (self.thruster_transform.move (vec 0 0 -0.17))
  (self.thruster_transform.rotate_absolute (vec 0 1 0) (* delta 684486486))
  (self.thruster_primitive.scale (* 0.2 (/ current_speed base_speed)))
  (if (> self.immunity 0) (self.thruster_primitive.scale 0))
)))
(set self.event (fun e (do
  (if (and (= e.type 'Collision) (<= self.immunity 0)) (do
    (change_health -1)
    (set self.immunity immunity_time)
    (self.hit_sound.play)
    (if (<= current_health 0) (engine_clear_and_read "gameover.ls")) ; Go back to gameover when dead
    (entity_destroy (e.other.entity))
  ))
)))
