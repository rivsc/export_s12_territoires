(define (filtrecommercant fname-one outputfilename commlayer)
    (let* (
	    ; fname-one : fichier xcf
	    ; outputfilename : nom du fichier de sortie
            ; first main image
            (image (car (gimp-file-load RUN-NONINTERACTIVE fname-one fname-one)))
            ; them layer
	    (drawable1 (car (gimp-file-load-layer RUN-NONINTERACTIVE image commlayer))) ;layer commercant
        )
        
	; Ajoute le calque
        (gimp-image-insert-layer image drawable1 0 0)
	;(gimp-image-lower-item image drawable1)

	; merge layers (seulement pour png)
	(set! drawable1 (car (gimp-image-flatten image)))
	
        ; save png
	(file-png-save RUN-NONINTERACTIVE image drawable1 outputfilename outputfilename FALSE 9 FALSE FALSE FALSE TRUE TRUE)
    )
)

; Pour le lancer : cd testgimpterr/territoire_001 && gimp --no-interface --batch='(filtrecommercant "S12_001_normal.png" "S12_001_normal_com.png" "commercant.png")' -b '(gimp-quit 0)'
; Pour le lancer : cd testgimpterr/territoire_001 && gimp --no-interface --batch='(filtrecommercant "S12_001_normal.png" "S12_001_normal.png" "pas_commercant.png")' -b '(gimp-quit 0)'
