#lang racket
;whole division
(define (divide n d)
  (cond ((> d n ) 0 )
  (else
  (+ 1 (divide (- n d) d)))))

; following two func. find binary number from decimal (solved in class) 
(define (decimal-to-binary-iter counter binary-number n)
  (cond ((= counter 0) binary-number)
  (else ( decimal-to-binary-iter (divide counter 2 ) (cons (modulo counter 2) binary-number) n))))

(define (decimal-to-binary number)
  (decimal-to-binary-iter number '() number))

;Next two functions parse the number -> (123) (1 2 3)
(define (add-to-list-helper number lst)
 (cond((= number 0 ) lst)
  (else (add-to-list-helper (/ (- number (modulo number 10 )) 10) (cons (modulo number 10) lst))) ))



(define (add-to-list number)
  (add-to-list-helper number '() ))

;Calculate decimal value of any base number coef parameter for represent the base
(define (iter-list lst coef counter)
  (cond ((null? lst) 0 )
  (else (+ (* (car lst) (expt coef counter)) (iter-list (cdr lst) coef (- counter 1)))
  )))

;Conversion from octal to decimal by using previous func
(define (octal-to-decimal number)
  
  (iter-list (add-to-list number) 8 (- (length(add-to-list number)) 1))
  )


;Word iter functions divide strings characters into a list .Used for hexadecimal number
(define (word-iter-helper word counter lst)
  (word-iter word (- counter 1) lst)
  )
(define (word-iter word counter lst)
  (cond ((= counter 0) (cons (string-ref word counter)lst ))
  (else (word-iter-helper word counter (cons (string-ref word counter)lst)
  ))))


;As the same idea with converting decimal to binary ,bu this time we divide 8
(define (decimal-to-octal-iter counter binary-number n)
  (cond ((= counter 0) binary-number)
  (else ( decimal-to-octal-iter (divide counter 8 ) (cons (modulo counter 8) binary-number) n))))

(define (decimal-to-octal number)
  (decimal-to-octal-iter number '() number))
;Using pre defined function first we convert to decimal then convert to octal
(define (binary-to-octal number)
  (decimal-to-octal (binary-to-decimal number))
  )

(define (octal-to-binary number)
  (iter-list (decimal-to-binary(octal-to-decimal number)) 10 (- (length(decimal-to-binary(octal-to-decimal number))) 1))
  )
(define (binary-to-decimal number)
  (iter-list (add-to-list number) 2 (- (length(add-to-list number)) 1))
  
  )
;This function used for searching elemnt into given list
(define (search-in-list inp list  counter)
  (cond ((= counter 0) -1)
        ((equal?(car list) inp)counter)
        (else (search-in-list inp (cdr list) (- counter 1))))

  )

(define (search inp list  counter)
  (cond ((= counter 0) -1)
        ((equal?(car list) inp)counter)
        (else (search-in-list inp (cdr list) (- counter 1))))

  )
;;backward

;string seperator func for hexadecimalnumbers
(define (string-sep-helper string-input counter lst)
  (cond((< counter 0) lst )
  (else (string-sep-helper string-input (- counter 1) (cons(string-ref string-input (- (-(string-length string-input)1) counter))lst))
  )))
(define (string-sep string-input)
  (string-sep-helper string-input (- (string-length string-input) 1) '())

  )
;To make conversion with binary and hexadecimal I decided to store 2 list like a dictionary add by position
;function find the match elment location and thanks to this location find corresponding hexadecimal value and append to output list 
(define (add-by-position position list)
  (list-ref list (- (length list) position)
  ))

(define(hexadecimal-to-binary-helper list-hexa list-bin list-input listoutput) 
  (cond((null? list-input)listoutput)
       (else (hexadecimal-to-binary-helper list-hexa list-bin (cdr list-input) (cons(add-by-position(search-in-list(car list-input) list-hexa (length list-bin))list-bin)listoutput))
  )))

(define (hexadecimal-to-decimal number)
  (let ((lst-hex (list #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9 #\A #\B #\C #\D #\E #\F))(lst-bin (list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15))     
    )
    (iter-list (hexadecimal-to-binary-helper lst-hex lst-bin (string-sep number) '()) 16 (-(length(hexadecimal-to-binary-helper lst-hex lst-bin (string-sep number) '()))1))
    )
  )
;previous functions feeds eachother
(define(hexadecimal-to-binary number)
  (decimal-to-binary(hexadecimal-to-decimal number))
  )
(define (hexadecimal-to-octal number)
  (decimal-to-octal(hexadecimal-to-decimal number))

  )
(define (decimal-to-hexadecimal-helper-2 counter binary-number n)
  (cond ((< counter 16) (cons counter binary-number))
  (else ( decimal-to-hexadecimal-helper-2 (divide counter 16 ) (cons (modulo counter 16) binary-number) n))))

(define (search-lst inp list  counter)
  (cond ((= counter 0) -1)
        ((=(car list) inp)counter)
        (else (search-in-list inp (cdr list) (- counter 1))))

  )
(define (decimal-to-hexadecimal-helper lst-hexa lst-bin input output counter)
  (cond((null? input)output)
       ((= counter 0) output)
       (else (decimal-to-hexadecimal-helper lst-hexa lst-bin  (cdr input) (cons(list-ref lst-hexa(- 16 ( search-in-list (list-ref  input 0) lst-bin (length lst-bin))) )output)(length input))))

  )
;This function works for make the list backward
(define (convert-list-back list outlist)
  (cond((null? list)outlist)
       (else (convert-list-back (cdr list) (cons (car list) outlist)))))
(define(decimal-to-hexadecimal number)
  (let ((lst-hex (list #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9 #\A #\B #\C #\D #\E #\F))(lst-bin (list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15))     
    )
    (convert-list-back (decimal-to-hexadecimal-helper lst-hex lst-bin (decimal-to-hexadecimal-helper-2 number '() number) '() (length (decimal-to-hexadecimal-helper-2 number '() (-(length (decimal-to-hexadecimal-helper-2 number '() number))1))))
  '())))

(define (binary-to-hexadecimal number)
  (decimal-to-hexadecimal(binary-to-decimal number))
  )
(define (octal-to-hexadecimal number)
  (decimal-to-hexadecimal (octal-to-decimal number))
  )
#|
;;TEST_FROM_BINARY

(binary-to-octal 111)
(binary-to-decimal 111)
(binary-to-hexadecimal 11111)

;;TEST_FROM_OCTAL

(octal-to-binary 3452)
(octal-to-decimal 3452)
(octal-to-hexadecimal 3452)

;;TEST_FROM_DECIMAL

(decimal-to-binary 145)
(decimal-to-octal 145)
(decimal-to-hexadecimal 145)

;;TEST_FROM_HEXADECIMAL

(hexadecimal-to-binary "A1234")
(hexadecimal-to-octal "ABC")
(hexadecimal-to-decimal "A123")

|#
;Works when user enter base as 2
(define (conv-from-base-2 target number)
          (cond((equal? target 8) (binary-to-octal number))
               ((equal? target 10) (binary-to-decimal number))
               ((equal? target 16) (binary-to-hexadecimal number))
  

                ))
;Works when user enter base as 8
(define (conv-from-base-8 target number)
          (cond ((equal? target 2) (octal-to-binary number))
          ((equal? target 10) (octal-to-decimal number))
          ((equal? target 16) (octal-to-hexadecimal number))
          ))
;Works when user enter base as 10
(define (conv-from-base-10 target number)
          (cond ((equal? target 2) (decimal-to-binary number))
          ((equal? target 8) (decimal-to-octal number))
          ((equal? target 16) (decimal-to-hexadecimal number))
          ))
;Works when user enter base as 16
(define (conv-from-base-16 target number)
          (cond ((equal? target 2) (hexadecimal-to-binary number))
          ((equal? target 10) (hexadecimal-to-decimal number))
          ((equal? target 8) (hexadecimal-to-octal number))
          ))

;CONVERTER FUNCTION
(define (converter init-base target-base number)
  (cond ((equal? init-base 2)(conv-from-base-2 target-base number))
        ((equal? init-base 8) (conv-from-base-8 target-base number))
        ((equal? init-base 10) (conv-from-base-10 target-base number))
        ((equal? init-base 16) (conv-from-base-16 target-base number))


        ))
;Some test value
;Please enter hexadecimal number as a string 
(converter 2 10 1111)              
(converter 8 10 1111)
(converter 10 16 3453)