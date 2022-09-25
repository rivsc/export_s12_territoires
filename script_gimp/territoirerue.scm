
(script-fu-register "script-fu-territoirerue"
                    "<Image>/File/Create/Territoires/Créer un nom de rue (sept 16)..."
		    "Créer le nom de rue avec la bonne police, taille et glow"
		    "rivsc57"
		    "rivsc57"
		    "2016"
		    ""
		    SF-IMAGE    "Image"         0
        	    SF-DRAWABLE "Layer to blur" 0
		    SF-STRING     _"Text"               "Rue "
		    SF-ADJUSTMENT _"Font size (pixels)" '(35 2 1000 1 10 0 1)
		    SF-FONT       _"Font"               "Open Sans Semi-Bold"
)


(define (script-fu-territoirerue img drawable text
			       size
			       font
				   )
  (let* (
    (text-layer2 (car (gimp-text-layer-new img text font size PIXELS)))
)

  (gimp-image-insert-layer img text-layer2 0 0)
  (gimp-text-layer-set-color text-layer2 "#000000")

  (script-fu-drop-shadow img text-layer2 0 0 5 "#FFFFFF" 100 0)
  (gimp-image-set-active-layer img text-layer2)
  (set! text-layer2 (car (gimp-image-merge-down img text-layer2 CLIP-TO-BOTTOM-LAYER)))

  (script-fu-drop-shadow img text-layer2 0 0 5 "#FFFFFF" 100 0)
  (gimp-image-set-active-layer img text-layer2)
  (set! text-layer2 (car (gimp-image-merge-down img text-layer2 CLIP-TO-BOTTOM-LAYER)))

  (gimp-item-set-name text-layer2 text)

))


;(script-fu-drop-shadow 1 image drawable value value value color value toggle)
