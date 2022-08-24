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

(defn str-empty? [s]
  (or (none? s) (empty? (.strip s))))

(defn str-not-empty? [s]
  (not (str-empty? s)))

(defn evently-divide [dividend-decimal divisor-int decimal-min-value]
  (setv
    total-amount (.quantize (abs dividend-decimal) decimal-min-value)
    low-amount (.quantize
                 (/ total-amount divisor-int)
                 decimal-min-value decimal.ROUND_DOWN)
    high-amount (+ low-amount decimal-min-value)
    num-highs (%
                (int (* total-amount (/ 1 decimal-min-value)))
                divisor-int
                )
    num-lows (- divisor-int num-highs)
    dividend-decimal-fn (if (pos? dividend-decimal) + -)
    high-amount (dividend-decimal-fn high-amount)
    low-amount (dividend-decimal-fn low-amount)
    )
  (+ (list (repeat high-amount num-highs))
     (list (repeat low-amount num-lows)))
  )


(defn evently-divide-portions [value portions decimal-min-value]
  (setv total-portions (reduce + portions)
        values (list (map
                      (fn [portion]
                        (.quantize 
                          (/ (* value portion) total-portions)
                          decimal-min-value
                          decimal.ROUND_DOWN)
                        )
                      portions))
        diff (- value (reduce + values))
        )
  (if (zero? diff)
      values
      (do
        (list
          (map + values
               (evently-divide diff (len values) decimal-min-value)))))
  )

(defn c-group-by [fn iter]
  (group-by
    (sorted iter :key fn)
    :key fn))
