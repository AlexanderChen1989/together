use std::sync::mpsc;
use std::sync::mpsc::{Receiver, Sender};
use std::thread;

enum Msg {
    V(i32),
    S(String),
}

fn main() {
    let (tx, rx): (Sender<Msg>, Receiver<Msg>) = mpsc::channel();

    let p = thread::spawn(move || {
        let ttx = tx.clone();
        let mut i = 0;
        loop {
            ttx.send(Msg::V(i)).unwrap();
            ttx.send(Msg::S(String::from("Hello")));
            i = i + 1;
            thread::sleep_ms(1000);
        }
    });

    let c = thread::spawn(move || loop {
        let result = rx.recv();
        match result {
            Err(_e) => {}
            Ok(msg) => match msg {
                Msg::V(v) => println!("I => {}", v),
                Msg::S(s) => println!("S => {}", s),
            },
        }
    });

    p.join();
    c.join();
}
