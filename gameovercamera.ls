(set self.start (fun (do
  (set self.camera (self.entity.require_camera))
  (set self.input (self.entity.require_input|.context))
  (self.input.set_input_map ((read "input_map.ls")))
  (self.entity.require_audio_source|.stream (+ "audio/" (if victory "victory" "failure") ".ogg"))
  (self.entity.require_audio_source|.play)
  (create_background self.entity (+ "texture/" (if victory "victory" "gameover") ".png?comp=bc1"))
)))
(set self.update (fun (do
  (if (and debug (self.input.get_button_pressed 'Restart))
    (engine_clear_and_read "startup.ls"))
  (if (self.input.get_button_pressed 'Continue)
    (engine_clear_and_read "menu.ls"))
)))
