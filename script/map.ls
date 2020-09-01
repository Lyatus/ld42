(set menu false)
(if (= current_oasis target_oasis)
  (do ; If you won
    (set victory true)
    (engine_clear_and_read "script/gameover.ls")
  )
  (do ; Otherwise load map UI
    ; Start map music
    (local music_source (entity_make|.add_audio_source))
    (music_source.stream "audio/map.ogg")
    (music_source.looping true)
    (music_source.play)
    (entity_make|.add_script|.load "script/mapcamera.ls")

    ; Heal
    (change_health oases:current_oasis.heal)
  )
)
