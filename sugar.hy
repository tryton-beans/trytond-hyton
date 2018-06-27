(defmacro default [field args &rest body]
  `(with-decorator classmethod
     (defn ~(HySymbol (+ "default_" (name field)))
       ~(cons (HySymbol "cls") args) ~@body)))

(defmacro default-value [field value]
  `(with-decorator classmethod
     (defn ~(HySymbol (+ "default_" (name field))) [cls] ~value)))

(defmacro default-fn [field function]
  `(with-decorator classmethod
     (defn ~(HySymbol (+ "default_" (name field))) [cls &rest args]
       (~function #* args))))

