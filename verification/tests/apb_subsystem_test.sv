class apb_subsystem_test extends apb_base_test;
  `uvm_component_utils(apb_subsystem_test)

  function new(string name = "apb_subsystem_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_smoke_seq  smoke_seq;
    apb_error_seq  error_seq;
    apb_random_seq random_seq;

    phase.raise_objection(this);
    smoke_seq = apb_smoke_seq::type_id::create("smoke_seq");
    smoke_seq.start(env.agent.sequencer);
    error_seq = apb_error_seq::type_id::create("error_seq");
    error_seq.start(env.agent.sequencer);
    random_seq = apb_random_seq::type_id::create("random_seq");
    random_seq.start(env.agent.sequencer);
    phase.drop_objection(this);
  endtask
  
endclass : apb_subsystem_test
