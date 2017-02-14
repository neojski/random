(helm-find-files-1 (shell-command-to-string "echo -n /home/$USER"))

(defun tomasz-search ()
  (interactive)
  (print "search")
  (helm-do-ag (shell-command-to-string "echo -n /home/$USER")))

(defun tomasz-search-all ()
  (interactive)
  (print "search-all")
  (helm-do-ag (shell-command-to-string "echo -n /")))

(spacemacs/set-leader-keys "saf" 'tomasz-search)
(spacemacs/set-leader-keys "saF" 'tomasz-search-all)
