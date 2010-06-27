(asdf:defsystem until-it-dies.examples
  :version "0.1"
  :description "Examples for Until It Dies -- A 2D Game Engine"
  :maintainer "Josh Marchán <sykopomp@sykosomatic.org>"
  :author "Josh Marchán <sykopomp@sykosomatic.org>"
  :licence "MIT"
  :depends-on (until-it-dies)
  :components
  ((:module "examples" :components
            ((:file "basic")
             (:file "text")
             (:file "image")
             #+nil(:file "multi-window")
             (:file "basic-no-subclass")))))
