(import datetime
        pytz
        [datetime [timedelta]]
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

(defn date-first-day-month [date]
  (.replace date :day 1))

(defn date-last-day-month [date]
  (setv month date.month)
  (if (= 12 date.month)
      (.replace date :day 31);;december
      (->
        (.replace date :month (inc month))
        (date-first-day-month)
        (- (timedelta :days 1)))))

(defclass DateBoundMixin []
  (setv start-date (.Date fields "Start Date" :required True)
        end-date (.Date fields "End Date")))
