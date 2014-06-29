;;; docker-client.el --- Docker Client for emacs

;; URL: https://github.com/pith/docker-client
;; Created: 16th June 2014
;; Version: 0.1

;; Copyright (C) 2014 Pierre THIROUIN <pierre.thirouin@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Description:

;; This file provides emacs lisp functions to reach the docker REST API. There is
;; no interactive functions. These functions are intend to be used in UI modes (eg.
;; helm-docker).

;; /!\ This is still a work in progress don't expect it to work.

;;; Configuration:

;; To use this file you have to define the host to request and the container to work with.

;;; Code:

;;(defvar docker-host "")
;;(defvar docker-port "")

;;; Dependencies

;; request.el is required (https://github.com/tkf/emacs-request)


;;; Commentary:
;; 

(require 'url)
(require 'json)
(require 'request)

(defvar docker-path (format "http://%s:%s" docker-host docker-port))

;;; Containers

;; Docker ps
(defun dkr/docker-containers ()
  "List docker containers."
  (with-current-buffer
      (url-retrieve-synchronously (format "%s/containers/json?all=1" docker-path))
    (goto-char url-http-end-of-headers)
    (json-read)))

(defun dkr/list-containers (&optional all limit since before size)
  "List containers.

Optional parameters:
-   **ALL** – 1/True/true or 0/False/false, Show all containers.
    Only running containers are shown by default
-   **LIMIT** – Show `limit` last created
    containers, include non-running ones.
-   **SINCE** – Show only containers created since Id, include
    non-running ones.
-   **BEFORE** – Show only containers created before Id, include
    non-running ones.
-   **SIZE** – 1/True/true or 0/False/false, Show the containers
    sizes"
  (request
   (format "%s/containers/json" docker-path)
   :params (if (not (equal "1" nil))
	     '(("all" . all))
	   nil)
   ;; :params '(("all" . all)
   ;; 	       ;; ("limit" . limit)
   ;; 	       ;; ("since" . since)
   ;; 	       ;; ("before" . before)
   ;; 	       ;; ("size" . size)
   ;; 	       )
   :parser 'json-read
   :success (cl-function
	     (lambda (&key data &allow-other-keys)
	       (message "I sent: %S" data)))
   :status-code '((400 . (lambda (&rest _) (message "Bad parameter")))
		  (500 . (lambda (&rest _) (message "Server error"))))
   )
  )

;; Create container
(defun dkr/delete-container (contrainerID &optional name)
  "Create a container.

Optional parameters:
Argument CONTRAINERID container name.
-   **NAME** – Assign the specified name to the container.  Must
    match `/?[a-zA-Z0-9_-]+`."
  (request
   (format "%s/containers/%s" docker-path containerID)
   :type "DELETE"
   :data (when v
	   '(("name" . name)
	     )
	   nil)
   :success (function*
	     (lambda (&key data &allow-other-keys)
	       (message "Delete container: %s" data)))
   :status-code '((404 . (lambda (&rest _) (message "Container not found")))
		  (406 . (lambda (&rest _) (message "Impossible to attach")))
		  (500 . (lambda (&rest _) (message "Server error"))))
   )
  )

;; Docker inspect
(defun dkr/docker-inspect (containerID)
  "Return low-level information on the container id.
Argument CONTAINERID container name."
  (dkr/http-get containerID "json"))

;; Docker top
(defun dkr/docker-top (containerID)
  "List processes running inside the container id.
Argument CONTAINERID container name."
  (dkr/http-get containerID "top"))

;; Docker logs
(defun dkr/docker-logs (containerID)
  "Get stdout and stderr logs from the container id.
Argument CONTAINERID container name."
  (dkr/http-get containerID "logs"))

;; Docker changes
(defun dkr/docker-changes (containerID)
  "Inspect change on container id's filesystem.
Argument CONTAINERID container name."
  (dkr/http-get containerID "changes"))

(defun dkr/http-get (containerID url)
  "Http GET request.
Argument CONTAINERID container name.
Argument URL url path."
  (with-current-buffer
      (url-retrieve-synchronously (format "%s/containers/%s/%s" docker-path containerID url))
    (goto-char url-http-end-of-headers)
    (json-read)))

(defun dkr/start-container (containerID)
  "Start a container.
Argument CONTAINERID container name."
  (request
   (format "%s/containers/%s/start" docker-path containerID)
   :type "POST"
   :success (function*
	     (lambda (&key symbol-status &allow-other-keys)
	       (message "Started container: %s" symbol-status)))))

(defun dkr/stop-container (containerID &optional timeout)
  "Stop a container.

Optional parameter:
-   **t** – number of seconds to wait before killing the container.
Argument CONTAINERID container name.
Optional argument TIMEOUT number of seconds to wait before killing the container."
  (request
   (format "%s/containers/%s/stop" docker-path containerID)
   :type "POST"
   :data (when timeout
	   '(("t" . timeout))
	   nil)
   :success (function*
	     (lambda (&key symbol-status &allow-other-keys)
	       (message "Stopped container: %s" symbol-status)))
   ))

(defun dkr/restart-container (containerID &optional timeout)
  "Restart a container.

Optional parameters:
-   **t** – number of seconds to wait before killing the container.
Argument CONTAINERID container name.
Optional argument TIMEOUT number fo seconds to wait before killing the container."
  (request
   (format "%s/containers/%s/restart" docker-path containerID)
   :type "POST"
   :data (when timeout
	     '(("t" . timeout))
	   nil)
   :success (function*
	     (lambda (&key symbol-status &allow-other-keys)
	       (message "Restart container: %s" symbol-status)))
   :status-code '((404 . (lambda (&rest _) (message "Container not found")))
		  (500 . (lambda (&rest _) (message "Server error"))))
   ))

(defun dkr/kill-container (containerID &optional signal)
  "Kill a container.

Argument CONTAINERID container name.
Optional argument SIGNAL signal to send to the container: integer or string like
\"SIGINT\". When not set, SIGKILL is assumed and the call will waits for the
container to exit."
  (request
   (format "%s/containers/%s/kill" docker-path containerID)
   :type "POST"
   :data (when signal
	     '(("signal" . signal))
	   nil)
   :success (function*
	     (lambda (&key symbol-status &allow-other-keys)
	       (message "Kill container: %s" symbol-status)))
   :status-code '((404 . (lambda (&rest _) (message "Container not found")))
		  (500 . (lambda (&rest _) (message "Server error"))))
   ))

(defun dkr/attach-container (containerID &optional logs stream stdin stdout stderr)
  "Attach a container.

- Argument CONTAINERID container name.
- Optional argument LOGS 1/True/true or 0/False/false, return logs.  Default
false
- Optional argument STREAM 1/True/true or 0/False/false, return stream.
    Default false
- Optional argument STDIN 1/True/true or 0/False/false, if stream=true, attach
    to stdin.  Default false
- Optional argument STDOUT 1/True/true or 0/False/false, if logs=true, return
    stdout log, if stream=true, attach to stdout.  Default false
- Optional argument STDERR 1/True/true or 0/False/false, if logs=true, return
    stderr log, if stream=true, attach to stderr.  Default false"
  (request
   (format "%s/containers/%s/attach" docker-path containerID)
   :type "POST"
;; TODO use add-to-list and when
   :data (when logs
	   '(("logs" . logs)
	     ("stream" . stream)
	     ("stdin" . stdin)
	     ("stdout" . stdout)
	     ("stderr" . stderr)
	     )
	   nil)
   :success (function*
	     (lambda (&key symbol-status &allow-other-keys)
	       (message "Attach container: %s" symbol-status)))
   :status-code '((404 . (lambda (&rest _) (message "Container not found")))
		  (500 . (lambda (&rest _) (message "Server error"))))
   ))

(defun dkr/wait-container (containerID)
  "Wait a container.
Argument CONTAINERID container name."
  (request
   (format "%s/containers/%s/wait" docker-path containerID)
   :type "POST"
   :success (function*
	     (lambda (&key data &allow-other-keys)
	       (message "Wait container: %s" data)))
   :status-code '((404 . (lambda (&rest _) (message "Container not found")))
		  (500 . (lambda (&rest _) (message "Server error"))))
   ))

(defun dkr/delete-container (&optional v force)
  "Create a container.

Optional parameters:
-   **V** – 1/True/true or 0/False/false, Remove the volumes
    associated to the container.  Default false
-   **FORCE** – 1/True/true or 0/False/false, Removes the container
    even if it was running.  Default false"
  (request
   (format "%s/containers" docker-path)
   :type "POST"
   :data (when v
	   '(("v" . v)
	     ("force" . force)
	     )
	   nil)
   :success (function*
	     (lambda (&key data &allow-other-keys)
	       (message "Create container: %s" data)))
   :status-code '((400 . (lambda (&rest _) (message "Bad parameter")))
		  (404 . (lambda (&rest _) (message "Container not found (container not running)")))
		  (500 . (lambda (&rest _) (message "Server error"))))
   )
  )

;;POST /containers/(id)/copy

;;; Images

(provide 'docker-client)
;; docker-client.el ends here

(provide 'docker-client)

;;; docker-client.el ends here
