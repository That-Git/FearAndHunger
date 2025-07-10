use {
    anyhow::Result, clap::Parser, rand::random_bool as chance, std::time::Duration
};


enum Face {
    Heads,
    Tails,
}
impl Face {
    fn new() -> (Self, u16) {
        let args = Args::parse();
        let chr: &str = &args.face.to_lowercase()[..1];
        let face: Face = match chr {
            "h" => Face::Heads,
            "t" => Face::Tails,
            _ => panic!("heads or tails"),
        };
        return (face, args.of)
    }
    fn ball(&self) -> &str {
        return match self {
            Self::Heads => "Heads",
            Self::Tails => "Tails",
        }
    }
}


#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// Name of the person to greet
    #[arg(short, long)]
    face: String,

    /// Number of times to greet
    #[arg(short, long, default_value_t = 5)]
    of: u16,
}


#[tokio::main]
async fn main() -> Result<()> {
    let (face, of) = Face::new();

    let mut sum: u16 = 0;
    for _ in 0..of {
        if chance(0.5) {
            sum += 1;
        }
    }

    let percent: f64 = 100.0*f64::from(sum)/f64::from(of);

    println!("drum roll please...");
    tokio::time::sleep(Duration::from_secs(3)).await;

    println!("{}% {}, you {}", percent, face.ball(), if percent > 50.0 { "won" } else { "lost" });
    return Ok(());
}
