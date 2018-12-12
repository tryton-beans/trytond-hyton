(import
  [trytond.transaction [Transaction]])

(defn context-company[]
    (.get (. (Transaction) context) "company"))
