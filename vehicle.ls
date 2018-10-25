(set self.immunity -1)
(set self.boost 0)
(set self.roll 0)
(set self.start (fun (do
	(self.entity.require-name|.set "vehicle")
	(self.entity.require-primitive|.material|.parent "material/spaceship.ls")
	(self.entity.require-primitive|.scale 0.2)
	(self.entity.require-collider|.box (vec 1 1 1))
	(self.entity.require-primitive|.material|.color 'color immunity-color)
	
	(set self.vroom (self.entity.add-audio-source))
	(self.vroom.stream "audio/vroom.wav")
	(self.vroom.looping true)
	(self.vroom.play)

	(set self.hit-sound (self.entity.add-audio-source))
	(self.hit-sound.stream "audio/hit.wav")

	; Create thruster fire
	(local thruster-entity (entity-make))
	(set self.thruster-transform (thruster-entity.require-transform))
	(set self.thruster-primitive (thruster-entity.require-primitive))
	(self.thruster-primitive.material|.parent "material/thruster_fire.ls")
)))
(set self.update (fun (do
	; Movement values
	(local transform (self.entity.require-transform))
	(local movement (* real-delta 128))
	(local axis-x 0)
	(local axis-y 0)
  (local axis-z 0)
	(local axis-rot-x 0)
	(local axis-rot-y 0)

	; Gather joystick input (based on X360 only)
	(foreach device _ (get-devices) (do
		(+= axis-x (device.get-axis 'GamepadLeftStickX))
		(-= axis-z (device.get-axis 'GamepadLeftTrigger))
		(+= axis-z (device.get-axis 'GamepadRightTrigger))
	))

	; Gather keyboard input
	(if (or (button-pressed 'Z) (button-pressed 'W)) (+= axis-z 1))
	(if (or (button-pressed 'Q) (button-pressed 'A)) (-= axis-x 1))
	(if (button-pressed 'S) (-= axis-z 1))
	(if (button-pressed 'D) (+= axis-x 1))

	; Execute input
	(if (> (abs axis-x) 0.1) (transform.move-absolute (vec (* axis-x movement) 0 0)))
	(+= self.roll (* axis-x 0.1))

	; Update speed base on race-distance, boost and input
	(set current-speed (+ base-speed (* 128 axis-z)))
	(if (< race-distance 128)
		(*= current-speed (/ race-distance 128)))
	(set current-speed (max current-speed min-speed))
	(-= self.boost delta)
	(if (> self.immunity -1)
		(set current-speed (min current-speed (+ base-speed (* 128 (max 0 (- self.immunity)))))))

  ; Update race distance
  (-= race-distance (* delta current-speed))
  (if (<= race-distance 0) (do
    (set race-end (now))
    (+= sandstorm-position (* (- race-end race-start) sandstorm-speed))
    (engine-clear-and-read "map.ls")
  ))

	; Update race timer
	(if (<= race-timer (- (now) race-start))
    (engine-clear-and-read "gameover.ls"))

  ; Playground limits
  (local position (transform.get-position))
  (set position (vec
    (clamp (position.x) -64 64)
    (position.y)
    (clamp (position.z) 5 16)))
  (transform.set-position position)

	; Rotation effects
	(*= self.roll 0.8)
	(transform.set-rotation (vec 0 0 1) (/ 3.14 2))
	(transform.rotate-absolute (vec 0 -1 0) (+ self.roll (* (position.x) 0.005)))

	; Update immunity
	(-= self.immunity delta)
	(local fragshader (if (< self.immunity 0) "staticmesh" "color"))
	(self.entity.require-primitive|.material|.pipeline (+ ".inline?fragment=shader/" fragshader ".frag&vertex=shader/staticmesh.vert"))

	; Update thruster fire
	(self.thruster-transform.copy transform)
	(self.thruster-transform.move-absolute (vec 0 -2.9 0))
	(self.thruster-transform.move (vec 0 0 -0.17))
	(self.thruster-transform.rotate-absolute (vec 0 1 0) (* delta 684486486))
	(self.thruster-primitive.scale (* 0.2 (/ current-speed base-speed)))
	(if (> self.immunity 0) (self.thruster-primitive.scale 0))
)))
(set self.event (fun (e) (do
  (if (= e.type 'COLLISION) (do
		(local collider-type (e.other.entity|.require-script|.call (fun self.type)))
		(switch collider-type
			'obstacle (if (<= self.immunity 0) (do
				(change-health -1)
				(set self.immunity immunity-time)
				(self.hit-sound.play)
				(if (<= current-health 0) (engine-clear-and-read "gameover.ls")) ; Go back to gameover when dead
				(entity-destroy (e.other.entity))
			))
			'boost (do
				(set self.boost boost-time)
			)
		)
  ))
)))
