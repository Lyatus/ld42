(set self.type 'obstacle)
(set self.decor false)
(set self.update (fun (do
  (local transform (self.entity.require-transform))
	(transform.move-absolute (vec 0 (* current-speed delta -1) 0))
  (local position (transform.get-position))
	(local tp-distance (* 2 terrain-size terrain-cell-count))
  (if (< (position.y) (- terrain-size))
    (transform.move-absolute (vec 0 tp-distance 0)))
  (if (and (not menu) (not self.decor) (< race-distance (position.y)))
    (entity-destroy self.entity))
)))
