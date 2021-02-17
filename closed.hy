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

  (defn on-close [self] True)  
  (defn close [self]
    (when (on-close self)
      (setv self.closed True)
      True))

  (defn on-open [self] True)  
  (defn open [self]
    (when (on-open self)
      (setv self.closed False)
      True)))
