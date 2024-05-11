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

    let mut wins = 0;
    for _ in 0..5 {
        // Command
        let mut sum = 0;
        for i in 0..4 {
            let mut rng = thread_rng();
            
            let coin: i8 = rng.gen_range(1..=2);
            sum += coin
        }

        println!("your sum is {}", sum);
        wins += if sum % 2 == 0 { 1 } else { 0 };
    }
    println!("you are...");
    tokio::time::sleep(Duration::from_secs(3)).await;
    println!("wins {}", wins);
    return Ok(());
}
