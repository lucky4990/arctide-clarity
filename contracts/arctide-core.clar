;; ArcTide Core Contract
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-status (err u102))

;; Goal status types
(define-data-var next-goal-id uint u0)

;; Goal data structure
(define-map goals
  { goal-id: uint }
  {
    owner: principal,
    title: (string-utf8 100),
    status: (string-ascii 20),
    created-at: uint,
    completed-at: (optional uint)
  }
)

;; Create new goal
(define-public (create-goal (title (string-utf8 100)))
  (let ((goal-id (var-get next-goal-id)))
    (map-set goals
      { goal-id: goal-id }
      {
        owner: tx-sender,
        title: title,
        status: "active",
        created-at: block-height,
        completed-at: none
      }
    )
    (var-set next-goal-id (+ goal-id u1))
    (ok goal-id)
  )
)

;; Complete goal and mint reward
(define-public (complete-goal (goal-id uint))
  (let ((goal (unwrap! (map-get? goals { goal-id: goal-id }) (err err-not-found))))
    (asserts! (is-eq (get owner goal) tx-sender) (err u403))
    (asserts! (is-eq (get status goal) "active") (err err-invalid-status))
    
    ;; Update goal status
    (map-set goals
      { goal-id: goal-id }
      (merge goal {
        status: "completed",
        completed-at: (some block-height)
      })
    )
    
    ;; Mint reward tokens
    (contract-call? .atide-token mint tx-sender u100)
  )
)

;; Get goal details
(define-read-only (get-goal (goal-id uint))
  (map-get? goals { goal-id: goal-id })
)
