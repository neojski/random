use std::{env, thread, time};
use arboard::{Clipboard};

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 3 {
        eprintln!("Usage: {} <html_content> <alt_text>", args[0]);
        std::process::exit(1);
    }

    let html_content = &args[1];
    let alt_text = &args[2];

    let mut clipboard = Clipboard::new().expect("Failed to initialize clipboard");
    clipboard.set_html(html_content, Some (alt_text)).expect("Failed to set HTML content");

    let sleep_duration = time::Duration::from_secs(60);
    thread::sleep(sleep_duration);

    println!("HTML and alt text set to clipboard successfully.");
}

