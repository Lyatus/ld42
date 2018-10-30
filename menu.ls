(set current-health base-health)
(set sandstorm-position 0.2)
(set victory false)
(generate-oases)

; Start intro music
(local music-source (entity-make|.add-audio-source))
(music-source.stream "audio/intro.ogg")
(music-source.looping true)
(music-source.play)

(set menu true)
(set race-distance 4096)
(set current-speed base-speed)
(read "race.ls"|)
