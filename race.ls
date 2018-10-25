; Terrain variables
(set terrain-size 128)
(set terrain-cell-count 32)

; Obstacle variables
(set obstacle-count 128)
(set boost-count 0)

; Make directional light
(local dirlight-entity (entity-make))
(dirlight-entity.require-transform|.rotate (vec -0.4 0 1) 2.25)
(dirlight-entity.require-primitive|.material|.parent "material/dirlight.ls")
(dirlight-entity.require-primitive|.material|.scalar 'intensity light-intensity)
(dirlight-entity.require-primitive|.scale 99999)

; Make emissive light
(local emissive-entity (entity-make))
(emissive-entity.require-primitive|.material|.parent "material/emissive.ls")
(emissive-entity.require-primitive|.scale 99999)

; Make ambient light
(local amblight-entity (entity-make))
(amblight-entity.require-primitive|.material|.parent "material/ssao.ls")
(amblight-entity.require-primitive|.material|.color 'color ambient-color)
(amblight-entity.require-primitive|.scale 99999)

; Make terrain cells
(local i 0)
(while (< i terrain-cell-count) (do
  (local terrain-entity (entity-make))
  (terrain-entity.require-transform|.move (vec 0 (* terrain-size i 2) 0))
  (terrain-entity.require-script|.load "terrain.ls")
  (+= i 1)
))

; Make obstacles
(local i 0)
(while (< i obstacle-count) (do
  (local obstacle-entity (entity-make))
  (obstacle-entity.require-transform|.move 
    (vec
      (rand-range (- terrain-size) terrain-size)
      (+ (* terrain-cell-count (rand-range 0 terrain-size) 2) (* 2 terrain-size))
      0))
  (obstacle-entity.require-transform|.rotate (vec (- (rand) 0.2) (- (rand) 0.2) (- (rand) 0.5)) (rand))
  (obstacle-entity.require-primitive|.material|.parent "material/rock.ls")

  ; Handle rock variations
  (local variant (floor (rand-range 1 4)))
  (local mesh-path (+ "mesh/rock_" variant ".obj"))
  (obstacle-entity.require-primitive|.material|.mesh mesh-path)
  (local extent (vec 8 8 32))
  (obstacle-entity.require-collider|.box extent)
  (obstacle-entity.require-rigidbody|.kinematic true)
  (obstacle-entity.require-script|.load "obstacle.ls")

  (+= i 1)
))

; Make background
(local sprite (entity-make))
(sprite.require-transform|.move (vec 0 4096 0))
(sprite.require-primitive|.material|.parent "material/sprite.ls")
(sprite.require-primitive|.material|.texture 'tex "texture/sunset.png?comp=bc1")
(sprite.require-primitive|.scale (vec (* 1920 4) 1 (* 1080 4)))

(if (not menu) (do
  ; Make end race arch
  (local arch-entity (entity-make))
  (arch-entity.require-transform|.move (vec 0 (+ race-distance 32) 0))
  (arch-entity.require-transform|.rotate (vec 0 0 1) (/ 3.14 2))
  (arch-entity.add-primitive|.material|.parent "material/arch.ls")
  (arch-entity.add-primitive|.material|.parent "material/arch_rocks.ls")
  (arch-entity.require-script|.load "obstacle.ls")
  (arch-entity.require-script|.call (fun (set self.decor true)))

  ; Make ship
  (local vehicle-entity (entity-make))
  (vehicle-entity.require-transform|.move (vec 0 10 4))
  (vehicle-entity.require-script|.load "vehicle.ls")

  ; Make boosts
  (local i 0)
  (while (< i boost-count) (do
    (local boost-entity (entity-make))
    (boost-entity.require-transform|.move 
      (vec
        (rand-range (- terrain-size) terrain-size)
        (+ (* terrain-cell-count (rand-range 0 terrain-size) 2) (* 2 terrain-size))
        5))
    (boost-entity.require-script|.load "boost.ls")
    (+= i 1)
  ))

  ; Start race music
  (local music-source (entity-make|.add-audio-source))
  (music-source.stream "audio/race.ogg")
  (music-source.looping true)
  (music-source.play)
))

(entity-make|.add-script|.load "camera.ls")
