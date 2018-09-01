(set (self'start) (fun (do
  (set (self'camera) (self'entity | 'require-camera|))
	(self'entity'require-audio-source || 'stream | (+ "audio/" (if victory "victory" "failure") ".ogg"))
	(self'entity'require-audio-source || 'play|)
)))
(set (self'update) (fun (do
	(foreach device _ (get-devices) (do
		(if (device'get-button | 7) (engine-clear-and-read "menu.ls"))
	))
)))
(set (self'event) (fun (e) (do
	(switch (e'type)
		'ButtonDown (switch (e'button)
			'R (engine-clear-and-read "startup.ls")
			(engine-clear-and-read "menu.ls")
		)
	)
)))
(set (self'gui) (fun (camera) (do
	(local bg-scale (/ (window-width) 1920))
	(camera'draw-image | 0 0 (+ "texture/" (if victory "victory" "gameover") ".png?comp=bc1") bg-scale)
)))
