(import
  unittest
  datetime
  doctest
  trytond.tests.test_tryton
  decimal [Decimal]
  trytond.tests.test_tryton [ModuleTestCase with_transaction]
  trytond.modules.hyton.sugar [gets]
  trytond.modules.hyton.date [date-last-day-month date-next-weekday]
  trytond.modules.hyton [common-fields]
  trytond.modules.hyton.utils [evently-divide
                               evently-divide-portions
                               c-group-by
                               is-str-empty
                               is-str-not-empty
                               volume-m3-to-cms
                               volume-cms-to-m3
                               volume-m3-fix-long-to-cms
                               ]
  itertools [groupby]
  trytond [pyson]
  trytond.pool [Pool]
  )

(defn is-even [x]
  (= 0 (% x 2)))

(defclass HytonTestCase [ModuleTestCase]
  "Test Hyton"
  (setv module "hyton")

 
  (defn [(with_transaction)] test-gets [self]
    (setv [User] (gets (Pool) ["res.user"]))
    (.assertEqual self 1 1))

 
  (defn [(with_transaction)] test-next-day-of-week [self]
    ;;4 -> Friday
    (.assertEqual self
                  (date-next-weekday (datetime.date 2021 2 1) 4)
                  (datetime.date 2021 2 5))
    ;;works with string as well.
    (.assertEqual self
                  (date-next-weekday (datetime.date 2021 2 1) "4")
                  (datetime.date 2021 2 5))
    (.assertEqual self
                  (date-next-weekday (datetime.date 2021 2 6) "4")
                  (datetime.date 2021 2 12))
    (.assertEqual self (.weekday (datetime.date 2021 2 12)) 4)
    (.assertEqual self
                  (date-next-weekday (datetime.date 2021 2 1) 0)
                  (datetime.date 2021 2 1)))
  
 
  (defn [(with_transaction)] test-last-day-month-2021-1-29-fix [self]
    (.assertEqual self
                  (date-last-day-month (datetime.date 2021 1 29))
                  (datetime.date 2021 1 31)))

  (defn [(with_transaction)] test-add-depends [self]
    (.assertEqual self
                  (. (common-fields.Company) depends)
                  #{}
                  )
    (.assertEqual self
                  (. (common-fields.add-depends
                       (common-fields.Company)
                       ["hola"])
                     depends)
                  #{"hola"}
                  )

    (.assertEqual self
                  (sorted
                    (.
                      (common-fields.add-depends
                        (common-fields.Company 
                          :depends ["hola" "adeu"])
                        #{"hola" "goodbye"})
                      depends))
                  (sorted ["hola" "adeu" "goodbye"])
                  ))

 
  (defn [(with_transaction)] test-add-readonly [self]
    (.assertEqual self
                  (. (common-fields.Company) states)
                  {}
                  "no state"
                  )
    (.assertEqual self
                  (.
                    (common-fields.add-readonly
                      (common-fields.Company)
                      True
                      ) states)
                  {"readonly" True}
                  )
    (.assertEqual self
                  (.
                    (common-fields.add-readonly
                      (common-fields.Company
                        :states {"readonly" True})
                      True
                      ) states)
                  {"readonly" (pyson.And True True)}
                  ))


  (defn test-str-empty [self]
    (.assertTrue self (is-str-empty None))
    (.assertTrue self (is-str-empty ""))
    (.assertTrue self (is-str-empty "  "))
    (.assertFalse self (is-str-not-empty "  "))
    (.assertTrue self (is-str-not-empty " h "))
    )
  
  
  (defn test-c-group-by [self]
    (.assertEqual self (len (list (groupby [1 2 3 4] is-even))) 4)
    (.assertEqual self (len (list (c-group-by is-even [1 2 3 4]))) 2))
  
  (defn test-evently-divide [self]
    (.assertEqual self
                  (evently-divide (Decimal "0.11") 2 (Decimal "0.01"))
                  [(Decimal "0.06") (Decimal "0.05")])
    (.assertEqual self
                  (evently-divide (Decimal "0.11") 3 (Decimal "0.01"))
                  [(Decimal "0.04")
                   (Decimal "0.04")
                   (Decimal "0.03")])
    (.assertEqual self
                  (evently-divide (Decimal "-0.11") 3 (Decimal "0.01"))
                  [(Decimal "-0.04")
                   (Decimal "-0.04")
                   (Decimal "-0.03")])
    (.assertEqual self
                  (evently-divide (Decimal "-0") 3 (Decimal "0.01"))
                  [(Decimal "0.00")
                   (Decimal "0.00")
                   (Decimal "0.00")]))

  (defn test-volume-to-cms [self]
    (.assertEqual self
                          (volume-m3-to-cms (Decimal "1"))
                          [100 100 100])
    (.assertEqual self
                          (volume-m3-fix-long-to-cms (Decimal "1") (Decimal "200"))
                          [(Decimal "200") (Decimal "70.71") (Decimal "70.71")])
    (.assertEqual self
                  (volume-cms-to-m3 [(Decimal "200") (Decimal "70.71") (Decimal "70.71")])
                  1))
  
  (defn test-evently-divide-portions [self]
    (.assertEqual self
                  (evently-divide-portions (Decimal "0.10") [(Decimal "4") (Decimal "6")] (Decimal "0.01"))
                  [(Decimal "0.04") (Decimal "0.06")]
                  )
    (.assertEqual self
                  (evently-divide-portions (Decimal "0.11") [(Decimal "1") (Decimal "1")] (Decimal "0.01"))
                  [(Decimal "0.06") (Decimal "0.05")]
                  )

    (.assertEqual self
                  (evently-divide-portions (Decimal "-0.10") [(Decimal "4") (Decimal "6")] (Decimal "0.01"))
                  [(Decimal "-0.04") (Decimal "-0.06")]
                  )
    (.assertEqual self
                  (evently-divide-portions (Decimal "-0.11") [(Decimal "1") (Decimal "1")] (Decimal "0.01"))
                  [(Decimal "-0.06") (Decimal "-0.05")]
                  )

    (.assertEqual self
                  (evently-divide-portions (Decimal "-0.11") [(Decimal "1") (Decimal "0")] (Decimal "0.01"))
                  [(Decimal "-0.11") (Decimal "0")]
                  ))
  )


