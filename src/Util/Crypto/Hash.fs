// Hashing helpers from Util.Crypto.Hash, backed by .NET cryptography.

let private utf8Bytes (value: obj) : byte[] =
    System.Text.Encoding.UTF8.GetBytes(unbox<string> value)

let private toHex (bytes: byte[]) : string =
    System.Convert.ToHexString(bytes).ToLowerInvariant()

let _md5 (value: obj) : obj =
    box (toHex (System.Security.Cryptography.MD5.HashData(utf8Bytes value)))

let _sha256 (value: obj) : obj =
    box (toHex (System.Security.Cryptography.SHA256.HashData(utf8Bytes value)))

let hmacSha256 (secret: obj) (message: obj) : obj =
    box (toHex (System.Security.Cryptography.HMACSHA256.HashData(utf8Bytes secret, utf8Bytes message)))

// xxHash64 (seed 0), matching `xxhash-wasm`'s `h64(str).toString(16)`.
let private xxh64 (input: byte[]) : uint64 =
    let prime1 = 0x9E3779B185EBCA87UL
    let prime2 = 0xC2B2AE3D27D4EB4FUL
    let prime3 = 0x165667B19E3779F9UL
    let prime4 = 0x85EBCA77C2B2AE63UL
    let prime5 = 0x27D4EB2F165667C5UL

    let rotl (x: uint64) (r: int) = (x <<< r) ||| (x >>> (64 - r))

    let round (acc: uint64) (value: uint64) : uint64 =
        rotl (acc + value * prime2) 31 * prime1

    let mergeRound (acc: uint64) (value: uint64) : uint64 =
        let acc = acc ^^^ round 0UL value
        acc * prime1 + prime4

    let read64 (buffer: byte[]) (offset: int) : uint64 =
        System.BitConverter.ToUInt64(buffer, offset)

    let read32 (buffer: byte[]) (offset: int) : uint64 =
        uint64 (System.BitConverter.ToUInt32(buffer, offset))

    let len = input.Length
    let mutable h : uint64 = 0UL
    let mutable offset = 0

    if len >= 32 then
        let mutable acc1 = 0UL + prime1 + prime2
        let mutable acc2 = 0UL + prime2
        let mutable acc3 = 0UL
        let mutable acc4 = 0UL - prime1

        while offset <= len - 32 do
            acc1 <- round acc1 (read64 input offset)
            acc2 <- round acc2 (read64 input (offset + 8))
            acc3 <- round acc3 (read64 input (offset + 16))
            acc4 <- round acc4 (read64 input (offset + 24))
            offset <- offset + 32

        h <- rotl acc1 1 + rotl acc2 7 + rotl acc3 12 + rotl acc4 18
        h <- mergeRound h acc1
        h <- mergeRound h acc2
        h <- mergeRound h acc3
        h <- mergeRound h acc4
    else
        h <- prime5

    h <- h + uint64 len

    while offset <= len - 8 do
        h <- h ^^^ round 0UL (read64 input offset)
        h <- rotl h 27 * prime1 + prime4
        offset <- offset + 8

    if offset <= len - 4 then
        h <- h ^^^ (read32 input offset * prime1)
        h <- rotl h 23 * prime2 + prime3
        offset <- offset + 4

    while offset < len do
        h <- h ^^^ (uint64 input.[offset] * prime5)
        h <- rotl h 11 * prime1
        offset <- offset + 1

    h <- h ^^^ (h >>> 33)
    h <- h * prime2
    h <- h ^^^ (h >>> 29)
    h <- h * prime3
    h ^^^ (h >>> 32)

let private formatHex (value: uint64) : string =
    value.ToString("x", System.Globalization.CultureInfo.InvariantCulture)

let _xxhash64 (value: obj) : obj =
    box (fun (_onError: obj) -> box (fun (onSuccess: obj) ->
        sharpurs_apply onSuccess (box (formatHex (xxh64 (utf8Bytes value)))) |> ignore
        box (fun (_reason: obj) -> box (fun (_onCancelerError: obj) -> box (fun (onCancelerSuccess: obj) ->
            sharpurs_apply onCancelerSuccess null)))))
