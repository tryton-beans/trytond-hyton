(import [trytond.pool [Pool]]
        [trytond.modules.hyton.sugar [save]])

(defn create-model [model-name &rest args &kwargs kwargs]
  ((.get (Pool) model-name)
    #* args #** kwargs))

(defn create-save-model [model-name &rest args &kwargs kwargs]
  (save
    (create-model model-name #* args #** kwargs)))
