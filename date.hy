(import [datetime]
        [pytz]
        [trytond.pool [Pool]])

(setv TIMEZONES  (list-comp (, x x)  [x pytz.common_timezones]))

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


