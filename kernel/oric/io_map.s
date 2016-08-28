		;; memory map
		;; tells mpalloc and spalloc which pages are not available in
		;; "no I/O" mode
		
io_map:	.byte $ef,$ff,$ff,$ff	; $0000-$1fff (page 3 is I/O)
		.byte $ff,$ff,$ff,$ff	; $2000-$3fff
		.byte $ff,$ff,$ff,$ff	; $4000-$5fff
		.byte $ff,$ff,$ff,$ff	; $6000-$7fff
		.byte $ff,$ff,$ff,$ff	; $8000-$9fff
		.byte $ff,$ff,$ff,$ff	; $a000-$bfff
		.byte $ff,$ff,$ff,$ff	; $c000-$dfff
		.byte $ff,$ff,$ff,$ff	; $e000-$ffff

