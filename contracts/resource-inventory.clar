;; Resource Inventory Contract
;; Tracks available emergency equipment and supplies

;; Data Variables
(define-map resources
  { resource-id: uint }
  {
    name: (string-ascii 64),
    category: (string-ascii 32),
    quantity: uint,
    location: (string-ascii 64),
    owner: principal,
    last-updated: uint
  }
)

(define-data-var next-resource-id uint u1)

;; Read-Only Functions
(define-read-only (get-resource (resource-id uint))
  (map-get? resources { resource-id: resource-id })
)

(define-read-only (get-next-resource-id)
  (var-get next-resource-id)
)

;; Public Functions
(define-public (add-resource
                (name (string-ascii 64))
                (category (string-ascii 32))
                (quantity uint)
                (location (string-ascii 64)))
  (let ((resource-id (var-get next-resource-id)))
    (begin
      (map-set resources
        { resource-id: resource-id }
        {
          name: name,
          category: category,
          quantity: quantity,
          location: location,
          owner: tx-sender,
          last-updated: block-height
        }
      )
      (var-set next-resource-id (+ resource-id u1))
      (ok resource-id)
    )
  )
)

(define-public (update-resource-quantity
                (resource-id uint)
                (quantity uint))
  (let ((resource (map-get? resources { resource-id: resource-id })))
    (begin
      (asserts! (is-some resource) (err u404))
      (asserts! (is-eq tx-sender (get owner (unwrap-panic resource))) (err u403))
      (map-set resources
        { resource-id: resource-id }
        (merge (unwrap-panic resource) {
          quantity: quantity,
          last-updated: block-height
        })
      )
      (ok true)
    )
  )
)

(define-public (transfer-resource-ownership
                (resource-id uint)
                (new-owner principal))
  (let ((resource (map-get? resources { resource-id: resource-id })))
    (begin
      (asserts! (is-some resource) (err u404))
      (asserts! (is-eq tx-sender (get owner (unwrap-panic resource))) (err u403))
      (map-set resources
        { resource-id: resource-id }
        (merge (unwrap-panic resource) {
          owner: new-owner,
          last-updated: block-height
        })
      )
      (ok true)
    )
  )
)

