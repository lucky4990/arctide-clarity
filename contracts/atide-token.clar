;; ATide Token Contract
(define-fungible-token atide)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))

;; Token info
(define-data-var token-name (string-ascii 32) "ArcTide Token")
(define-data-var token-symbol (string-ascii 10) "ATide")

;; Only arctide-core can mint tokens
(define-public (mint (recipient principal) (amount uint))
  (let ((caller tx-sender))
    (asserts! (is-eq caller .arctide-core) err-owner-only)
    (ft-mint? atide amount recipient)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (ft-transfer? atide amount sender recipient)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance atide account))
)
