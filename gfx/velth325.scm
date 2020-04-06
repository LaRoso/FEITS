;----------script-fu-set-all-layers-invisible----------
;procedure by Hevan53
;------------------------------------------------------

(define (script-fu-set-all-layers-invisible inImage inDrawable)
        (let*  (
                (layers (gimp-image-get-layers inImage))
                (num-layers (car layers))
                (layer-array (cadr layers))
                (theLayer)
               )

        (gimp-image-undo-group-start inImage)

        (while (> num-layers 0)
                (set! num-layers (- num-layers 1))
                (set! theLayer (aref layer-array num-layers))
                (if (= (car (gimp-drawable-get-visible theLayer) ) TRUE)
					(gimp-drawable-set-visible theLayer FALSE)
                )
        )

        (gimp-image-undo-group-end inImage)
        (gimp-displays-flush)

        )
)

;--------------------save-layers-----------------------
;procedure by planetmaker
;
; // List of source and target images followed by a list of layer names
; // in the source image which will make up the target image.
;
; // Example:
; // (save-layers "source-file-name" "target-file-name" '(layername1 layername2 layername3 ...))
;------------------------------------------------------
(define
	(
		save-layers

		inImageName
		outImageName
		inLayerNames
	)
	(let*
		(
			(image (car (gimp-file-load RUN-NONINTERACTIVE inImageName inImageName)))
			(visibleStuff (car (gimp-image-get-active-layer image)))
        	(layers (gimp-image-get-layers image))
        	(num-layers (car layers))
        	(layer-array (cadr layers))
        	(thisLayer -1)
			(thisNumLayers 0)
			(theseLayers layers)
			(thisLayerName 0)

			(layerNames inLayerNames)
		)

		; First make everything invisble
		(script-fu-set-all-layers-invisible image image)

		; Now make those layers visible which were asked to become visible

		; iterate through all layers of the image
		(while (> num-layers 0)
			(set! num-layers (- num-layers 1))
            (set! thisLayer (aref layer-array num-layers))
			(set! thisLayerName (car (gimp-drawable-get-name thisLayer)))
			; (gimp-message (string-append "Image Layer-Name: " thisLayerName))

			; iterate through all layer Names we shall use
			(set! layerNames inLayerNames)
			(while (not (null? layerNames))
				; if layerName matches this user supplied layername: make it visible
				(if (string=? (car layerNames) thisLayerName)
					(gimp-drawable-set-visible thisLayer TRUE)
				)
				(set! layerNames (cdr layerNames))
			)
		)

		; Merge all visible layers into one layer which we then save to the given filename
		(set! visibleStuff (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))
		(file-png-save RUN-NONINTERACTIVE image visibleStuff outImageName outImageName 0 9 0 0 0 0 0)
		(gimp-image-delete image)
	)
)


; // ===================================================================
; // List of source and target images followed by a list of layer names
; // in the source image which will make up the target image.
; // Example:
; // (save-layers "source-file-name" "target-file-name" '(layername1 layername2 layername3 ...))
; // ===================================================================
(gimp-quit 0)
