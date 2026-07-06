package apb_pkg;

  typedef enum logic [1:0] {
    APB_IDLE = 2'b00,
    APB_SETUP = 2'b01,
    APB_ACCESS = 2'b10
  } apb_state_e;

  typedef enum logic {
    APB_READ = 1'b0,
    APB_WRITE = 1'b1
  } apb_dir_e;

  typedef enum logic {
    APB_OKAY = 1'b0,
    APB_ERROR = 1'b1
  } apb_resp_e;

  typedef enum logic {
    APB_NORMAL = 1'b0,
    APB_PRIVILEGED = 1'b1
  } apb_priv_e;

  typedef enum logic {
    APB_DATA = 1'b0,
    APB_INSTRUCTION = 1'b1
  } apb_access_e;

  typedef enum logic {
    APB_SECURE = 1'b0,
    APB_NONSECURE = 1'b1
  } apb_sec_e;

  localparam int APB_PPROT_PRIV_BIT = 0;
  localparam int APB_PPROT_SEC_BIT = 1;
  localparam int APB_PPROT_ACCESS_BIT = 2;

endpackage : apb_pkg