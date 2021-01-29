(import
  unittest
  datetime
  doctest
  trytond.tests.test_tryton
  [trytond.tests.test_tryton [ModuleTestCase with_transaction]]
  [trytond.modules.hyton.sugar [gets]]
  [trytond.modules.hyton.date [date-last-day-month]]
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
  )

(defn suite []
  (setv suite (.suite trytond.tests.test_tryton))
  (.addTests suite
             (.loadTestsFromTestCase
               (.TestLoader unittest) HytonTestCase))
  suite)
