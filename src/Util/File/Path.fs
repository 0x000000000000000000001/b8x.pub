// Project root resolution for Util.File.Path. The executed assembly lives under
// `<root>/run/bak/sharp/output/Main/bin/...`, and the JavaScript variant derives
// the same root from the module URL. Walk up to the directory that owns `env`,
// which is unique to the b8x root.

let private resolveRootDir () : string =
    let rec walk (dir: System.IO.DirectoryInfo) =
        if isNull dir then
            System.IO.Directory.GetCurrentDirectory()
        elif System.IO.Directory.Exists(System.IO.Path.Combine(dir.FullName, "env")) then
            dir.FullName
        else
            walk dir.Parent

    walk (System.IO.DirectoryInfo(System.AppContext.BaseDirectory))

let _rootDirAbsolutePath : obj =
    let root = resolveRootDir ()
    box (if root.EndsWith("/") then root else root + "/")
