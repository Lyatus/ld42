(set (self'start) (fun (do
  (set (self'camera) (self'entity'require-camera|))
  (set (self'ui-hover-sound) (self'entity'add-audio-source|))
  (set (self'ui-select-sound) (self'entity'add-audio-source|))
	(self'ui-hover-sound'stream | "audio/ui_hover.wav")
	(self'ui-select-sound'stream | "audio/ui_select2.wav")

	(local gui)
	; Create background
	(create-background (self'entity) "texture/map.png?comp=bc1")

	; Create oases
	(foreach i oasis oases (do
		(local is-attainable (< (oasis-distance (oases current-oasis) oasis) oasis-max-distance))
		(local is-current (= current-oasis i))
		(local is-target (= target-oasis i))
		(local is-destroyed (< (oasis'x) sandstorm-position))

		(set gui (self'entity'add-gui|))
		(set (oasis'gui) gui)
		(gui'material || 'parent | "material/gui_image.ls")
		(gui'material || 'texture | 'tex "texture/oasis.png?comp=bc3")
		(gui'viewport-anchor | (oasis'x) (oasis'y))
		(gui'anchor | 0.5 0.5)

		(set gui (self'entity'add-gui|))
		(set (oasis'heal-gui) gui)
		(gui'material || 'parent | "material/gui_image.ls")
		(gui'viewport-anchor | (oasis'x) (oasis'y))
		(gui'material || 'texture | 'tex "texture/no_heal.png")
		(gui'anchor | 0.5 1)
		(gui'offset | 0 -15)

		(if (and is-attainable (not is-current) (not is-destroyed)) (do
			(set gui (self'entity'add-gui|))
			(gui'material || 'parent | "material/gui_text.ls")
			(gui'viewport-anchor | (oasis'x) (oasis'y))
			(gui'anchor | 0.5 1)
			(local duration (oasis-deadline oasis))
			(local duration-text (time-format duration))
			(local duration-y-offset -20)
			(if (> (oasis'heal) 0) (-= duration-y-offset 65))
			(if is-target (-= duration-y-offset 40))
			(gui'offset | 0 duration-y-offset)
			(gui'material || 'text | duration-text)
		))

		(if is-target (do
			(set gui (self'entity'add-gui|))
			(gui'material || 'parent | "material/gui_image.ls")
			(gui'material || 'texture | 'tex "texture/safezone.png")
			(gui'viewport-anchor | (oasis'x) (oasis'y))
			(gui'anchor | 0.5 1)
			(gui'offset | 0 -20)
		))
	))

	; Create sandstorm
	(set gui (self'entity'add-gui|))
	(gui'material || 'parent | "material/gui_image.ls")
	(gui'material || 'texture | 'tex "texture/sandstorm.png?comp=bc3")
	(gui'viewport-anchor | sandstorm-position 0.5)
	(gui'anchor | 1 0.5)
	(gui'scale | background-scale background-scale)

	; Create tutorial
	(set gui (self'entity'add-gui|))
	(gui'material || 'parent | "material/gui_image.ls")
	(gui'material || 'texture | 'tex "texture/map_tuto.png?comp=bc3")
	(gui'viewport-anchor | 0.5 0.95)
	(gui'anchor | 0.5 1)

	; Create health gui
	(create-health-display (self'entity))

	; Create debug gui
	(create-debug-display (self'entity))
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

	; Update oases GUIs
	(foreach i oasis oases (do
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
		(oasis'gui'material || 'texture | 'tex (+ "texture/" texture-name ".png"))

		(if (and (not is-current) (not is-destroyed)) (switch (oasis'heal)
			1 (oasis'heal-gui'material || 'texture | 'tex (+ "texture/heal_1.png"))
			2 (oasis'heal-gui'material || 'texture | 'tex (+ "texture/heal_2.png"))
			3 (oasis'heal-gui'material || 'texture | 'tex (+ "texture/heal_3.png"))
			(oasis'heal-gui'material || 'texture | 'tex (+ "texture/no_heal.png"))
		))
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

	(display-debug)
)))
