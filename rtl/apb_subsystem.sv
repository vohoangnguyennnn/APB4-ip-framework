module apb_subsystem #(
  parameter int ADDR_WIDTH = 16,
  parameter int DATA_WIDTH = 32,
  parameter int GPIO_WIDTH = 8,
  parameter int SLAVE_ADDR_WIDTH = 12,
  parameter int GPIO_WAIT_CYCLES = 0,
  parameter int TIMER_WAIT_CYCLES = 0,
  parameter logic [ADDR_WIDTH-1:0] GPIO_BASE_ADDR = 'h0000,
  parameter logic [ADDR_WIDTH-1:0] TIMER_BASE_ADDR = 'h1000
)(
  input  logic PCLK,
  input  logic PRESETn,

  input  logic [ADDR_WIDTH-1:0]     PADDR,
  input  logic [DATA_WIDTH-1:0]     PWDATA,
  input  logic                      PWRITE,
  input  logic                      PENABLE,
  input  logic [(DATA_WIDTH/8)-1:0] PSTRB,
  input  logic                      PSEL,
  input  logic [2:0]                PPROT,
  output logic [DATA_WIDTH-1:0]     PRDATA,
  output logic                      PREADY,
  output logic                      PSLVERR,

  inout  tri   [GPIO_WIDTH-1:0]     gpio_pins,
  output logic [1:0]                timer_irq_o
);

  localparam logic [ADDR_WIDTH-1:0] SLAVE_ADDR_MASK =
      {ADDR_WIDTH{1'b1}} << SLAVE_ADDR_WIDTH;
  localparam logic [ADDR_WIDTH-1:0] SLAVE_OFFSET_MASK = ~SLAVE_ADDR_MASK;

  logic gpio_addr_hit;
  logic timer_addr_hit;
  logic psel_gpio;
  logic psel_timer;
  logic decode_error;

  logic [SLAVE_ADDR_WIDTH-1:0] local_paddr;

  logic [DATA_WIDTH-1:0] gpio_prdata;
  logic                  gpio_pready;
  logic                  gpio_pslverr;

  logic [DATA_WIDTH-1:0] timer_prdata;
  logic                  timer_pready;
  logic                  timer_pslverr;

  initial begin
    if (ADDR_WIDTH <= 0) begin
      $error("ADDR_WIDTH must be greater than zero");
    end

    if (ADDR_WIDTH > 32) begin
      $error("ADDR_WIDTH must be 32 bits or less");
    end

    if (SLAVE_ADDR_WIDTH <= 0) begin
      $error("SLAVE_ADDR_WIDTH must be greater than zero");
    end

    if (SLAVE_ADDR_WIDTH > ADDR_WIDTH) begin
      $error("SLAVE_ADDR_WIDTH must be less than or equal to ADDR_WIDTH");
    end

    if (!(DATA_WIDTH == 8 || DATA_WIDTH == 16 || DATA_WIDTH == 32)) begin
      $error("DATA_WIDTH must be 8, 16, or 32 bits");
    end

    if ((GPIO_BASE_ADDR & SLAVE_ADDR_MASK) ==
        (TIMER_BASE_ADDR & SLAVE_ADDR_MASK)) begin
      $error("GPIO and TIMER address windows must not overlap");
    end

    if ((GPIO_BASE_ADDR & SLAVE_OFFSET_MASK) != '0) begin
      $error("GPIO_BASE_ADDR must be aligned to the APB slave address window");
    end

    if ((TIMER_BASE_ADDR & SLAVE_OFFSET_MASK) != '0) begin
      $error("TIMER_BASE_ADDR must be aligned to the APB slave address window");
    end
  end

  assign local_paddr = PADDR[SLAVE_ADDR_WIDTH-1:0];

  assign gpio_addr_hit =
      ((PADDR & SLAVE_ADDR_MASK) == (GPIO_BASE_ADDR & SLAVE_ADDR_MASK));
  assign timer_addr_hit =
      ((PADDR & SLAVE_ADDR_MASK) == (TIMER_BASE_ADDR & SLAVE_ADDR_MASK));

  assign psel_gpio  = PSEL && gpio_addr_hit;
  assign psel_timer = PSEL && timer_addr_hit;
  assign decode_error = PSEL && PENABLE && !gpio_addr_hit && !timer_addr_hit;

  apb_gpio #(
    .ADDR_WIDTH      (SLAVE_ADDR_WIDTH),
    .DATA_WIDTH      (DATA_WIDTH),
    .GPIO_WIDTH      (GPIO_WIDTH),
    .APB_WAIT_CYCLES (GPIO_WAIT_CYCLES)
  ) u_gpio (
    .PCLK      (PCLK),
    .PRESETn   (PRESETn),
    .PADDR     (local_paddr),
    .PWDATA    (PWDATA),
    .PWRITE    (PWRITE),
    .PENABLE   (PENABLE),
    .PSTRB     (PSTRB),
    .PSEL      (psel_gpio),
    .PPROT     (PPROT),
    .PRDATA    (gpio_prdata),
    .PREADY    (gpio_pready),
    .PSLVERR   (gpio_pslverr),
    .gpio_pins (gpio_pins)
  );

  apb_timer #(
    .ADDR_WIDTH      (SLAVE_ADDR_WIDTH),
    .DATA_WIDTH      (DATA_WIDTH),
    .NUM_REGS        (3),
    .APB_WAIT_CYCLES (TIMER_WAIT_CYCLES)
  ) u_timer (
    .PCLK    (PCLK),
    .PRESETn (PRESETn),
    .PADDR   (local_paddr),
    .PWDATA  (PWDATA),
    .PWRITE  (PWRITE),
    .PENABLE (PENABLE),
    .PSTRB   (PSTRB),
    .PSEL    (psel_timer),
    .PPROT   (PPROT),
    .PRDATA  (timer_prdata),
    .PREADY  (timer_pready),
    .PSLVERR (timer_pslverr),
    .irq_o   (timer_irq_o)
  );

  always_comb begin
    PRDATA  = '0;
    PREADY  = 1'b1;
    PSLVERR = 1'b0;

    if (PSEL) begin
      if (gpio_addr_hit) begin
        PRDATA  = gpio_prdata;
        PREADY  = gpio_pready;
        PSLVERR = gpio_pslverr;
      end
      else if (timer_addr_hit) begin
        PRDATA  = timer_prdata;
        PREADY  = timer_pready;
        PSLVERR = timer_pslverr;
      end
      else begin
        PSLVERR = decode_error;
      end
    end
  end

endmodule : apb_subsystem
