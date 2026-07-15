class gpio_test extends apb_base_test;
  `uvm_component_utils(gpio_test)

  function new(string name = "gpio_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    gpio_seq seq;

    phase.raise_objection(this);
    seq = gpio_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
    phase.drop_objection(this);
  endtask
  
endclass : gpio_test
