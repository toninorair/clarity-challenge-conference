;; Conference smart contract - selling tickets, checking ticket validity and conference time 
(define-map conference-owners ((id int)) ((owner principal)))
(define-map conference-start ((id int)) ((start-time uint)))
(define-map conference-end ((id int)) ((end-time uint)))
(define-map conference-price ((id int)) ((ticket-price uint)))

;; conference non-fungible tokens, proof of payment and ticket ownership
(define-fungible-token conference-tickets)

;; initiate new conference and set default parameters
(define-private (add-conference 
  (conference-id int) 
  (start uint) 
  (duration uint)
  (price uint)
  (conference-owner principal))
 (begin
  (map-insert conference-owners ((id conference-id)) ((owner conference-owner)))
  (map-insert conference-start ((id conference-id)) ((start-time start)))
  (map-insert conference-end ((id conference-id)) ((end-time (+ start duration))))
  (map-insert conference-price ((id conference-id)) ((ticket-price price)))
  (ok true)))

;; checks that conference is active, is used for other checks
(define-private (is-active (conference-id int))
   (and 
     (>= 
       block-height
       (default-to (+ block-height u1) (get start-time (map-get? conference-start (tuple (id conference-id)))))
     )
     (<= 
       block-height
       (default-to u0 (get end-time (map-get? conference-end (tuple (id conference-id)))))
      )))

  ;; checks that conference has not ended yet
  (define-private (has-ended (conference-id int))
     (> 
       block-height
       (unwrap-panic (get end-time (map-get? conference-end (tuple (id conference-id)))))
     ))

  ;; checks that conference has started
  (define-private (has-started (conference-id int))
     (> 
       block-height
       (default-to u0 (get start-time (map-get? conference-start (tuple (id conference-id)))))
     ))

  ;; public method for initializing new conference
  (define-public (init-conference
    (conference-id int) 
    (start uint) 
    (duration uint)
    (price uint)
    (tickets-num uint))
    ;;ADD checks here
    (begin
      (ft-mint? conference-tickets tickets-num tx-sender)
      (add-conference conference-id start duration price tx-sender)
      (ok true)))

  ;; buying ticket for conference
  (define-public (buy-ticket (conference-id int) (participant principal))
    (if (and (not (has-started conference-id)) (not (has-ended conference-id)))
     (begin
       (ft-transfer? 
         conference-tickets 
         u1
         tx-sender
         participant)
      (ok true))
      (err false)))

  ;; entering conference
  (define-public (enter-conference (conference-id int))
    (if (is-active conference-id)
      (if (> (ft-get-balance conference-tickets tx-sender) u0)
        (ok true)
        (err false))
      (err false)
    ))


    

  
     