(import [trytond.model [fields]])

(defn Money [name &rest args &kwargs kwargs]
  (.Numeric fields name :digits (, 16 2) #* args #** kwargs))
