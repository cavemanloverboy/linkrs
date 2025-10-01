#[no_mangle]
pub extern "C" fn kv_add(a: u64, b: u64) -> u64 {
    let v = core::hint::black_box(vec![a, b]);
    v.into_iter().sum()
}
