(import [trytond.model [ModelSQL ModelView fields]]
        [trytond.pool [Pool]]
        [random])



(defn create-random-str [letters size]
  (setv l (len letters))
  (reduce + (take size (repeatedly (fn [] (get letters (dec (random.randint 1 l))))))))

(defn create-id [&optional [size 8]]
  ;; some the letters/numbers that get confussed removed
  ;; 0 O 1 I
  (create-random-str "23456879ABCDEFGHJKLMNPRSTUVWXYZ" size))


(defn get-new-id [model field &optional [size 8]]
  (setv TheModel (.get (Pool) model)
        new-identifier (create-id size))
  (while (not (empty? (.search TheModel [(, field "=" new-identifier)])))
    (setv new-identifier (create-id size)))
  new-identifier)
