;; ------------------------------------------------------------
;; eco-token-reward.clar
;; Purpose: A decentralized reward system for verified environmental actions
;; Language: Clarity
;; Network: Stacks Blockchain
;; ------------------------------------------------------------

;; ------------------------------------------------------------
;; SECTION 1: DATA DEFINITIONS
;; ------------------------------------------------------------

(define-data-var admin principal tx-sender)
(define-data-var total-actions uint u0)
(define-data-var reward-pool uint u0)

;; Each action record includes ID, participant, type, and reward value
(define-map eco-actions
  { id: uint }
  {
    participant: principal,
    action-type: (string-ascii 64),
    description: (string-ascii 256),
    reward: uint,
    verified: bool
  }
)

;; Track users and their total earned rewards
(define-map user-rewards
  { user: principal }
  { total-earned: uint }
)

;; ------------------------------------------------------------
;; SECTION 2: CONSTANTS AND ERRORS
;; ------------------------------------------------------------

(define-constant ERR-NOT-ADMIN (err u401))
(define-constant ERR-ACTION-NOT-FOUND (err u404))
(define-constant ERR-ALREADY-VERIFIED (err u405))
(define-constant ERR-NO-REWARD (err u406))

;; ------------------------------------------------------------
;; SECTION 3: EVENTS
;; ------------------------------------------------------------
;; Removed define-event declarations - not valid in Clarity
;; Events are emitted using print with tuples

;; ------------------------------------------------------------
;; SECTION 4: ADMIN FUNCTIONS
;; ------------------------------------------------------------

;; 4.1 Fund the reward pool with STX
(define-public (fund-pool (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set reward-pool (+ (var-get reward-pool) amount))
    (ok { funded: amount, total-pool: (var-get reward-pool) })
  )
)

;; 4.2 Verify a user's eco action and release reward
;; Fixed map syntax, replaced emit-event with print, fixed non-ASCII characters
(define-public (verify-action (id uint))
  (if (is-eq tx-sender (var-get admin))
      (match (map-get? eco-actions { id: id })
        action
          (if (not (get verified action))
              (let ((reward (get reward action))
                    (participant (get participant action)))
                (if (>= (var-get reward-pool) reward)
                    (begin
                      (try! (as-contract (stx-transfer? reward tx-sender participant)))
                      (map-set eco-actions { id: id }
                        {
                          participant: participant,
                          action-type: (get action-type action),
                          description: (get description action),
                          reward: reward,
                          verified: true
                        })
                      (var-set reward-pool (- (var-get reward-pool) reward))
                      (let ((previous (default-to u0 (get total-earned (map-get? user-rewards { user: participant })))))
                        (map-set user-rewards { user: participant } { total-earned: (+ previous reward) }))
                      (print { event: "action-verified", id: id, verifier: tx-sender })
                      (print { event: "reward-sent", participant: participant, amount: reward })
                      (ok { action-id: id, verified: true, reward: reward })
                    )
                    ERR-NO-REWARD))
              ERR-ALREADY-VERIFIED)
        ERR-ACTION-NOT-FOUND)
      ERR-NOT-ADMIN)
)

;; ------------------------------------------------------------
;; SECTION 5: PUBLIC FUNCTIONS
;; ------------------------------------------------------------

;; 5.1 Log a new eco-friendly action
;; Fixed map syntax and replaced emit-event with print
(define-public (log-action (action-type (string-ascii 64)) (description (string-ascii 256)) (reward uint))
  (let ((next-id (+ (var-get total-actions) u1)))
    (begin
      (map-set eco-actions { id: next-id }
        {
          participant: tx-sender,
          action-type: action-type,
          description: description,
          reward: reward,
          verified: false
        })
      (var-set total-actions next-id)
      (print { event: "action-logged", id: next-id, participant: tx-sender, reward: reward })
      (ok { action-id: next-id, pending-reward: reward })
    )
  )
)

;; ------------------------------------------------------------
;; SECTION 6: READ-ONLY FUNCTIONS
;; ------------------------------------------------------------

;; 6.1 Get details of an action
;; Fixed map syntax
(define-read-only (get-action (id uint))
  (match (map-get? eco-actions { id: id })
    action
      (ok {
        id: id,
        participant: (get participant action),
        action-type: (get action-type action),
        description: (get description action),
        reward: (get reward action),
        verified: (get verified action)
      })
    ERR-ACTION-NOT-FOUND)
)

;; 6.2 Get total reward pool balance
(define-read-only (get-reward-pool)
  (ok (var-get reward-pool))
)

;; 6.3 Get total actions logged
(define-read-only (get-total-actions)
  (ok (var-get total-actions))
)

;; 6.4 Get total rewards earned by a user
;; Fixed map syntax
(define-read-only (get-user-rewards (user principal))
  (default-to u0 (get total-earned (map-get? user-rewards { user: user })))
)
