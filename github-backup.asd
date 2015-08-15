(asdf:defsystem :github-backup
  :depends-on (:drakma :flexi-streams :jsown :cl-ppcre :local-time :cl-fad)
  :components ((:file "github-backup")))
