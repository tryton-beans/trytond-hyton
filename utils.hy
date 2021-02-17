(import decimal
        [decimal [Decimal]])

(defn quantize-euros[d]
  (when (not (none? d))
    (.quantize d (decimal.Decimal "0.01") decimal.ROUND_HALF_UP)))

(defn calculate-percentage [percentage value]
  (/ (* value percentage) (Decimal "100")))

(defn not-none? [x] (not (none? x)))

(defn get-or [map key value]
  (try (get map key) (except [KeyError] value)))

(defn get-or-none [map key]
  (get-or map key None))

(defn str-not-empty? [s]
  (and s (not (empty? (.strip s)))))
