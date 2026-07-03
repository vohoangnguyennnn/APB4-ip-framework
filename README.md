# APB4 Peripheral Framework

AMBA APB4 Completer framework in SystemVerilog — a reusable protocol core
paired with a configurable register bank (RW/RO/W1C, PSTRB, PPROT).
Verified using UVM.

## Status
🚧 In progress

## Architecture
- **APB4 Protocol Core** — FSM (IDLE/SETUP/ACCESS), PSTRB, PPROT handling
- **Register Bank** — configurable RW/RO/W1C registers, PSLVERR on invalid access

Requester → APB4 Protocol Core → Register Bank

## Roadmap
- [ ] APB4 protocol core
- [ ] PSTRB / PPROT support
- [ ] Configurable register bank
- [ ] Directed testbench
- [ ] UVM environment
- [ ] CI simulation

## Structure
rtl/ - protocol core + register bank
tb/ - directed + UVM testbenches
docs/ - diagrams, register map
sim/ - simulation scripts

## Tools
Icarus Verilog / Verilator, GTKWave

## Reference
AMBA APB Protocol Specification, ARM IHI 0024E

## License
MIT