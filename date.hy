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

(defn date-first-day-year [date]
  (.replace (.replace date :day 1) :month 1)
  )

(defn date-first-day-current-year []
  (.replace (.replace (datetime.date.today) :day 1) :month 1))

(defn plus-days [dt-time days]
  (+ dt-time (timedelta :days days)))

(defn next-day [dt-time]
  (plus-days dt-time 1))

(defn skip-weekend [dt-time]
  (setv wkday (.weekday dt-time))
  (if (or(= wkday 5) (= wkday 6))
      (skip-weekend (next-day dt-time))
      dt-time))

(defn plus-days-weekday [dt-time days]
  (skip-weekend (plus-days dt-time days)))

(defclass DateBoundMixin []
  (setv start-date (.Date fields "Start Date" :required True)
        end-date (.Date fields "End Date")))
