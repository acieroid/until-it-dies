;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10; indent-tabs-mode: nil -*-

;;;; This file is part of Until It Dies

;;;; drawable.lisp
;;;;
;;;; Basic drawable objects
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package :until-it-dies)

;;;
;;; Drawable base
;;;
(defclass drawable () ())

(defgeneric draw (drawable &key))

(defun draw-at (x y obj &rest all-keys)
  (apply #'draw obj :x x :y y all-keys))

;;;
;;; Sprite
;;;
(defclass sprite (drawable) 
  ()
  (:documentation "Sprites are 2D drawable objects."))

;;;
;;; Textured
;;;
(defclass textured (drawable)
  ((texture :initarg :texture :accessor texture))
  (:documentation "Not to be confused with TEXTURE; TEXTURED is a mixin that provides
facilities for drawing textures."))

(defmethod initialize-instance :after ((textured textured) &key texture-filepath)
  (cond (texture-filepath
         (setf (texture textured)
               (make-instance 'file-texture :filepath texture-filepath)))
        ((not (slot-boundp textured 'texture))
         (error "Textured objects must be given a texture."))
        (t nil)))

(defgeneric calculate-tex-coords (textured))

;;;
;;; Image
;;;
(defclass image (sprite textured)
  ()
  (:documentation "Images are 2d sprites with textures drawn on them."))

;; Can't resize them right now. Just pull in the image's dimensions.
(defmethod height ((image image))
  (height (texture image)))
(defmethod width ((image image))
  (width (texture image)))

(defmethod calculate-tex-coords ((image image))
  (vector 0 0 1 1))

(defmethod draw :before ((image image) &key)
  "Before we a draw textured sprite, we should bind its texture."
  (gl:enable :texture-2d :blend)
  (gl:blend-func :src-alpha :one-minus-src-alpha)
  (when (texture image)
    (bind-texture (texture image))))

(defmethod draw ((image image)
                 &key x y x-scale y-scale
                 rotation (z 0) (x-offset 0) (y-offset 0))
  (let ((x (+ x x-offset))
        (y (+ y y-offset))
        (tex-coords (calculate-tex-coords image))
        (height (height image))
        (width (width image)))
    (when tex-coords
      (gl:with-pushed-matrix
        (gl:translate x y z)
        (when rotation
          (gl:rotate (- rotation) 0 0 1))
        (draw-rectangle 0 0 (* width (or x-scale 1)) (* height (or y-scale 1)) :z z
                        :u1 (elt tex-coords 0)
                        :v1 (elt tex-coords 1)
                        :u2 (elt tex-coords 2)
                        :v2 (elt tex-coords 3))))))

(defmethod draw :after ((image image) &key)
  "Once we're done drawing it, we should unbind the texture."
  (unbind-texture (texture image))
  (gl:disable :texture-2d))

;;;
;;; Animation
;;;
(defclass animation (image)
  ((current-frame :initform 0 :initarg :current-frame :accessor current-frame)
   (num-frames :initarg :num-frames :accessor num-frames)
   (frame-delay :initarg :frame-delay :accessor frame-delay)
   (frame-width :initarg :frame-width :accessor frame-width)
   (frame-height :initarg :frame-height :accessor frame-height)
   (frame-step :initform 1 :initarg :frame-step :accessor frame-step)
   (timer :initform 0 :accessor timer)
   (animation-type :initform :loop :initarg :type :accessor animation-type))
  (:documentation
  "Animations are like images, but they use the provided texture
as a sprite sheet. Based on certain provided parameters, they
figure out which frames to draw."))

(defmethod height ((animation animation))
  (frame-height animation))
(defmethod width ((animation animation))
  (frame-width animation))

(defmethod on-update ((animation animation) dt)
  ;; TODO - this needs to update an animation properly regardless of framerate.
  ;;        That probably means that frames should sometimes be skipped.
  (with-accessors ((timer timer) (num-frames num-frames)
                   (current-frame current-frame) (frame-delay frame-delay)
                   (animation-type animation-type) (frame-step frame-step))
      animation
    (incf timer dt)
    (when (> timer frame-delay)
      (setf timer 0)
      (case animation-type
        (:loop
         (incf current-frame frame-step)
         (when (or (> current-frame (1- num-frames))
                   (< current-frame 0))
           (setf current-frame 0)))
        (:bounce
         (incf current-frame frame-step)
         (when (or (= current-frame num-frames)
                   (= current-frame 0))
           (setf frame-step (* -1 frame-step)))
         (when (or (> current-frame num-frames)
                   (< current-frame 0))
           (setf current-frame 0)))
        (:once
         (unless (= current-frame num-frames)
           (incf current-frame frame-step))
         (when (or (> current-frame num-frames)
                   (< current-frame 0))
           (setf current-frame 0)))))))

(defmethod calculate-tex-coords ((animation animation))
  (with-accessors ((current-frame current-frame) (num-frames num-frames)
                   (frame-width frame-width) (frame-height frame-height)
                   (texture texture))
      animation
    (with-accessors ((tex-height height) (tex-width width))
        texture
      (when (loadedp texture)
        (vector (/ (* (1- current-frame) frame-width) tex-width)
                0 (/ (* current-frame frame-width) tex-width) (/ frame-height tex-height))))))

;;;
;;; Text prototype
;;;
(defclass text (sprite)
  ((string-to-draw :initform "Hello World" :initarg :string :accessor string-to-draw)))

(defmethod draw ((string string)
                 &key x y x-scale y-scale
                 rotation (font *font*)
                 (z 0) (x-offset 0) (y-offset 0))
  (unless (loadedp font)
    (load-resource font))
  (gl:with-pushed-matrix
    (let ((x (+ x x-offset))
          (y (+ y y-offset)))
      (gl:translate x y z)
      (when rotation
        (gl:rotate (- rotation) 0 0 1))
      (gl:scale (or x-scale 1) (or y-scale 1) 1)
      (draw-string (font-pointer font) string :size (size font)))))

(defmethod draw ((text text)
                 &key x y (width 100) (height 100)
                 x-scale y-scale
                 rotation (wrap t) (align :left) (valign :bottom)
                 (font *font*) (z 0)
                 (x-offset 0) (y-offset 0))
  (unless (loadedp font)
    (load-resource font))
  (gl:with-pushed-matrix
    (let ((x (+ x x-offset))
          (y (+ y y-offset)))
      (gl:translate x y z)
      (when rotation
        (gl:rotate (- rotation) 0 0 1))
      (gl:scale (or x-scale 1) (or y-scale 1) 1)
      (mapc #'(lambda (line)
                (draw-at (units->pixels (first line) (font-pointer font) (size font))
                         (units->pixels (second line) (font-pointer font) (size font))
                         (third line) :font font))
            (format-text (string-to-draw text)
                         :width width
                         :height height
                         :font font
                         :wrap wrap
                         :align align
                         :valign valign)))))
