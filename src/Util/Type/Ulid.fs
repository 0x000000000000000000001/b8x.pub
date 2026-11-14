// ULID generation and validation, matching the `ulid` npm package:
// Crockford base32, 10 characters of 48-bit timestamp and 16 random
// characters, lowercased like `ulid().toLowerCase()`.

let private ulidEncoding = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

let private ulidEncodeTime (timeMs: int64) : string =
    let mutable value = timeMs
    let chars = Array.zeroCreate 10
    for i = 9 downto 0 do
        chars.[i] <- ulidEncoding.[int (value % 32L)]
        value <- value / 32L
    System.String(chars)

let private ulidRandomPart () : string =
    let bytes = System.Security.Cryptography.RandomNumberGenerator.GetBytes(16)
    System.String(Array.init 16 (fun i -> ulidEncoding.[int bytes.[i] % 32]))

let private generateUlid () : string =
    (ulidEncodeTime (System.DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()) + ulidRandomPart()).ToLowerInvariant()

let private isValidUlid (value: string) : bool =
    value.Length = 26
    && (value.ToUpperInvariant().ToCharArray()
        |> Array.forall (fun ch -> ulidEncoding.IndexOf(ch) >= 0))

let _generateUlid : obj =
    box (fun (_: obj) -> box (generateUlid ()))

let _isValid (value: obj) : obj =
    if isNull value then box false
    else box (isValidUlid (unbox<string> value))
