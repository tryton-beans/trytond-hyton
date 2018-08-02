(import
  unitest
  doctest
  trytond.tests.test_tryton
  [trytond.test.test_tryton [ModuleTestCase with_transaction]]
  [trytond.pool [Pool]])

(defclass HytonTestCase [ModuleTestCase]
  "Test Hyton"
  [module "hyton"]


  #@((with_transaction)
     (defn test-gets [self]
       (setv [User] (sugar.gets ["ir.user"]))
       (.assertEquals self 1 2))) )

(defn suite []
  (setv suite (.suite trytond.tests.test_tryton))
  (.addTests suite
             (.loadTestsFromTestCase
               (.TestLoader unittest) HytonTestCase))
  suite)
