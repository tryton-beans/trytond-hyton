(import decimal
        [decimal [Decimal]])

(defn quantize-euros[d]
  (when d
    (.quantize d (decimal.Decimal "0.01") decimal.ROUND_HALF_UP)))

(defn calculate-percentage [percentage value]
  (/ (* value percentage) (Decimal "100")))


