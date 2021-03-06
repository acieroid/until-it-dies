;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10; indent-tabs-mode: nil -*-

(asdf:defsystem until-it-dies.base
  :version "0.1"
  :description "Until It Dies -- A 2D Game Engine."
  :maintainer "Josh Marchán <sykopomp@sykosomatic.org>"
  :author "Josh Marchán <sykopomp@sykosomatic.org>"
  :licence "MIT"
  :depends-on (cl-opengl glop alexandria)
  :serial t
  :components
  ((:module "src"
            :components
            ((:file "packages")
             (:module "util"
                      :depends-on ("packages")
                      :components
                      ((:file "opengl-hacks")
                       (:file "queue")
                       (:file "priority-queue")
                       (:file "finalizers")
                       (:file "split-sequence")
                       (:file "utils")))
             (:file "clock" :depends-on ("util"))
             (:file "colors" :depends-on ("util"))
             (:file "primitives" :depends-on ("colors"))
             (:file "resources" :depends-on ("util"))
             (:file "view" :depends-on ("util"))
             (:file "window" :depends-on ("util" "view" "colors"))
             (:file "engine" :depends-on ("util" "window" "clock"))))))
