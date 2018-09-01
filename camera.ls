(set (self'start) (fun (do
	(set (self'transform) (self'entity'require-transform|))
	(if (not menu) (set (self'vehicle-transform) (entity-get "vehicle" | 'require-transform|)))
  (set (self'camera) (self'entity'require-camera|))
	(self'entity'require-audio-listener|)
)))
(set (self'late-update) (fun (do
	; Update camera field of view to match current speed
  (self'camera'perspective | (+ 60 (* current-speed 0.085)) 1 4096) ; TWEAK: Relation between speed and FOV

	(if menu (do
    (foreach device _ (get-devices) (do
			(if (device'get-button | 7) (engine-clear-and-read "map.ls"))
		))
		(self'transform'set-position | (vec 0 0 15))
	) (do
		; Set camera position relative to vehicle
		(local vehicle-x (self'vehicle-transform'get-position||'x|))
		(local vehicle-z (self'vehicle-transform'get-position||'z|))
		(self'transform'set-position | (vec
			(* vehicle-x 0.8)
			0
			(+ 10 (* (- vehicle-z 10) 0.5))))
	))
)))
(set (self'event) (fun (e) (do
	(switch (e'type)
		'ButtonDown (switch (e'button)
			'R (engine-clear-and-read "startup.ls")
			(if menu (engine-clear-and-read "map.ls"))
		)
	)
)))
(set (self'gui) (fun (camera) (do
	(local bg-scale (/ (window-width) 1920))
	(if menu (do
		(camera'draw-image | 0 0 "texture/startscreen.png?comp=bc3" bg-scale)
		(camera'draw-image | (- (* (window-width) 0.5) (* 212 bg-scale))  (* (window-height) 0.6) "texture/startscreen_pressstart.png" bg-scale)
	) (do
		(camera'draw-image | 0 0 "texture/vignette.png?comp=bc3" bg-scale)
		(display-health camera)
		(local half-width (/ (window-width) 2))
		(local time-left (- race-timer (- (now) race-start)))
		(local draw-timer (or (> time-left (time 6)) (> (% time-left 0.5) 0.25)))
		(if draw-timer (camera'draw-text | "font/novaround.ttf?height=25" (- half-width 30) 62 (time-format time-left)))
		(camera'draw-image | (- half-width 146) 100 "texture/race_bar.png")
		(local progression (- 1 (/ race-distance race-start-distance)))
		(camera'draw-image | (+ half-width -146 (* progression 270)) 100 "texture/race_arrow.png")
	))
	(display-debug camera)
)))
