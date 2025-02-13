module RangeFinder
    #(parameter WIDTH=16)
    (input logic [WIDTH-1:0] data_in,
     input logic clock, reset,
     input logic go, finish,
     output logic [WIDTH-1:0] range,
     output logic debug_error);

    logic [WIDTH-1:0] max, next_max;
    logic [WIDTH-1:0] min, next_min;
    typedef enum logic {IDLE, BUSY} state_type;
    state_type current_state, next_state;

    logic reg_debug_error, next_debug_error;

    always_ff @(posedge clock or posedge reset) begin 
        if(reset) begin
            current_state <= IDLE;
            reg_debug_error <= 0;
            max <= 0;
            min <= 0;
        end else begin
            current_state <= next_state;
            reg_debug_error <= next_debug_error;
            max <= next_max;
            min <= next_min;
        end
    end

    always_comb begin
        next_state = current_state;
        next_max = (data_in > max)? data_in:max;
        next_min = (data_in < min)? data_in:min;
        next_debug_error = reg_debug_error;
        if((current_state == IDLE) && go) begin
            next_state = BUSY;
            next_max = data_in;
            next_min = data_in;
            next_debug_error = 0;
        end 
        if((current_state == BUSY) && go) begin
            next_debug_error = 1;
        end 
        if((current_state == IDLE) && finish) begin
            next_debug_error = 1;
        end 
        if((current_state == BUSY) && finish) begin
            next_debug_error = 0;
            next_state = IDLE;
        end 
        if(go && finish) begin
            next_state = IDLE;
        end 
    end

    assign range = (current_state == IDLE)? (max - min) : (next_max - next_min);
    assign debug_error = reg_debug_error;

endmodule
