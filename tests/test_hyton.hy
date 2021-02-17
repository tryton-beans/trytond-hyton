(import
  unittest
  datetime
  doctest
  trytond.tests.test_tryton
  [trytond.tests.test_tryton [ModuleTestCase with_transaction]]
  [trytond.modules.hyton.sugar [gets]]
  [trytond.modules.hyton.date [date-last-day-month]]
  [trytond.modules.hyton [common-fields]]
  [trytond [pyson]]
  [trytond.pool [Pool]])

(defclass HytonTestCase [ModuleTestCase]
  "Test Hyton"
  (setv module "hyton")

  #@((with_transaction)
     (defn test-gets [self]
       (setv [User] (gets (Pool) ["res.user"]))
       (.assertEqual self 1 1)))

  #@((with_transaction)
      (defn test-last-day-month-2021-1-29-fix [self]
        (.assertEqual self
          (date-last-day-month (datetime.date 2021 1 29))
          (datetime.date 2021 1 31))))

  #@((with_transaction)
      (defn test-add-depends [self]
        (.assertEqual self
                      (. (common-fields.Company) depends)
                      []
                      )
        (.assertEqual self
                      (. (common-fields.add-depends
                           (common-fields.Company)
                                  ["hola"])
                         depends)
                      ["hola"]
                      )

        (.assertEqual self
                      (sorted
                        (.
                          (common-fields.add-depends
                            (common-fields.Company 
                              :depends ["hola" "adeu"]) 
                            ["hola" "goodbye"])
                          depends))
                      (sorted ["hola" "adeu" "goodbye"])
                      )))

  #@((with_transaction)
      (defn test-add-readonly [self]
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
                      ))))

(defn suite []
  (setv suite (.suite trytond.tests.test_tryton))
  (.addTests suite
             (.loadTestsFromTestCase
               (.TestLoader unittest) HytonTestCase))
  suite)
