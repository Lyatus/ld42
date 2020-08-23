; Big low collider that destroys everything to avoid ever falling garbage

(set (self'start) (fun (do
  (self'entity | 'require_transform || 'move | (vec 0 0 -128))
  (self'entity | 'require_collider || 'box | (vec 4096 4096 64))
)))

(set (self'event) (fun e (do
  (if (= (e'type) 'COLLISION) (entity_destroy (e'other | 'entity|)))
)))
