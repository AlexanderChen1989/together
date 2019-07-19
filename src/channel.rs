#[macro_use]
extern crate crossbeam_channel;

use std::thread;

const NUM_THREADS: u32 = 10;

fn main() {
    use crossbeam_channel::bounded;

    let (s, r) = bounded(0);

    for _ in 1..NUM_THREADS {
        let st = s.clone();
        thread::spawn(move || loop {
            let name = format!("Process {:?}", thread::current().id());
            st.send(name).unwrap();
        });
    }

    for _ in 1..NUM_THREADS {
        let rt = r.clone();
        thread::spawn(move || loop {
            let msg = rt.recv().unwrap();
            println!("{:?} => {}", thread::current().id(), msg);
            thread::sleep_ms(1000);
        });
    }

    thread::sleep_ms(1000000);
}
