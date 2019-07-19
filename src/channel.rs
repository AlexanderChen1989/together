#[macro_use]
extern crate crossbeam_channel;

use std::thread;

fn main() {
    use crossbeam_channel::bounded;

    // Create a channel of unbounded capacity.
    let (s, r) = bounded(0);

    // Send a message into the channel.
    let s1 = s.clone();
    thread::spawn(move || {
        for _ in 0..1000 {
            s1.send(1).unwrap();
        }
    });
    let s2 = s.clone();
    thread::spawn(move || {
        for _ in 0..1000 {
            s2.send(2).unwrap();
        }
    });

    // Receive the message from the channel.
    loop {
        match r.recv() {
            Ok(s) => println!("{}", s),
            Err(_) => (),
        }
        thread::sleep_ms(1000);
    }
}
