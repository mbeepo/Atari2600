use std::{io::stdin, process::exit};

fn main() {
    let mut section_amt = 0;

    for line in stdin().lines().map(|l| l.unwrap()) {
        if line.starts_with("SECTIONAMT") {
            section_amt = str::parse(line.split_once("=").unwrap().1.trim()).unwrap();
            
            println!("{}", line);

            continue;
        }

        if line == "; ----- SECTIONS -----" {
            println!("; ----- GENERATED SECTION -----");

            for i in 0..section_amt {
                println!(r#"
      ; --- Section {0} ---
        SUBROUTINE
        PREP SECTION{0}

        lda #>.CurrentEnd
        sta SECTIONEND
        lda #<.CurrentEnd
        sta SECTIONENDM

        lda #SECTIONHEIGHT

        jmp SectionPlayer0
.CurrentEnd"#, i);
            }

            println!("; ----- END OF GENERATED -----");

            continue;
        }

        if line.trim_start() == "END" {
            exit(0);
        }

        println!("{}", line);
    }
}
