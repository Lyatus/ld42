(set debug false)

; Common functions
(set rand-range (fun (min max) (+ min (* (- max min) (rand)))))
(set rand-color (fun (color (rand) (rand) (rand))))
(set time-format (fun (time)
  (+ (left-pad (floor (/ time 60)) 2 "0") ":" (left-pad (floor (% time 60)) 2 "0"))))

; Game constants
(set oases-count 20)
(set oasis-max-distance 0.3)
(set oasis-min-distance 0.1)
(set oasis-min-x 0.25)
(set sandstorm-speed 0.01) ; Screen portion per second
(set unit-per-pixel 25000)
(set base-speed 256)
(set min-speed 100)
(set boost-speed 512)
(set base-health 3)
(set immunity-time 1.5)
(set boost-time 1.5)

; Visual constants
(set light-intensity 4)
(set ambient-color (color "#1e031a"))
(set immunity-color (color 1 1 1 0.25))

; Game functions
(set generate-oasis (fun {
  'x (rand-range 0.25 0.9)
  'y (rand-range 0.2 0.8)
  'heal (floor (rand-range 0 3))
}))
(set oasis-is-compliant (fun (oasis) (do
  (local near-enough false)
  (local far-enough true)
  (foreach i other-oasis oases (do
    (local distance (oasis-distance oasis other-oasis))
    (if (< distance oasis-max-distance) (set near-enough true))
    (if (< distance oasis-min-distance) (set far-enough false))
  ))
  (or (and near-enough far-enough) (= (count oases) 0))
)))
(set generate-oases (fun (do
  (set oases {})
  (set current-oasis 0)
  (set target-oasis 0)
  (local i 0)
  (while (< i oases-count) (do
    (local oasis (generate-oasis))
    (while (not (oasis-is-compliant oasis))
      (set oasis (generate-oasis)))
    (set (oases i) oasis)
    
    (if (< (oases i 'x) (oases current-oasis 'x)) (set current-oasis i)) ; Current oasis is leftmost
    (if (> (oases i 'x) (oases target-oasis 'x)) (set target-oasis i)) ; Target oasis is rightmost

    (+= i 1)
  ))
  (set (oases current-oasis 'heal) 0)
  (set (oases target-oasis 'heal) 0)
)))
(set oasis-distance (fun (a b) (do
	(local xdiff (- (a'x) (b'x)))
	(local ydiff (- (a'y) (b'y)))
	(sqrt (+ (* xdiff xdiff) (* ydiff ydiff)))
)))
(set oasis-deadline (fun (oasis) (do
  (time (/ (abs (- (oasis'x) sandstorm-position)) sandstorm-speed))
)))
(set goto-oasis (fun (i) (do
	(local start-oasis (oases current-oasis))
	(local end-oasis (oases i))
	(local distance (oasis-distance start-oasis end-oasis))
	(set race-start-distance (* distance unit-per-pixel))
	(set race-distance (* distance unit-per-pixel))
	(set race-timer (oasis-deadline end-oasis))
	(set current-oasis i)
  (set race-start (now))
	(engine-clear-and-read "race.ls")
)))
(set display-health (fun (camera) (do
  (local i 0)
  (while (< i 3) (do
	  (camera'draw-image | (+ 86 (* i 45)) 57 (+ "texture/health_" (if (<= current-health i) "off" "on") ".png"))
    (+= i 1)
  ))
)))
(set display-debug (fun (camera)
  (if debug (camera'draw-text | ".pixel" 10 100
    (+ "FPS: " (/ 1.0 delta) "\n"
      "Frame: " avg-frame-work-duration "\n"
      "Race distance: " race-distance "\n"
      "Race time: " (- (now) race-start) "\n"
      "FINAL COUNTDOWN: " (- race-timer (- (now) race-start)) "\n")))
))

; Engine setup
(font-pipeline ".inline?fragment=shader/texture.frag&vertex=shader/font.vert&pass=present")

(engine-clear-and-read "menu.ls")
