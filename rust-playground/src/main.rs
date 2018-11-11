use std::iter::Iterator;

#[derive(Debug)]
struct Tree {
  data: i64,
  left: Option<Box<Tree>>,
  right: Option<Box<Tree>>
}

enum Remaining<'a> {
  Value(i64),
  Tree(&'a Tree)
}

struct Helper<'a> {
  remaining: Vec<Remaining<'a>>
}

impl<'a> Iterator for Helper<'a> {
  type Item = i64;

  fn next (&mut self) -> Option<Self::Item> {
    let remaining = self.remaining.pop()?;
    match remaining {
      | Remaining::Value (v) => Some (v),
      | Remaining::Tree (t) => {
        let mut c : &'a Tree = t;
        loop {
          if let Some(r) = c.right.as_ref() {
            self.remaining.push(Remaining::Tree(r));
          }
          match c.left.as_ref() {
            | None => {
              return Some (c.data)
            }
            | Some (l) => {
              self.remaining.push (Remaining::Value(c.data));
              c = &l
            }
          }
        }
      }
    }
  }
}

impl<'a> Tree {
  fn iter(&'a self) -> Helper<'a> {
    let mut remaining = Vec::new();
    remaining.push(Remaining::Tree(self));
    Helper {
      remaining
    }
  }

  fn build(data : &'a [i64]) -> Option<Box<Tree>> {
    if data.len() == 0 {
      return None
    }
    let c = data.len() / 2;
    let left = Tree::build (&data[0..c]);
    let right = Tree::build (&data[c+1 .. data.len()]);
    Some (Box::new(Tree {
      data : data[c],
      left,
      right
    }))
  }
}

fn main() {
  let x : Vec<i64> = (0..10).collect();
  let tree = Tree::build(&x[..]).expect("tree is non-empty");

  for i in tree.iter() {
    println!("{:?}", i);
  }
}
