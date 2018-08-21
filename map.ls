(set menu false)
(if (= current-oasis target-oasis)
	(do ; If you won
		(set victory true)
		(engine-clear-and-read "gameover.ls") 
	)
	(do ; Otherwise load map UI
		; Heal
		(set current-health (min base-health (+ current-health (oases current-oasis 'heal))))

		; Start map music
		(local music-source (entity-make | 'add-audio-source|))
		(music-source'stream | "audio/map.ogg")
		(music-source'looping | true)
		(music-source'play|)
		(entity-make | 'add-script || 'load | "mapcamera.ls")
	)
)
