(set self.start (fun (do
  (set self.camera (self.entity.require_camera))
  (self.entity.require_audio_source|.stream (+ "audio/" (if victory "victory" "failure") ".ogg"))
  (self.entity.require_audio_source|.play)
  (create_background self.entity (+ "texture/" (if victory "victory" "gameover") ".png?comp=bc1"))
)))
(set self.event (fun e (do
  (if e.pressed (switch e.button
    'R (engine_clear_and_read "startup.ls")
    (engine_clear_and_read "menu.ls")
  ))
)))
