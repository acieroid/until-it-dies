;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10; indent-tabs-mode: nil -*-

(asdf:defsystem until-it-dies
  :version "0.1"
  :description "Until It Dies -- A 2D Game Engine."
  :maintainer "Josh Marchán <sykopomp@sykosomatic.org>"
  :author "Josh Marchán <sykopomp@sykosomatic.org>"
  :licence "MIT"
  :depends-on (until-it-dies.base until-it-dies.graphics until-it-dies.sound))

(cl:defpackage until-it-dies.examples.resource-info
  (:export :*resource-directory*))

(cl:defvar until-it-dies.examples.resource-info:*resource-directory*
  (print (merge-pathnames "examples/res/" *load-truename*)))
