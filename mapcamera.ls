(set (self'start) (fun (do
  (set (self'camera) (self'entity'require-camera|))
  (set (self'ui-hover-sound) (self'entity'add-audio-source|))
  (set (self'ui-select-sound) (self'entity'add-audio-source|))
	(self'ui-hover-sound'stream | "audio/ui_hover.wav")
	(self'ui-select-sound'stream | "audio/ui_select2.wav")
)))
(set (self'goto) (fun (i) (do
	(self'ui-select-sound'play|)
	(set (self'event) (fun (do)))
	(set (self'timer) 0.75)
	(set (self'update) (fun (do
		(-= (self'timer) delta)
		(if (< (self'timer) 0)
			(goto-oasis selected-oasis))
	)))
)))
(set (self'event) (fun (e) (do
	(switch (e'type)
		'ButtonDown (switch (e'button)
			'R (engine-clear-and-read "startup.ls")
			'LeftButton (do
				(if (>= selected-oasis 0)
					(self'goto | selected-oasis))
			)
		)
	)
)))
(set (self'update) (fun (do
	(local prev-selected-oasis selected-oasis)
	(set selected-oasis -1)
	(foreach i oasis oases (do
		(local px (* (window-width) (oasis'x)))
		(local py (* (window-height) (oasis'y)))
		(if (and
				(<> current-oasis i)
				(< (oasis-distance (oases current-oasis) oasis) oasis-max-distance)
				(< (- px 16) (mouse-x) (+ px 16))
				(< (- py 16) (mouse-y) (+ py 16)))
			(set selected-oasis i))
	))

	; Gather joystick input
	(local axis-x 0)
	(local axis-y 0)
	(local button-pressed false)
	(foreach device _ (get-devices) (do
		(+= axis-x (device'get-axis | 0))
		(+= axis-y (device'get-axis | 1))
		(set button-pressed (or button-pressed (device'get-button | 0)))
	))
	(local joy-dir (normalize (vec axis-x axis-y 0)))
	(if (> (length joy-dir) 0) (do
		(local best-value 0)
		(foreach i oasis oases (if (<> current-oasis i) (do
			(local dx (- (oasis'x) (oases current-oasis 'x)))
			(local dy (- (oasis'y) (oases current-oasis 'y)))
			(local value (dot joy-dir (normalize (vec dx dy 0))))
			(if (and
					(> value best-value)
					(< (oasis-distance (oases current-oasis) oasis) oasis-max-distance)) (do
				(set selected-oasis i)
				(set best-value value)))
		)))
		(if (and button-pressed (>= selected-oasis 0))
			(self'goto | selected-oasis))
	))

	; Play interaction sounds
	(if (and (>= selected-oasis 0) (<> selected-oasis prev-selected-oasis))
		(self'ui-hover-sound'play|))
)))
(set (self'gui) (fun (camera) (do
	(local bg-scale (/ (window-width) 1920))
	(camera'draw-image | 0 0 "texture/map.png" bg-scale)
	(foreach i oasis oases (do
		(local px (* (window-width) (oasis'x)))
		(local py (* (window-height) (oasis'y)))

		(local is-attainable (< (oasis-distance (oases current-oasis) oasis) oasis-max-distance))
		(local is-current (= current-oasis i))
		(local is-target (= target-oasis i))
		(local is-destroyed (< (oasis'x) sandstorm-position))
		(local is-selected (= selected-oasis i))
		(local texture-name "oasis")
		(if is-destroyed (+= texture-name "_destroyed")
			(do ; Else
				(if is-target (+= texture-name "_target"))
				(if is-current (+= texture-name "_current"))
				(if (not is-attainable) (+= texture-name "_disabled"))
				(if is-selected (+= texture-name "_selected"))
		))
		(camera'draw-image | (- px 21) (- py 21) (+ "texture/" texture-name ".png"))
		(if (and (not is-current) (not is-destroyed)) (switch (oasis'heal)
			1 (camera'draw-image | (- px 47) (- py 82) (+ "texture/heal_1.png"))
			2 (camera'draw-image | (- px 61) (- py 82) (+ "texture/heal_2.png"))
			3 (camera'draw-image | (- px 81) (- py 82) (+ "texture/heal_3.png"))
		))
		(if (and is-attainable (not is-current) (not is-destroyed)) (do
			(local duration (oasis-deadline oasis))
			(local duration-text (time-format duration))
			(local duration-y-offset 40)
			(if (> (oasis'heal) 0) (+= duration-y-offset 65))
			(camera'draw-text | "font/novaround.ttf" (- px 22) (- py duration-y-offset) duration-text)
		))
		(if is-target 
			(camera'draw-image | (- px 64) (- py 64) "texture/safezone.png"))
	))
	(camera'draw-image | (* (window-width) (- sandstorm-position 1)) 0 "texture/sandstorm.png" bg-scale)
	(camera'draw-image | (- (/ (window-width) 2) 286) (- (window-height) 150) "texture/map_tuto.png")
	(display-health camera)
	(display-debug camera)
)))
