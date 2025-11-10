; extends
; =============================================
; INJECTIONS FOR gohtml (HTML + JS + CSS + gotmpl)
; =============================================

;; Go template: {{ ... }}
((text) @injection.content
  (#match? @injection.content "^\\{\\{.*\\}\\}$")
  (#offset! @injection.content 0 2 0 -2)
  (#set! injection.language "gotmpl")
  (#set! injection.include-children))
