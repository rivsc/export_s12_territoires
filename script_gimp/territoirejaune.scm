(define (territoirejaune fname-one outputfilename)
    (let* (
	    ; fname-one : fichier xcf
	    ; outputfilename : nom du fichier de sortie
            ; first main image
            (image (car (gimp-file-load RUN-NONINTERACTIVE fname-one fname-one)))
            ; them layer
            (drawable1 (car (gimp-image-get-layer-by-name image "Arrière-plan")))
            (drawable2 (car (gimp-image-get-layer-by-name image "FONDU_CARTE2")))
            (drawable3 (car (gimp-image-get-layer-by-name image "terr_couche_1.png")))
        )
        
	; Rends visible l'arrière plan
	(gimp-layer-set-visible drawable1 TRUE)

        ; Coloris en jaune (le fondu et l'arrière plan)
	(plug-in-colorify RUN-NONINTERACTIVE image drawable1 "yellow")
	(plug-in-colorify RUN-NONINTERACTIVE image drawable2 "yellow")
	; Lum / contraste plan
	(gimp-brightness-contrast drawable3 -88 88)

	; merge layers (seulement pour png)
	;(gimp-image-flatten image) 

        ; save xcf
        (gimp-file-save RUN-NONINTERACTIVE image image outputfilename outputfilename)
        ; save png
	;(file-png-save RUN-NONINTERACTIVE image image outputfilename outputfilename FALSE 9 FALSE FALSE FALSE TRUE TRUE)
    )
)

; Pour le lancer : cd testgimpterr/territoire_001 && gimp --no-interface --batch='(territoirejaune "S12_001.xcf" "S12_001_campagne.xcf")' -b '(gimp-quit 0)'
