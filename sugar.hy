(defn default-func-name [name]
  (+ "default_" (.replace name "-" "_")))

(defmacro default [field args &rest body]
  `(with-decorator classmethod
     (defn ~(HySymbol (default-func-name (name field)))
       ~(cons (HySymbol "cls") args) ~@body)))

(defmacro default-value [field value]
  `(with-decorator classmethod
     (defn ~(HySymbol (default-func-name (name field))) [cls] ~value)))

(defmacro default-fn [field function]
  `(with-decorator classmethod
     (defn ~(HySymbol (default-func-name (name field))) [cls &rest args]
       (~function #* args))))

