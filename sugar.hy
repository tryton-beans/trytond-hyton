(import hy.models [Symbol]
        trytond.model [Model fields]
        trytond.modules.hyton [sugar-runtime]
        trytond.modules.hyton.utils [first]
        cytoolz [second partition]
        functools [reduce])

(defn default-func-name [name]
  (+ "default_" (.replace name "-" "_")))

;; Symbol to python string
(defmacro pstr [field]
  (.replace (str field) "-" "_"))

(defmacro default [field args #* body]
  `(defn [classmethod] ~(Symbol (default-func-name (str field)))
         ~(+ [(Symbol "cls")] (list args)) ~@body))

(defmacro default-value [field value]
  `(defn [classmethod] ~(Symbol (default-func-name (str field))) [cls] ~value))

(defmacro default-fn [field function]
  `(defn [classmethod] ~(Symbol (default-func-name (str field))) [cls #* args]
         (~function #* args)))

;; Runtime helpers delegated to sugar_runtime.py
(defn gets [provider keys]
  (.gets sugar-runtime provider keys))

(defn save [model]
  (.save sugar-runtime model))

(defn save-all [models]
  (.save_all sugar-runtime models))

(defn pool-gets [provider keys]
  (.pool_gets sugar-runtime provider keys))

(defn pool-create [model-name #* args #** kargs]
  (.pool_create sugar-runtime model-name #* args #** kargs))

(defn pool-new [model-name #* args #** kargs]
  (.pool_new sugar-runtime model-name #* args #** kargs))

(defn pool-load [model-name id]
  (.pool_load sugar-runtime model-name id))

(defn pool-search [model-name #* args #** kargs]
  (.pool_search sugar-runtime model-name #* args #** kargs))

(defn pool-delete [model-name #* args #** kargs]
  (.pool_delete sugar-runtime model-name #* args #** kargs))

(defn pool-search-one [model-name #* args #** kargs]
  (.pool_search_one sugar-runtime model-name #* args #** kargs))

(defn pool-singleton [model-name]
  (.pool_singleton sugar-runtime model-name))

(defn pool-browse [model-name #* args #** kargs]
  (.pool_browse sugar-runtime model-name #* args #** kargs))

(defn pool-browse-active-ids [model-name]
  (.pool_browse_active_ids sugar-runtime model-name))

;;rec-name helpers
(defn is-not-operator [s]
  (.is_not_operator sugar-runtime s))

(defn rec-name-and-or [s-operator]
  (.rec_name_and_or sugar-runtime s-operator))

(defn rec-name-search-fields [fields clauses]
  (.rec_name_search_fields sugar-runtime fields clauses))

;; this macro requires rec-name-search-fields
(defmacro search-rec-name-fields [fields]
  `(defn [classmethod] search-rec-name [cls name clauses]
         (rec-name-search-fields ~fields clauses)))

(defmacro create-fn-values [fn-values]
  `(defn [classmethod] create [cls vlist]
     (setv
       fn-pre ~fn-values
       c-vlist (lfor x vlist (.copy x)))
     (for [values c-vlist] (fn-pre values))
     (.create (super) c-vlist)))

;; it has defensive copy is it really is-needed
(defmacro on-create [fn-values fn-record]
  `(defn [classmethod] create [cls vlist]
     (setv
       fn-pre ~fn-values
       fn-post ~fn-record
       c-vlist (lfor x vlist (.copy x)))
     (for [values c-vlist] (fn-pre values))
     (setv ret (.create (super) c-vlist))
     (for [o ret] (fn-post o))
     ret))

;; should it have defensive is-copy
(defmacro on-write [fn]
  `(defn [classmethod] write [cls records values #* args]
     (setv fn-record-values ~fn)
     (for [o records] (fn-record-values o values))
     (for [o (list (partition 2 args))]
       (for [r (first o)] (fn-record-values r (second o))))
     (.write (super) records values #* args)))

(defn create-indexes-code [table-field-code]
  (.create_indexes_code sugar-runtime table-field-code))

(defn create-indexes-date [table-field-date]
  (.create_indexes_date sugar-runtime table-field-date))

(defclass NavInFunctionFieldMixin [Model]

  (defn get-in [self name]
    (let [path (.split name "__")]
      (reduce (fn [x y]
                (if (is x None)
                    None
                    (getattr x y))) path self)))

  (defn get-in-id [self name]
    (.get-in self (+ name "__id")))
  
  (defn [classmethod] search-in [cls name domain]
    [(+ #((.replace name "__" "."))
        (tuple (cut domain 1 None None)))])

  (defn [staticmethod] nav-in-function-field [field]
    (.Function fields field "get_in" :searcher "search_in"))

  (defn [staticmethod] nav-in-function-field-m2o [field]
    (.Function fields field "get_in_id" :searcher "search_in"))

  )
