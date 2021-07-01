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

(defn evently-divide [dividend-decimal divisor-int decimal-min-value]
  (setv
    total-amount (.quantize dividend-decimal decimal-min-value)
    low-amount (.quantize
                 (/ total-amount divisor-int)
                 decimal-min-value decimal.ROUND_DOWN)
    high-amount (+ low-amount decimal-min-value)
    num-highs (%
                (int (* total-amount (/ 1 decimal-min-value)))
                divisor-int
                )
    num-lows (- divisor-int num-highs)
    )
  (+ (list (repeat high-amount num-highs))
     (list (repeat low-amount num-lows)))
  )
