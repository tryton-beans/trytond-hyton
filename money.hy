(import [trytond.model [fields]]
        [trytond.modules.hyton.utils [evently-divide]]
        [decimal [Decimal]]
        decimal)

(defn Money [name &rest args &kwargs kwargs]
  (.Numeric fields name :digits (, 16 2) #* args #** kwargs))

(defn evently-divide-money [money divisor-int]
  (evently-divide money divisor-int (Decimal "0.01"))
  )


