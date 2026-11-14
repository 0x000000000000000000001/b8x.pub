pub fn Util_File_Path__rootDirAbsolutePath() -> String {
    // Like the JS module URL, generated-crate metadata is independent of cwd.
    // The b8x Rust profile exports crates below run/bak/rust/output; using the
    // executable's working directory would put caches inside a diagnostic build.
    let manifest = env!("CARGO_MANIFEST_DIR");
    let (root, _) = manifest
        .split_once("/run/bak/rust/output/")
        .expect("Util.File.Path: expected a b8x Rust profile export");
    purust_core::purust_string_from_utf8(&format!("{root}/"))
}
