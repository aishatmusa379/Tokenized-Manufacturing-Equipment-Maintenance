;; Maintenance History Contract
;; Tracks repairs and servicing for industrial equipment

;; Data structures
(define-map maintenance-records
  { record-id: uint }
  {
    asset-id: uint,
    maintenance-type: (string-ascii 50),
    description: (string-utf8 500),
    technician: principal,
    cost: uint,
    start-date: uint,
    end-date: uint,
    parts-used: (list 10 uint),
    notes: (string-utf8 1000),
    version: uint
  }
)

;; Asset to maintenance records mapping
(define-map asset-maintenance-records
  { asset-id: uint }
  { records: (list 100 uint) }
)

;; Record counter
(define-data-var record-counter uint u0)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-RECORD-NOT-FOUND u101)
(define-constant ERR-ASSET-NOT-FOUND u102)
(define-constant ERR-TOO-MANY-RECORDS u103)

;; Authorization check
(define-read-only (is-authorized (caller principal))
  (is-eq caller tx-sender)
)

;; Add a maintenance record
(define-public (add-maintenance-record
    (asset-id uint)
    (maintenance-type (string-ascii 50))
    (description (string-utf8 500))
    (technician principal)
    (cost uint)
    (start-date uint)
    (end-date uint)
    (parts-used (list 10 uint))
    (notes (string-utf8 1000))
  )
  (let (
    (record-id (+ (var-get record-counter) u1))
    (asset-records (default-to { records: (list) } (map-get? asset-maintenance-records { asset-id: asset-id })))
    (updated-records (unwrap! (as-max-len? (append (get records asset-records) record-id) u100) (err ERR-TOO-MANY-RECORDS)))
  )
    (asserts! (is-authorized tx-sender) (err ERR-NOT-AUTHORIZED))

    ;; Store maintenance record
    (map-set maintenance-records
      { record-id: record-id }
      {
        asset-id: asset-id,
        maintenance-type: maintenance-type,
        description: description,
        technician: technician,
        cost: cost,
        start-date: start-date,
        end-date: end-date,
        parts-used: parts-used,
        notes: notes,
        version: u1
      }
    )

    ;; Update asset maintenance records list
    (map-set asset-maintenance-records
      { asset-id: asset-id }
      { records: updated-records }
    )

    ;; Increment record counter
    (var-set record-counter record-id)

    (ok record-id)
  )
)

;; Get maintenance record
(define-read-only (get-maintenance-record (record-id uint))
  (map-get? maintenance-records { record-id: record-id })
)

;; Get all maintenance records for an asset
(define-read-only (get-asset-records (asset-id uint))
  (get records (default-to { records: (list) } (map-get? asset-maintenance-records { asset-id: asset-id })))
)

;; Update maintenance record
(define-public (update-maintenance-record
    (record-id uint)
    (description (string-utf8 500))
    (cost uint)
    (end-date uint)
    (parts-used (list 10 uint))
    (notes (string-utf8 1000))
  )
  (let (
    (record (unwrap! (map-get? maintenance-records { record-id: record-id }) (err ERR-RECORD-NOT-FOUND)))
  )
    (asserts! (is-authorized tx-sender) (err ERR-NOT-AUTHORIZED))

    (map-set maintenance-records
      { record-id: record-id }
      (merge record {
        description: description,
        cost: cost,
        end-date: end-date,
        parts-used: parts-used,
        notes: notes,
        version: (+ (get version record) u1)
      })
    )

    (ok true)
  )
)

;; Get total number of maintenance records
(define-read-only (get-record-count)
  (var-get record-counter)
)

;; Calculate total maintenance cost for an asset
(define-read-only (get-total-maintenance-cost (asset-id uint))
  (let (
    (records (get records (default-to { records: (list) } (map-get? asset-maintenance-records { asset-id: asset-id }))))
  )
    (fold calculate-total-cost records u0)
  )
)

;; Helper function to calculate total cost
(define-private (calculate-total-cost (record-id uint) (total uint))
  (let (
    (record (unwrap! (map-get? maintenance-records { record-id: record-id }) total))
  )
    (+ total (get cost record))
  )
)
