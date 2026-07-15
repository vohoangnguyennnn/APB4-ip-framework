class timer_test extends apb_base_test;
  `uvm_component_utils(timer_test)

  function new(string name = "timer_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    timer_seq seq;

    phase.raise_objection(this);
    seq = timer_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
    phase.drop_objection(this);
  endtask
  
endclass : timer_test
