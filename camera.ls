(set self.start (fun (do
	(set self.transform (self.entity.require-transform))
	(if (not menu) (set self.vehicle-transform (entity-get "vehicle" |.require-transform)))
  (set self.camera (self.entity.require-camera))
	(self.entity.require-audio-listener)
	(local gui)
	(if menu (do
		; Create background
		(create-background self.entity "texture/startscreen.png?comp=bc3")
		
		; Create press start text
		(set gui (self.entity.add-gui))
		(gui.material|.parent "material/gui_image.ls")
		(gui.material|.texture 'tex "texture/startscreen_pressstart.png")
		(gui.viewport-anchor 0.5 0.7)
		(gui.anchor 0.5 0.5)

	) (do ; Race
		; Create vignette
		(create-background self.entity "texture/vignette.png?comp=bc3")

		; Create timer
		(set gui (self.entity.add-gui))
		(set self.timer-gui gui)
		(gui.material|.parent "material/gui_text.ls")
		(gui.material|.font "font/novaround.ttf")
		(gui.viewport-anchor 0.5 0)
		(gui.anchor 0.5 0)
		(gui.offset 0 62)
		(gui.scale 25 25)

		; Create race bar
		(set gui (self.entity.add-gui))
		(gui.material|.parent "material/gui_image.ls")
		(gui.material|.texture 'tex "texture/race_bar.png?comp=bc3")
		(gui.viewport-anchor 0.5 0)
		(gui.anchor 0.5 0)
		(gui.offset 0 100)

		; Create race arrow
		(set gui (self.entity.add-gui))
		(set self.arrow-gui gui)
		(gui.material|.parent "material/gui_image.ls")
		(gui.material|.texture 'tex "texture/race_arrow.png?comp=bc3")
		(gui.viewport-anchor 0.5 0)
		(gui.anchor 0.5 0)
		(gui.offset 0 100)

		(create-health-display self.entity)
	))

	; Create debug gui
	(create-debug-display self.entity)
)))
(set self.late-update (fun (do
	; Update camera field of view to match current speed
  (self.camera.perspective (+ 60 (* current-speed 0.085)) 1 4096) ; TWEAK: Relation between speed and FOV

	(if menu (do
    (foreach device _ (get-devices) (do
			(if (device.get-button 7) (engine-clear-and-read "map.ls"))
		))
		(self.transform.set-position (vec 0 0 15))
	) (do
		; Set camera position relative to vehicle
		(local vehicle-x (self.vehicle-transform.get-position|.x))
		(local vehicle-z (self.vehicle-transform.get-position|.z))
		(self.transform.set-position (vec
			(* vehicle-x 0.8)
			0
			(+ 10 (* (- vehicle-z 10) 0.5))))

		; Update GUI
		(local time-left (- race-timer (- (now) race-start)))
		(local draw-timer (or (> time-left (time 6)) (> (% time-left 0.5) 0.25)))
		(self.timer-gui.material|.text (if draw-timer (time-format time-left) ""))
		(local progression (- 1 (/ race-distance race-start-distance)))
		(self.arrow-gui.offset (- (* progression 270) 140) 100)
	))
	(display-debug)
)))
(set self.event (fun (e) (do
	(if e.pressed (switch e.button
		'R (engine-clear-and-read "startup.ls")
		(if menu (engine-clear-and-read "map.ls"))
	))
)))
