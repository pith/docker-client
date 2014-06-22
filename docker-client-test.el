;;; docker-client-test.el --- Tests docker-client.el

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

;; Uncomment the following line and the set one of your running container.
;; (defvar container-name "")

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
