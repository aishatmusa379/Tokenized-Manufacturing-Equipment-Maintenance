;; Asset Registration Contract
;; Records details of industrial machinery as non-fungible tokens

(define-non-fungible-token asset-token uint)

;; Data structures
(define-map asset-details
  { asset-id: uint }
  {
    name: (string-ascii 100),
    manufacturer: (string-ascii 100),
    model: (string-ascii 100),
    serial-number: (string-ascii 100),
    manufacture-date: uint,
    installation-date: uint,
    warranty-expiry: uint,
    location: (string-ascii 100),
    department: (string-ascii 100),
    status: (string-ascii 20),
    last-updated: uint,
    version: uint
  }
)

;; Asset counter
(define-data-var asset-counter uint u0)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-ASSET-EXISTS u101)
(define-constant ERR-ASSET-NOT-FOUND u102)
(define-constant ERR-INVALID-STATUS u103)

;; Authorization check
(define-read-only (is-authorized (caller principal))
  (is-eq caller tx-sender)
)

;; Register a new asset
(define-public (register-asset
    (name (string-ascii 100))
    (manufacturer (string-ascii 100))
    (model (string-ascii 100))
    (serial-number (string-ascii 100))
    (manufacture-date uint)
    (installation-date uint)
    (warranty-expiry uint)
    (location (string-ascii 100))
    (department (string-ascii 100))
  )
  (let ((asset-id (+ (var-get asset-counter) u1)))
    (asserts! (is-authorized tx-sender) (err ERR-NOT-AUTHORIZED))

    ;; Mint new asset token
    (try! (nft-mint? asset-token asset-id tx-sender))

    ;; Store asset details
    (map-set asset-details
      { asset-id: asset-id }
      {
        name: name,
        manufacturer: manufacturer,
        model: model,
        serial-number: serial-number,
        manufacture-date: manufacture-date,
        installation-date: installation-date,
        warranty-expiry: warranty-expiry,
        location: location,
        department: department,
        status: "active",
        last-updated: block-height,
        version: u1
      }
    )

    ;; Increment asset counter
    (var-set asset-counter asset-id)

    (ok asset-id)
  )
)

;; Get asset details
(define-read-only (get-asset (asset-id uint))
  (map-get? asset-details { asset-id: asset-id })
)

;; Update asset status
(define-public (update-asset-status (asset-id uint) (new-status (string-ascii 20)))
  (let (
    (asset (unwrap! (map-get? asset-details { asset-id: asset-id }) (err ERR-ASSET-NOT-FOUND)))
    (valid-status (or (is-eq new-status "active") (is-eq new-status "inactive")
                      (is-eq new-status "maintenance") (is-eq new-status "retired")))
  )
    (asserts! (is-authorized tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! valid-status (err ERR-INVALID-STATUS))

    (map-set asset-details
      { asset-id: asset-id }
      (merge asset {
        status: new-status,
        last-updated: block-height,
        version: (+ (get version asset) u1)
      })
    )

    (ok true)
  )
)

;; Update asset location
(define-public (update-asset-location (asset-id uint) (new-location (string-ascii 100)))
  (let (
    (asset (unwrap! (map-get? asset-details { asset-id: asset-id }) (err ERR-ASSET-NOT-FOUND)))
  )
    (asserts! (is-authorized tx-sender) (err ERR-NOT-AUTHORIZED))

    (map-set asset-details
      { asset-id: asset-id }
      (merge asset {
        location: new-location,
        last-updated: block-height,
        version: (+ (get version asset) u1)
      })
    )

    (ok true)
  )
)

;; Update asset department
(define-public (update-asset-department (asset-id uint) (new-department (string-ascii 100)))
  (let (
    (asset (unwrap! (map-get? asset-details { asset-id: asset-id }) (err ERR-ASSET-NOT-FOUND)))
  )
    (asserts! (is-authorized tx-sender) (err ERR-NOT-AUTHORIZED))

    (map-set asset-details
      { asset-id: asset-id }
      (merge asset {
        department: new-department,
        last-updated: block-height,
        version: (+ (get version asset) u1)
      })
    )

    (ok true)
  )
)

;; Get total number of assets
(define-read-only (get-asset-count)
  (var-get asset-counter)
)
