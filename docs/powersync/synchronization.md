# Synchronization

> Reference: `AGENTS.md` §54, §55, Appendix G. See also
> [ADR-0003](../architecture/ADR-0003-powersync.md).

PowerSync is **mandatory**. Every critical workflow supports offline operation.
PowerSync maintains local replicas; **Supabase remains the source of truth**.
Flutter communicates primarily with the local database, and synchronization
occurs automatically.

## Synchronization Lifecycle (Appendix G)

```
Initial Sync → Delta Sync → Conflict Resolution → Background Sync
             → Retry Queue → Offline Queue → Manual Refresh
```

## What Synchronizes (§55)

- patients
- treatments
- hospitals
- assignments
- notifications
- timeline
- document **metadata**
- audit references

## What Does NOT Auto-Synchronize

Large binary files (images, scans, PDFs). Only document **metadata** syncs; the
binary is **downloaded on demand** from Storage via signed URLs
(see [ADR-0005](../architecture/ADR-0005-storage-strategy.md)).

## Sync Rules Must Mirror RLS

A user's local replica must never exceed their authorized scope. Author
PowerSync sync rules alongside each table's RLS policy so that hospital/patient
assignment is respected offline as well as online (§72, §77).

## Surfacing Status

The UI always reflects sync status: `Offline`, `Sync Pending`, `Synchronizing`,
`Conflict Detected` (§27, §135). Never hide background synchronization.

## Related

- [`conflict_resolution.md`](./conflict_resolution.md)
- [`offline_queue.md`](./offline_queue.md)
