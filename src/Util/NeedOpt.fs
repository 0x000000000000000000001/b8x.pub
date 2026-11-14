// Util.NeedOpt FFI: strict null checks, matching `f === null`.

let jsonNull : obj = box null

let isNull (value: obj) : obj =
    box (System.Object.ReferenceEquals(value, null))
