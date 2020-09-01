; Terrain variables
(set terrain_size 128)
(set terrain_cell_count (+ (/ race_distance terrain_size 2) 6))

; Obstacle variables
(set obstacle_per_cell (if menu 2 4))
(set obstacle_count (* terrain_cell_count obstacle_per_cell))
(set boost_count 0)

; Make directional light
(local dirlight_entity (entity_make))
(dirlight_entity.require_transform|.rotate (euler_degrees -20 0 130))
(dirlight_entity.require_primitive|.material|.parent "material/dirlight.ls")
(dirlight_entity.require_primitive|.material|.scalar 'intensity light_intensity)
(dirlight_entity.require_primitive|.scale 99999)

; Make emissive light
(local emissive_entity (entity_make))
(emissive_entity.require_primitive|.material|.parent "material/emissive.ls")
(emissive_entity.require_primitive|.scale 99999)

; Make ambient light
(local amblight_entity (entity_make))
(amblight_entity.require_primitive|.material|.parent "material/ssao.ls")
(amblight_entity.require_primitive|.material|.color 'color ambient_color)
(amblight_entity.require_primitive|.scale 99999)
(if (not menu) (do
  ; Make end race arch
  (local arch_entity (entity_make))
  (arch_entity.require_transform|.move (vec 0 (+ race_distance 32) 0))
  (arch_entity.require_transform|.rotate (euler_radians 0 0 (/ 3.14 2)))
  (arch_entity.add_primitive|.material|.parent "material/arch.ls")
  (arch_entity.add_primitive|.material|.parent "material/arch_rocks.ls")

  ; Make ship
  (local vehicle_entity (entity_make))
  (vehicle_entity.require_transform|.move (vec 0 10 4))
  (vehicle_entity.require_script|.load "script/vehicle.ls")

  ; Start race music
  (local music_source (entity_make|.add_audio_source))
  (music_source.stream "audio/race.ogg")
  (music_source.looping true)
  (music_source.play)
))

; Make camera
(entity_make|.add_script|.load "script/camera.ls")

; Infinite roll for menu
(local loop_objects {})
(if menu (do
  (local o (entity_make|.require_script|.object))
  (local camera (entity_get "camera" |.require_transform))
  (set o.update (fun (do
    (foreach loop_object _ loop_objects (do
      (if (< (+ terrain_size (loop_object.get_position).y) (camera.get_position).y)
        (loop_object.move_absolute (vec 0 race_distance 0)))
    ))
  )))
))

; Make terrain cells
(local i 0)
(while (< i terrain_cell_count) (do
  (local terrain_entity (entity_make))
  (local terrain_transform (terrain_entity.require_transform))
  (terrain_transform.move (vec 0 (* terrain_size i 2) 0))
  (terrain_entity.require_primitive|.material|.parent "material/terrain.ls")
  (terrain_entity.require_primitive|.scale (vec terrain_size terrain_size 8))
  (set loop_objects:terrain_transform true)
  (+= i 1)
))

; Make obstacles
(local i 0)
(local obstacle_y_min 0)
(local obstacle_y_max race_distance)
(if (not menu) (do
  (+= obstacle_y_min (* 2 terrain_size))
  (-= obstacle_y_max (* 2 terrain_size))
))
(while (< i obstacle_count) (do
  (local obstacle_entity (entity_make))
  (obstacle_entity.require_transform|.move
    (vec
      (rand_range (- terrain_size) terrain_size)
      (rand_range obstacle_y_min obstacle_y_max)
      0))
  (obstacle_entity.require_transform|.rotate (euler_radians (- (rand) 0.5) (- (rand) 0.5) (- (rand) 0.5)))
  (obstacle_entity.require_primitive|.material|.parent "material/rock.ls")
  (local obstacle_transform (obstacle_entity.require_transform))
  (set loop_objects:obstacle_transform true)

  ; Handle rock variations
  (local variant (floor (rand_range 1 4)))
  (local mesh_path (+ "mesh/rock_" variant ".obj"))
  (obstacle_entity.require_primitive|.material|.mesh mesh_path)
  (local extent (vec 8 8 32))
  (obstacle_entity.require_collider|.box extent)
  (obstacle_entity.require_rigidbody|.kinematic true)

  (+= i 1)
))

; Make background
(local sprite (entity_make))
(sprite.require_transform|.move (vec 0 4096 0))
(sprite.require_primitive|.material|.parent "material/sprite.ls")
(sprite.require_primitive|.material|.texture 'tex "texture/sunset.png?comp=bc1")
(sprite.require_primitive|.scale (vec (* 1920 4) 1 (* 1080 4)))
; Continuously move background with vehicle
(set (sprite.require_script|.object).update (fun
  (self.entity.require_transform|.move_absolute (vec 0 (* current_speed delta) 0))
))
