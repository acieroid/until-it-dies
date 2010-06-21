(asdf:defsystem until-it-dies.sound
  :version "0.1"
  :description "Until It Dies -- Sound module."
  :maintainer "Josh Marchán <sykopomp@sykosomatic.org>"
  :author "Josh Marchán <sykopomp@sykosomatic.org>"
  :licence "MIT"
  :depends-on (until-it-dies.base cl-openal)
  :components
  ((:module "src"
            :components
            ((:module "sound"
                      :components
                      ((:file "sounds")))))))