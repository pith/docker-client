;; This file test docker-client.el.
;;
;; Uncomment the following line and the set one of your running container.
;; (defvar container-name "")
;;
;; Then eval these lines one by one.

(require 'docker-client)

;; Gets
(dkr/docker-containers)

(dkr/docker-inspect container-name)

(dkr/docker-top container-name)

(dkr/docker-logs container-name)

(dkr/docker-changes container-name)

;; Posts
(dkr/start-container container-name)

(dkr/stop-container container-name) ;message: "Stop container: success"

(dkr/stop-container container-name "10") ;message: "Stop container: success"

(dkr/stop-container "zzz") ;message: "Container not found"
