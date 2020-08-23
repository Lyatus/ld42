(set current_health base_health)
(set sandstorm_position 0.2)
(set victory false)
(generate_oases)

; Start intro music
(local music_source (entity_make|.add_audio_source))
(music_source.stream "audio/intro.ogg")
(music_source.looping true)
(music_source.play)

(set menu true)
(set race_distance 4096)
(set current_speed base_speed)
(read "race.ls"|)
