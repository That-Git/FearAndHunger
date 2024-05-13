use std::time::Duration;
use anyhow::{Context, Result};
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

    let mut sum = 0;
    for _ in 0..5 {
        let mut rng = thread_rng();
        
        let coin: i8 = rng.gen_range(0..=1);
        sum += coin
    }
    println!("drum roll please...");
    tokio::time::sleep(Duration::from_secs(3)).await;
    println!("{} {}", sum, if value == 0 { "Heads" } else { "tails" });
    return Ok(());
}

