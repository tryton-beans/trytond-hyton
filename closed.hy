(import inspect
        [trytond.model [fields]]
        [trytond.model.fields [Field]]
        [trytond.pyson [Equal Eval]]
        [trytond.modules.hyton.common-fields [add-readonly add-depends]])
(require [trytond.modules.hyton.sugar [default-value]])


(setv -close-readonly-statement 
  (Equal (Eval "closed" False) True))

(defclass Closeable []
  (setv
    closed (.Boolean fields "Closed" :select True))

  #@(classmethod
      (defn readonly-closed-setup [cls]
        (for [field (->> cls
                         (inspect.getmembers)
                         (map second)
                         (filter (fn[m] (isinstance m Field))))]
          (add-depends 
            (add-readonly field -close-readonly-statement)
            ["closed"]))))
  
  (default-value closed False)

  (defn can-close [self]
    True)
  
  (defn -close [self]
    (when (.can-close self)
      (setv self.closed True)
      True))

  
  (defn can-open [self]
    True)
  
  (defn -open [self]
    (when (.can-open self)
      (setv self.closed False)
      True)))
