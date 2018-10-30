; Terrain variables
(set terrain-size 128)
(set terrain-cell-count (+ (/ race-distance terrain-size 2) 6))

; Obstacle variables
(set obstacle-per-cell (if menu 2 4))
(set obstacle-count (* terrain-cell-count obstacle-per-cell))
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
(if (not menu) (do
  ; Make end race arch
  (local arch-entity (entity-make))
  (arch-entity.require-transform|.move (vec 0 (+ race-distance 32) 0))
  (arch-entity.require-transform|.rotate (vec 0 0 1) (/ 3.14 2))
  (arch-entity.add-primitive|.material|.parent "material/arch.ls")
  (arch-entity.add-primitive|.material|.parent "material/arch_rocks.ls")

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

; Make camera
(entity-make|.add-script|.load "camera.ls")

; Infinite roll for menu
(local loop-objects {})
(if menu (entity-make|.require-script|.call (fun (loop-objects) (do
  (set self.loop-objects loop-objects)
  (set self.camera (entity-get "camera" |.require-transform))
  (set self.update (fun (do
    (foreach loop-object _ self.loop-objects (do
      (if (< (+ terrain-size (loop-object.get-position|.y)) (self.camera.get-position|.y))
        (loop-object.move-absolute (vec 0 race-distance 0)))
    ))
  )))
)) loop-objects))

; Make terrain cells
(local i 0)
(while (< i terrain-cell-count) (do
  (local terrain-entity (entity-make))
  (local terrain-transform (terrain-entity.require-transform))
  (terrain-transform.move (vec 0 (* terrain-size i 2) 0))
  (terrain-entity.require-primitive|.material|.parent "material/terrain.ls")
  (terrain-entity.require-primitive|.scale (vec terrain-size terrain-size 8))
  (set loop-objects:terrain-transform true)
  (+= i 1)
))

; Make obstacles
(local i 0)
(local obstacle-y-min 0)
(local obstacle-y-max race-distance)
(if (not menu) (do
  (+= obstacle-y-min (* 2 terrain-size))
  (-= obstacle-y-max (* 2 terrain-size))
))
(while (< i obstacle-count) (do
  (local obstacle-entity (entity-make))
  (obstacle-entity.require-transform|.move 
    (vec
      (rand-range (- terrain-size) terrain-size)
      (rand-range obstacle-y-min obstacle-y-max)
      0))
  (obstacle-entity.require-transform|.rotate (vec (- (rand) 0.2) (- (rand) 0.2) (- (rand) 0.5)) (rand))
  (obstacle-entity.require-primitive|.material|.parent "material/rock.ls")
  (local obstacle-transform (obstacle-entity.require-transform))
  (set loop-objects:obstacle-transform true)

  ; Handle rock variations
  (local variant (floor (rand-range 1 4)))
  (local mesh-path (+ "mesh/rock_" variant ".obj"))
  (obstacle-entity.require-primitive|.material|.mesh mesh-path)
  (local extent (vec 8 8 32))
  (obstacle-entity.require-collider|.box extent)
  (obstacle-entity.require-rigidbody|.kinematic true)

  (+= i 1)
))

; Make background
(local sprite (entity-make))
(sprite.require-transform|.move (vec 0 4096 0))
(sprite.require-primitive|.material|.parent "material/sprite.ls")
(sprite.require-primitive|.material|.texture 'tex "texture/sunset.png?comp=bc1")
(sprite.require-primitive|.scale (vec (* 1920 4) 1 (* 1080 4)))
; Continuously move background with vehicle
(sprite.require-script|.call (fun (set self.update (fun
  (self.entity.require-transform|.move-absolute (vec 0 (* current-speed delta) 0))
))))
