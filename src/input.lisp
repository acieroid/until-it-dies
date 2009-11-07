;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10; indent-tabs-mode: nil -*-

;;;; This file is part of Until It Dies

;;;; input.lisp
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package :until-it-dies)

;;;
;;; Callbacks for GLFW events
;;;
(cffi:defcallback key-hook :void ((key :int) (action :int))
  "Invokes KEY-DOWN or KEY-UP on the active engine, for control keys."
  (unless (<= key 255)
    (continuable
      (funcall (case action
                 (#.uid-glfw:+press+ 'key-down)
                 (#.uid-glfw:+release+ 'key-up))
               *engine* (translate-glfw-control-key key)))))

(cffi:defcallback char-hook :void ((key :int) (action :int))
  "Invokes KEY-DOWN or KEY-UP on the active engine, for character input."
  (continuable
    (funcall (case action
               (#.uid-glfw:+press+ 'key-down)
               (#.uid-glfw:+release+ 'key-up))
             *engine* (code-char key))))

;;;
;;; Control key translation
;;;
(defun glfw-vector-index (keycode)
  ;; This, like some of the following, assumes the input is valid
  (- keycode uid-glfw:+key-special+ 1))

(defvar *glfw-control-keys*
  (make-array (1+ (glfw-vector-index uid-glfw:+key-last+)) :element-type 'keyword)
  "A vector translating the GLFW control key constants to CL keywords")

(defun glfw-keysym-p (symbol)
  (with-accessors ((name symbol-name) (value symbol-value)) symbol
    (and (constantp symbol)             ; <- CLHS that. I love lisp.
         (= 5 (mismatch "+KEY-" name)) ; Is it key-related?
         (or (< uid-glfw:+key-special+ value uid-glfw:+key-last+)
             ;; These bounds aren't too tight... :(
             (and (= value uid-glfw:+key-last+)
                  (not (eq symbol 'uid-glfw:+key-last+)))))))

(defun translate-glfw-keysym-name (symbol)
  (let ((name (subseq (string-trim "+" (symbol-name symbol)) 4)))
    (cond                  ; This function assumes the input is valid!
      ;; This turns KP-DIVIDE into KEYPAD-DIVIDE
      ((= 3 (mismatch "KP-" name))
       (format nil "KEYPAD-~A" (subseq name 3)))
      ;; This turns RCTRL into RIGHT-CONTROL
      ((some (fun (search _ name)) '("ALT" "CTRL" "SHIFT"))
       (format nil "~:[RIGHT~;LEFT~]-~A"
               (char= (char name 0) #\L) (subseq name 1)))
      ;; This turns PAGEUP to PAGE-UP
      ((= 4 (mismatch "PAGE" name))
       (format nil "PAGE-~A" (subseq name 4)))
      ;; Now we get a bit crappy and hardcoded
      ((string= "DEL" name) "DELETE")
      ((string= "ESC" name) "ESCAPE")
      ;; If it doesn't match any special case, just return the name as-is
      (t name))))

(do-external-symbols (symbol :uid-glfw)
  (with-accessors ((name symbol-name) (value symbol-value)) symbol
    (when (glfw-keysym-p symbol)
      (setf (svref *glfw-control-keys* (glfw-vector-index value))
            (intern (translate-glfw-keysym-name symbol) :keyword)))))

(defun translate-glfw-control-key (keycode)
  (svref *glfw-control-keys* (glfw-vector-index keycode)))
