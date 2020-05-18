(import datetime
        pytz
        [trytond.model [fields]]
        [trytond.pool [Pool]])

(setv TIMEZONES  (lfor x pytz.common_timezones (, x x)))

(defn timezones []
  TIMEZONES)

(defn default-timezone []
  ;; TODO maybe attempt to get timezone from user/company if exists
  "Europe/Madrid")


(defn date-today []
  (setv Date (.get (Pool) "ir.date"))
  (.today Date))

(defn datetime-now []
  (datetime.datetime.now))


(defclass DateBoundMixin []
  (setv start-date (.Date fields "Start Date" :required True)
        end-date (.Date fields "End Date")))
