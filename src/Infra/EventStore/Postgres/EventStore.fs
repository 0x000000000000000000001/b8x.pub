// Infra.EventStore.Postgres.EventStore.generateLockKeyStr: process-unique
// advisory lock keys built from the timestamp, a random process id and a
// rotating counter, mirroring the JavaScript implementation.

let private lockKeyProcessId =
    (System.Random.Shared.Next(0, 1000)).ToString("D3", System.Globalization.CultureInfo.InvariantCulture)

let private lockKeyCounter = ref 0

let private generateLockKey () : string =
    let counter = System.Threading.Interlocked.Increment(lockKeyCounter)
    let wrapped = counter % 1000
    System.DateTimeOffset.UtcNow.ToUnixTimeMilliseconds().ToString(System.Globalization.CultureInfo.InvariantCulture)
    + lockKeyProcessId
    + wrapped.ToString("D3", System.Globalization.CultureInfo.InvariantCulture)

let generateLockKeyStr : obj =
    box (fun (_: obj) -> box (generateLockKey ()))
