;; This file test docker-client.el.
;;
;; Uncomment the following line and the set one of your running container.
;; (defvar container-name "")
;;
;; Then eval these lines one by one.

(require 'docker-client)

(dkr/docker-containers)

(dkr/docker-inspect container-name)

(dkr/docker-top container-name)

(dkr/docker-logs container-name)

(dkr/docker-changes container-name)
