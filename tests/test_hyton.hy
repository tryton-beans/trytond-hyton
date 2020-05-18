(import
  unittest
  doctest
  trytond.tests.test_tryton
  [trytond.tests.test_tryton [ModuleTestCase with_transaction]]
  [trytond.modules.hyton.sugar [gets]]
  [trytond.pool [Pool]])

(defclass HytonTestCase [ModuleTestCase]
  "Test Hyton"
  (setv module "hyton")


  #@((with_transaction)
     (defn test-gets [self]
       (setv [User] (gets (Pool) ["res.user"]))
       (.assertEqual self 1 1))) )

(defn suite []
  (setv suite (.suite trytond.tests.test_tryton))
  (.addTests suite
             (.loadTestsFromTestCase
               (.TestLoader unittest) HytonTestCase))
  suite)
