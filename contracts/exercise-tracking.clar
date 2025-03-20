;; Exercise Tracking Contract
;; Monitors participation in preparedness drills

;; Data Variables
(define-map exercises
  { exercise-id: uint }
  {
    name: (string-ascii 64),
    description: (string-ascii 256),
    date: uint,
    coordinator: principal,
    status: (string-ascii 16),
    created-at: uint
  }
)

(define-map participations
  { exercise-id: uint, participant: principal }
  {
    attended: bool,
    role: (string-ascii 64),
    feedback: (optional (string-ascii 256)),
    verified-by: (optional principal)
  }
)

(define-map exercise-participants
  { exercise-id: uint }
  { participants: (list 100 principal) }
)

(define-data-var next-exercise-id uint u1)

;; Read-Only Functions
(define-read-only (get-exercise (exercise-id uint))
  (map-get? exercises { exercise-id: exercise-id })
)

(define-read-only (get-participation (exercise-id uint) (participant principal))
  (map-get? participations { exercise-id: exercise-id, participant: participant })
)

(define-read-only (get-exercise-participants (exercise-id uint))
  (map-get? exercise-participants { exercise-id: exercise-id })
)

(define-read-only (get-next-exercise-id)
  (var-get next-exercise-id)
)

;; Public Functions
(define-public (create-exercise
                (name (string-ascii 64))
                (description (string-ascii 256))
                (date uint))
  (let ((exercise-id (var-get next-exercise-id)))
    (begin
      (map-set exercises
        { exercise-id: exercise-id }
        {
          name: name,
          description: description,
          date: date,
          coordinator: tx-sender,
          status: "scheduled",
          created-at: block-height
        }
      )
      (map-set exercise-participants
        { exercise-id: exercise-id }
        { participants: (list) }
      )
      (var-set next-exercise-id (+ exercise-id u1))
      (ok exercise-id)
    )
  )
)

(define-public (register-for-exercise
                (exercise-id uint)
                (role (string-ascii 64)))
  (let (
    (exercise (map-get? exercises { exercise-id: exercise-id }))
    (participants-data (default-to { participants: (list) } (map-get? exercise-participants { exercise-id: exercise-id })))
  )
    (begin
      (asserts! (is-some exercise) (err u404))
      (asserts! (is-eq (get status (unwrap-panic exercise)) "scheduled") (err u403))
      (map-set participations
        { exercise-id: exercise-id, participant: tx-sender }
        {
          attended: false,
          role: role,
          feedback: none,
          verified-by: none
        }
      )
      (map-set exercise-participants
        { exercise-id: exercise-id }
        { participants: (append (get participants participants-data) tx-sender) }
      )
      (ok true)
    )
  )
)

(define-public (verify-participation
                (exercise-id uint)
                (participant principal)
                (attended bool))
  (let (
    (exercise (map-get? exercises { exercise-id: exercise-id }))
    (participation (map-get? participations { exercise-id: exercise-id, participant: participant }))
  )
    (begin
      (asserts! (is-some exercise) (err u404))
      (asserts! (is-eq (get coordinator (unwrap-panic exercise)) tx-sender) (err u403))
      (asserts! (is-some participation) (err u404))
      (map-set participations
        { exercise-id: exercise-id, participant: participant }
        (merge (unwrap-panic participation) {
          attended: attended,
          verified-by: (some tx-sender)
        })
      )
      (ok true)
    )
  )
)

(define-public (provide-feedback
                (exercise-id uint)
                (feedback (string-ascii 256)))
  (let ((participation (map-get? participations { exercise-id: exercise-id, participant: tx-sender })))
    (begin
      (asserts! (is-some participation) (err u404))
      (map-set participations
        { exercise-id: exercise-id, participant: tx-sender }
        (merge (unwrap-panic participation) {
          feedback: (some feedback)
        })
      )
      (ok true)
    )
  )
)

(define-public (update-exercise-status
                (exercise-id uint)
                (status (string-ascii 16)))
  (let ((exercise (map-get? exercises { exercise-id: exercise-id })))
    (begin
      (asserts! (is-some exercise) (err u404))
      (asserts! (is-eq (get coordinator (unwrap-panic exercise)) tx-sender) (err u403))
      (map-set exercises
        { exercise-id: exercise-id }
        (merge (unwrap-panic exercise) {
          status: status
        })
      )
      (ok true)
    )
  )
)

