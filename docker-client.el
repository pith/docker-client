;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;                        Docker Client
;;
;; This file provides emacs lisp functions to reach the docker REST API. There is
;; no interactive functions. These functions are intend to be used in UI modes (eg. 
;; helm-docker).
;;
;; /!\ This is still a work in progress don't expect it to work.
;;
;; Configuration:
;;
;; To use this file you have to define the host to request and the container to work with.
;;
;; (defvar docker-host "myhost.lol")
;; (defvar docker-port "8080")
;; 

(require 'url)
(require 'json)

;; Docker ps
(defun dkr/docker-containers ()
  "List docker containers"
  (with-current-buffer 
      (url-retrieve-synchronously (format "http://%s:%s/containers/json" docker-host docker-port))
    (goto-char url-http-end-of-headers)
    (json-read)))

;; Docker inspect
(defun dkr/docker-inspect (containerID) 
  "Return low-level information on the container id"
  (dkr/http-get containerID "json"))

;; Docker top
(defun dkr/docker-top (containerID)
  "List processes running inside the container id"
  (dkr/http-get containerID "top"))

;; Docker logs
(defun dkr/docker-logs (containerID)
  "Get stdout and stderr logs from the container id"
  (dkr/http-get containerID "logs"))

;; Docker changes
(defun dkr/docker-changes (containerID)
  "Inspect changes on container id's filesystem"
  (dkr/http-get containerID "changes"))

(defun dkr/http-get (containerID url)
  "Http GET request"
  (with-current-buffer 
      (url-retrieve-synchronously (format "http://%s:%s/containers/%s/%s" docker-host docker-port containerID url))
    (goto-char url-http-end-of-headers)
    (json-read)))
