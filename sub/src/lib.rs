#[no_mangle]
pub extern "C" fn kv_sub(a: u64, b: u64) -> u64 {
    let v = core::hint::black_box(vec![a, b]);
    v.windows(2).map(|ab| ab[0] - ab[1]).sum()
}
