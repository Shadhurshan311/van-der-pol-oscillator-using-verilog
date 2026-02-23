`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2026 04:31:20 PM
// Design Name: 
// Module Name: van_der_pol
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// Van der Pol Oscillator - CORRECTED VERSION
// Equation: d²x/dt² - μ(1-x²)(dx/dt) + x = 0
// This version properly outputs results at each iteration

module van_der_pol_simple(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [31:0] x_init,
    input wire [31:0] u_init,
    input wire [31:0] dt,
    input wire [31:0] mu,
    input wire [31:0] t_max,
    output reg [31:0] x_out,
    output reg [31:0] u_out,
    output reg [31:0] t_out,
    output reg done,
    output reg valid
);

    // Fixed-point: Q16.16
    localparam FRAC_BITS = 16;
    localparam ONE = 32'h00010000;
    
    // States
    localparam IDLE = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam DONE_STATE = 2'd2;
    
    reg [1:0] state;
    reg [31:0] x, u, t;
    
    // Intermediate calculations
    wire signed [63:0] x_sq_full;
    wire signed [31:0] x_squared;
    wire signed [31:0] one_minus_x_sq;
    wire signed [63:0] damping_full;
    wire signed [31:0] damping_term;
    wire signed [63:0] du_dt_full;
    wire signed [31:0] du_dt;
    wire signed [63:0] dx_dt_scaled;
    wire signed [63:0] du_dt_scaled;
    
    // Calculate x²
    assign x_sq_full = $signed(x) * $signed(x);
    assign x_squared = x_sq_full[47:16];  // Take middle 32 bits after mult
    
    // Calculate (1 - x²)
    assign one_minus_x_sq = ONE - x_squared;
    
    // Calculate μ(1-x²)
    assign damping_full = $signed(mu) * $signed(one_minus_x_sq);
    assign damping_term = damping_full[47:16];
    
    // Calculate du/dt = μ(1-x²)u - x
    assign du_dt_full = $signed(damping_term) * $signed(u);
    assign du_dt = du_dt_full[47:16] - x;
    
    // Scale by dt
    assign dx_dt_scaled = $signed(u) * $signed(dt);
    assign du_dt_scaled = $signed(du_dt) * $signed(dt);
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            x <= 0;
            u <= 0;
            t <= 0;
            x_out <= 0;
            u_out <= 0;
            t_out <= 0;
            done <= 0;
            valid <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    valid <= 0;
                    done <= 0;
                    if (start) begin
                        x <= x_init;
                        u <= u_init;
                        t <= 0;
                        state <= COMPUTE;
                    end
                end
                
                COMPUTE: begin
                    if (t < t_max) begin
                        // Euler method update (all in one cycle)
                        x <= x + dx_dt_scaled[47:16];
                        u <= u + du_dt_scaled[47:16];
                        t <= t + dt;
                        
                        // Output current values
                        x_out <= x;
                        u_out <= u;
                        t_out <= t;
                        valid <= 1;
                    end
                    else begin
                        state <= DONE_STATE;
                        done <= 1;
                        valid <= 1;
                        x_out <= x;
                        u_out <= u;
                        t_out <= t;
                    end
                end
                
                DONE_STATE: begin
                    valid <= 1;
                    done <= 1;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule