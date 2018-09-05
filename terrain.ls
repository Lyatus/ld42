(set (self'start) (fun (do
	(self'entity'require-primitive || 'material || 'parent | "material/terrain.ls")
	(self'entity'require-primitive || 'scale | (vec terrain-size terrain-size 8))
)))
(set (self'update) (fun (do
  (local transform (self'entity | 'require-transform |))
	(transform'move | (vec 0 (* current-speed delta -1) 0))
  (local position (transform'get-position|))
  (if (< (position'y|) (- terrain-size)) (transform'move | (vec 0 (* 2 terrain-size terrain-cell-count) 0)))
)))
