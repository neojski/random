use std::io;
use std::io::BufWriter;
use std::io::Write;

fn main() {
  let mut buf = String::new();
  let mut w = BufWriter::new(io::stdout());

  while io::stdin().read_line(&mut buf).unwrap() > 0 {
    let out = (buf.len() - 1).to_string();
    w.write(out.as_bytes()).expect("write failed");
    w.write("\n".as_bytes()).expect("write failed");
    buf.clear();
  };
}
