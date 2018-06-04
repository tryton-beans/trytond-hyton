
(defmacro default [field args &rest body]
  `(with-decorator staticmethod
     (defn ~(HySymbol (+ "default_" (name field))) ~args ~@body)))

(defmacro default-fn [field function]
  `(with-decorator staticmethod
     (defn ~(HySymbol (+ "default_" (name field))) [&rest args]
       (~function #* args))))
