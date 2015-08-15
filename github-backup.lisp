(defpackage #:github-backup
  (:use :cl)
  (:export :main))

(in-package #:github-backup)

(defvar *token*)
(defvar *orgs*)

(defun main (&rest args)
  (declare (ignore args))
  (setf *token* (uiop:getenv "PERSONAL_ACCESS_TOKEN"))
  (setf *orgs* (cl-ppcre:split "," (uiop:getenv "ORGS")))
  (let ((archive-name (cl-ppcre:regex-replace-all
                       ":"
                       (format nil
                               "github-archive-~A"
                               (local-time:format-rfc3339-timestring
                                nil
                                (local-time:now)))
                       "-"))
        (repos
         (append
          (get-user-repos)
          (get-orgs-repos *orgs*))))
    (ensure-directories-exist archive-name)
    (dolist (repo repos)
      (format t "Cloning ~A/~A...~%" (repo-owner repo) (repo-name repo))
      (uiop:run-program (format nil "git clone ~A ~A"
                                (repo-url repo)
                                (format nil "~A/~A" archive-name (repo-name repo)))))
    (format t "Archiving everything into ~A...~%" (format nil "~A.tar.gz" archive-name))
    (uiop:run-program (format nil
                              "tar -czf ~A -C ~A ."
                              (format nil "~A.tar.gz" archive-name)
                              archive-name))
    (format t "Cleaning up...~%")
    (cl-fad:delete-directory-and-files archive-name)))

(defun get-repos (url &optional (page 1))
  (format t "~TFetching page ~A...~%" page)
  (multiple-value-bind (response status headers)
      (drakma:http-request (format nil "~A&page=~A" url page)
                           :additional-headers
                           `(("Authorization" . ,(format nil
                                                         "token ~A"
                                                         *token*))))
    (unless (= status 200)
      (format *error-output* "Github didn't return 200. Aborting.~%")
      (uiop:quit -1))
    (let ((response-list (jsown:parse (flexi-streams:octets-to-string response))))
      (if (has-more (drakma:header-value :link headers))
          (append response-list
                  (get-repos url (1+ page)))
          response-list))))

(defun has-more (link)
  (if (cl-ppcre:scan "; rel=\"last\"" link) t nil))

(defun get-user-repos ()
  (format t "Fetching user repositories...~%")
  (get-repos "https://api.github.com/user/repos?type=owner&per_page=100"))

(defun get-orgs-repos (orgs)
  (mapcar #'get-org-repos orgs))

(defun get-org-repos (org)
  (format t "Fetching ~A repositories...~%" org)
  (get-repos (format nil "https://api.github.com/orgs/~A/repos?per_page=100" org)))

(defun repo-owner (repo)
  (jsown:val (jsown:val repo "owner") "login"))

(defun repo-url (repo)
  (jsown:val repo "ssh_url"))

(defun repo-name (repo)
  (jsown:val repo "name"))
