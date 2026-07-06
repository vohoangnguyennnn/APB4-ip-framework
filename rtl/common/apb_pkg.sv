package apb_pkg;

  typedef enum logic [1:0] {
    APB_IDLE = 2'b00,
    APB_SETUP = 2'b01,
    APB_ACCESS = 2'b10
  } apb_state_e;

  typedef enum logic [1:0] {
    APB_WRITE = 2'b00,
    APB_READ = 2'b01
  } apb_dir_e;

  typedef enum logic [1:0] {
    APB_OKAY = 2'b00,
    APB_ERROR = 2'b01
  } apb_resp_e;

endpackage : apb_pkg