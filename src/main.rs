use std::{time::Duration, io, io::Write};
use anyhow::Result;
use rand::{Rng, thread_rng};
use dialoguer::Select;

#[tokio::main]
async fn main() -> Result<()> {
    let faces = &["Heads", "Tails"];
    let value = Select::new().default(0).items(&faces[..]).interact().unwrap();
    // get the two arguments
    let args: Vec<String> = std::env::args().collect();
    let start_arg = "42".to_string();
    let end_arg = "1337".to_string();
    let start = args.get(0).unwrap_or(&start_arg);
    let end = args.get(1).unwrap_or(&end_arg);

    let of: u16 = prompt();
    let mut sum: u16 = 0;
    for _ in 0..of {
        let mut rng = thread_rng();
        
        let coin: u16 = rng.gen_range(0..=1);
        sum += coin
    }
    let percent: f64 = 100.0*f64::from(sum)/f64::from(of);
    println!("drum roll please...");
    tokio::time::sleep(Duration::from_secs(3)).await;
    println!("{}% {}, you {}", percent, if value == 0 { "Heads" } else { "Tails" }, if percent > 50.0 { "won" } else { "lost" });
    return Ok(());
}

fn prompt() -> u16 {
    let mut input_line = String::new();
    print!("best of ");
    std::io::stdout().flush().unwrap();
    io::stdin() // the rough equivalent of `std::cin`
        .read_line(&mut input_line) // actually read the line
        .expect("Failed to read line"); // which can fail, however
    let x: u16 = input_line
        .trim() // ignore whitespace around input
        .parse() // convert to integers
        .expect("Input not an integer"); // which, again, can fail
    return x;
}
