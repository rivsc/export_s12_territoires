(define (changetransparent fname-one number outputfilename)
    (let* (
	    ; fname-one : fichier xcf
	    ; outputfilename : nom du fichier de sortie
            ; first main image
            (image (car (gimp-file-load RUN-NONINTERACTIVE fname-one fname-one)))
            ; them layer
            (calquename "terr_couche_2.png")
            ;(calquenameext (car (string-append calquename ".png"))) 
            (drawable3 (car (gimp-image-get-layer-by-name image calquename)))
        )

        ; Vire la transparence du calque
	(plug-in-threshold-alpha RUN-NONINTERACTIVE image drawable3 0)

	; Change l'opacité du calque
	(gimp-layer-set-opacity drawable3 20)
	
	; save xcf
        (gimp-file-save RUN-NONINTERACTIVE image image outputfilename outputfilename)
    )
)

; Pour le lancer : gimp --no-interface --batch='(changetransparent "S12_001_normal.xcf" "001" "S12_001_testscl.xcf")' -b '(gimp-quit 0)'
