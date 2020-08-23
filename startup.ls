(set debug false)
(set background_scale (max (/ (window_width) 1920) (/ (window_height) 1080)))

; Common functions
(set rand_range (fun min max (+ min (* (- max min) (rand)))))
(set rand_color (fun (color (rand) (rand) (rand))))
(set time_format (fun time
  (+ (left_pad (floor (/ time 60)) 2 "0") ":" (left_pad (floor (% time 60)) 2 "0"))))

; Game constants
(set oases_count 20)
(set oasis_max_distance 0.3)
(set oasis_min_distance 0.1)
(set oasis_min_x 0.25)
(set sandstorm_speed 0.01) ; Screen portion per second
(set unit_per_pixel 25000)
(set base_speed 256)
(set min_speed 100)
(set boost_speed 512)
(set base_health 3)
(set immunity_time 1.5)
(set boost_time 1.5)

; Visual constants
(set light_intensity 4)
(set ambient_color (color "#1e031a"))
(set immunity_color (color 1 1 1 0.25))

; Game functions
(set generate_oasis (fun {
  'x (rand_range 0.25 0.9)
  'y (rand_range 0.2 0.8)
  'heal (floor (rand_range 0 3))
}))
(set oasis_is_compliant (fun oasis (do
  (local near_enough false)
  (local far_enough true)
  (foreach i other_oasis oases (do
    (local distance (oasis_distance oasis other_oasis))
    (if (< distance oasis_max_distance) (set near_enough true))
    (if (< distance oasis_min_distance) (set far_enough false))
  ))
  (or (and near_enough far_enough) (= (count oases) 0))
)))
(set generate_oases (fun (do
  (set oases {})
  (set current_oasis 0)
  (set target_oasis 0)
  (local i 0)
  (while (< i oases_count) (do
    (local oasis (generate_oasis))
    (while (not (oasis_is_compliant oasis))
      (set oasis (generate_oasis)))
    (set oases:i oasis)

    (if (< oases:i.x oases:current_oasis.x) (set current_oasis i)) ; Current oasis is leftmost
    (if (> oases:i.x oases:target_oasis.x) (set target_oasis i)) ; Target oasis is rightmost

    (+= i 1)
  ))
  (set oases:current_oasis.heal 0)
  (set oases:target_oasis.heal 0)
)))
(set oasis_distance (fun a b (do
  (local xdiff (- a.x b.x))
  (local ydiff (- a.y b.y))
  (sqrt (+ (* xdiff xdiff) (* ydiff ydiff)))
)))
(set oasis_deadline (fun oasis (do
  (time (/ (abs (- oasis.x sandstorm_position)) sandstorm_speed))
)))
(set goto_oasis (fun i (do
  (local start_oasis oases:current_oasis)
  (local end_oasis oases:i)
  (local distance (oasis_distance start_oasis end_oasis))
  (set race_start_distance (* distance unit_per_pixel))
  (set race_distance (* distance unit_per_pixel))
  (set race_timer (oasis_deadline end_oasis))
  (set current_oasis i)
  (set race_start (now))
  (engine_clear_and_read "race.ls")
)))
(set create_health_display (fun entity (do
  (set health_gui {
    0 (entity.add_gui)
    1 (entity.add_gui)
    2 (entity.add_gui)
  })
  (foreach i gui health_gui (do
    (gui.material|.parent "material/gui_image.ls")
    (gui.offset (+ 86 (* i 45)) 57)
  ))
  (change_health 0)
)))
(set change_health (fun offset (do
  (set current_health (min base_health (+ current_health offset)))
  (foreach i gui health_gui (do
    (gui.material|.texture 'tex (+ "texture/health_" (if (<= current_health i) "off" "on") ".png?comp=bc3"))
  ))
)))
(set create_debug_display (fun entity (do
  (set debug_gui (entity.add_gui))
  (debug_gui.material|.parent "material/gui_text.ls")
  (debug_gui.viewport_anchor 0 1)
  (debug_gui.anchor 0 1)
  (debug_gui.offset 10 -10)
  (debug_gui.scale 20 20)
)))
(set display_debug (fun
  (if debug (debug_gui.material|.text
    (+ "FPS: " (/ 1.0 delta) "\n"
      "Frame avg: " avg_frame_work_duration "\n"
      "Frame max: " max_frame_work_duration "\n"
      "Race dist: " race_distance "\n"
      "Race time: " (- (now) race_start) "\n"
      "Countdown: " (- race_timer (- (now) race_start)) "\n")))
))
(set create_background (fun entity texture (do
  (local gui (entity.add_gui))
  (gui.material|.parent "material/gui_image.ls")
  (gui.material|.texture 'tex texture)
  (gui.viewport_anchor 0.5 0.5)
  (gui.anchor 0.5 0.5)
  (gui.scale background_scale background_scale)
)))

(engine_clear_and_read "menu.ls")
