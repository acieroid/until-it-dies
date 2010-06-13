;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10; indent-tabs-mode: nil -*-

(asdf:defsystem until-it-dies
  :version "0.1 (unreleased)"
  :description "Until It Dies -- A 2D Game Engine."
  :maintainer "Josh Marchán <sykopomp@sykosomatic.org>"
  :author "Josh Marchán <sykopomp@sykosomatic.org>"
  :licence "MIT"
  :depends-on (until-it-dies.base))

(cl:defpackage until-it-dies.demo.resource-info
  (:export :*resource-directory*))

(cl:defvar until-it-dies.demo.resource-info:*resource-directory*
  (print (merge-pathnames "demo/res/" *load-truename*)))

(asdf:defsystem until-it-dies.examples
  :version "0.1 (unreleased)"
  :description "Examples for Until It Dies -- A 2D Game Engine"
  :maintainer "Josh Marchán <sykopomp@sykosomatic.org>"
  :author "Josh Marchán <sykopomp@sykosomatic.org>"
  :licence "MIT"
  :depends-on (until-it-dies)
  :components
  ((:module "demo" :components
            ((:file "testgame")))))
