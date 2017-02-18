;; these may be ocaml programs
(defun tomasz-feature-basedir ()
  (shell-command-to-string "echo -n /home/$USER/feature")
  )

buffer-file-name

(defun tomasz-feature-workspace-dir ()
  (shell-command-to-string "echo -n /home/$USER")
  )

(defun tomasz-search ()
  (interactive)
  (helm-do-ag (tomasz-feature-basedir)))

(defun tomasz-search-all ()
  (interactive)
  (helm-do-ag (tomasz-feature-workspace-dir)))

(helm-do-ag nil)

(helm-read-file-name "Search in file(s): "
                     :initial-input "/tmp/")

(defun tomasz-open-file ()
  (interactive)
  (helm-find-files-1 (tomasz-feature-basedir))
  )


(spacemacs/set-leader-keys "saf" 'tomasz-search)
(spacemacs/set-leader-keys "saF" 'tomasz-search-all)

;; options:
;; - search project = sp
;; - search project + select directory = sP
;; - search feature = sf
;; - search feature + select directory = sF
;; - search current directory = sd
;; - search current directory + select directory = sD
