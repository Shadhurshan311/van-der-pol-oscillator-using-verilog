`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2026 04:33:22 PM
// Design Name: 
// Module Name: tb_van_der_pol
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
/////////////////////////////////////////////////////////////////////////////////

module tb_van_der_pol;

    reg clk;
    reg rst;
    reg start;
    reg [31:0] x_init;
    reg [31:0] u_init;
    reg [31:0] dt;
    reg [31:0] mu;
    reg [31:0] t_max;
    
    wire [31:0] x_out;
    wire [31:0] u_out;
    wire [31:0] t_out;
    wire done;
    wire valid;
    
    integer csv_file;
    integer txt_file;
    integer iteration_count;
    
    localparam FRAC_BITS = 16;
    real x_real, u_real, t_real;
    real x_max, x_min, u_max, u_min;
    
    // Instantiate design
    van_der_pol_simple uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x_init(x_init),
        .u_init(u_init),
        .dt(dt),
        .mu(mu),
        .t_max(t_max),
        .x_out(x_out),
        .u_out(u_out),
        .t_out(t_out),
        .done(done),
        .valid(valid)
    );
    
    // Fast clock (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Convert real to fixed-point
    function [31:0] real_to_fixed;
        input real value;
        begin
            real_to_fixed = $rtoi(value * (2.0 ** FRAC_BITS));
        end
    endfunction
    
    // Convert fixed-point to real
    function real fixed_to_real;
        input [31:0] fixed_value;
        integer signed_val;
        begin
            signed_val = fixed_value;
            fixed_to_real = signed_val / (2.0 ** FRAC_BITS);
        end
    endfunction
    
    initial begin
        // Initialize
        rst = 1;
        start = 0;
        iteration_count = 0;
        x_max = -1000.0;
        x_min = 1000.0;
        u_max = -1000.0;
        u_min = 1000.0;
        
        // Parameters
        mu = real_to_fixed(1.0);
        x_init = real_to_fixed(1.0);
        u_init = real_to_fixed(0.0);
        dt = real_to_fixed(0.1);
        t_max = real_to_fixed(10.0);
        
        // Create CSV file with header
        csv_file = $fopen("vanderpol_data.csv", "w");
        $fwrite(csv_file, "time,position,velocity\n");
        
        // Create detailed text file
        txt_file = $fopen("vanderpol_results.txt", "w");
        $fwrite(txt_file, "========================================\n");
        $fwrite(txt_file, "Van der Pol Oscillator Simulation Results\n");
        $fwrite(txt_file, "========================================\n\n");
        $fwrite(txt_file, "Simulation Parameters:\n");
        $fwrite(txt_file, "---------------------\n");
        $fwrite(txt_file, "  mu (nonlinearity parameter) = 1.0\n");
        $fwrite(txt_file, "  x(0) (initial position)     = 1.0\n");
        $fwrite(txt_file, "  u(0) (initial velocity)     = 0.0\n");
        $fwrite(txt_file, "  dt (time step)              = 0.1\n");
        $fwrite(txt_file, "  t_max (maximum time)        = 10.0\n\n");
        $fwrite(txt_file, "Differential Equation:\n");
        $fwrite(txt_file, "---------------------\n");
        $fwrite(txt_file, "  d²x/dt² - μ(1-x²)(dx/dt) + x = 0\n");
        $fwrite(txt_file, "  where u = dx/dt (velocity)\n\n");
        $fwrite(txt_file, "========================================\n");
        $fwrite(txt_file, "Simulation Data:\n");
        $fwrite(txt_file, "========================================\n\n");
        $fwrite(txt_file, "%-10s %-12s %-15s %-15s\n", "Iteration", "Time", "Position (x)", "Velocity (u)");
        $fwrite(txt_file, "----------------------------------------------------------------\n");
        
        // Console output
        $display("\n========================================");
        $display("Van der Pol Oscillator Simulation");
        $display("========================================");
        $display("Parameters:");
        $display("  mu = 1.0, x0 = 1.0, u0 = 0.0");
        $display("  dt = 0.1, t_max = 10.0");
        $display("\nRunning simulation...");
        $display("Output files:");
        $display("  - vanderpol_data.csv (for plotting)");
        $display("  - vanderpol_results.txt (detailed report)\n");
        
        // Reset
        #20 rst = 0;
        #10 start = 1;
        #10 start = 0;
        
        // Monitor outputs and write to both files
        while (!done) begin
            @(posedge clk);
            if (valid && !done) begin
                iteration_count = iteration_count + 1;
                x_real = fixed_to_real(x_out);
                u_real = fixed_to_real(u_out);
                t_real = fixed_to_real(t_out);
                
                // Track min/max values
                if (x_real > x_max) x_max = x_real;
                if (x_real < x_min) x_min = x_real;
                if (u_real > u_max) u_max = u_real;
                if (u_real < u_min) u_min = u_real;
                
                // Write to CSV (all data points)
                $fwrite(csv_file, "%f,%f,%f\n", t_real, x_real, u_real);
                
                // Write to text file (every point for small dataset)
                $fwrite(txt_file, "%-10d %-12.6f %-15.9f %-15.9f\n", 
                        iteration_count, t_real, x_real, u_real);
                
                // Console progress every 10 iterations
                if (iteration_count % 10 == 0) begin
                    $display("  Progress: %3d iterations, t = %.2f", iteration_count, t_real);
                end
            end
        end
        
        // Final iteration
        @(posedge clk);
        x_real = fixed_to_real(x_out);
        u_real = fixed_to_real(u_out);
        t_real = fixed_to_real(t_out);
        
        // Write final point
        $fwrite(csv_file, "%f,%f,%f\n", t_real, x_real, u_real);
        $fwrite(txt_file, "%-10d %-12.6f %-15.9f %-15.9f\n", 
                iteration_count+1, t_real, x_real, u_real);
        
        // Write summary to text file
        $fwrite(txt_file, "\n========================================\n");
        $fwrite(txt_file, "Simulation Summary:\n");
        $fwrite(txt_file, "========================================\n\n");
        $fwrite(txt_file, "Execution Statistics:\n");
        $fwrite(txt_file, "--------------------\n");
        $fwrite(txt_file, "  Total iterations:     %d\n", iteration_count);
        $fwrite(txt_file, "  Final time:           %.6f\n", t_real);
        $fwrite(txt_file, "  Time step (dt):       %.6f\n\n", 0.1);
        
        $fwrite(txt_file, "Final State:\n");
        $fwrite(txt_file, "------------\n");
        $fwrite(txt_file, "  Position x(t):        %.9f\n", x_real);
        $fwrite(txt_file, "  Velocity u(t):        %.9f\n\n", u_real);
        
        $fwrite(txt_file, "Statistical Analysis:\n");
        $fwrite(txt_file, "--------------------\n");
        $fwrite(txt_file, "Position (x):\n");
        $fwrite(txt_file, "  Maximum value:        %.9f\n", x_max);
        $fwrite(txt_file, "  Minimum value:        %.9f\n", x_min);
        $fwrite(txt_file, "  Peak-to-peak:         %.9f\n", x_max - x_min);
        $fwrite(txt_file, "  Amplitude:            %.9f\n\n", (x_max - x_min)/2.0);
        
        $fwrite(txt_file, "Velocity (u):\n");
        $fwrite(txt_file, "  Maximum value:        %.9f\n", u_max);
        $fwrite(txt_file, "  Minimum value:        %.9f\n", u_min);
        $fwrite(txt_file, "  Peak-to-peak:         %.9f\n", u_max - u_min);
        $fwrite(txt_file, "  Amplitude:            %.9f\n\n", (u_max - u_min)/2.0);
        
        $fwrite(txt_file, "Observations:\n");
        $fwrite(txt_file, "-------------\n");
        $fwrite(txt_file, "- The Van der Pol oscillator exhibits limit cycle behavior\n");
        $fwrite(txt_file, "- For mu=1.0, the system shows moderate nonlinearity\n");
        $fwrite(txt_file, "- The oscillation converges to a stable periodic orbit\n");
        $fwrite(txt_file, "- This is characteristic of self-sustained oscillations\n\n");
        
        $fwrite(txt_file, "========================================\n");
        $fwrite(txt_file, "End of Report\n");
        $fwrite(txt_file, "========================================\n");
        
        // Console summary
        $display("\n========================================");
        $display("Simulation Complete!");
        $display("========================================");
        $display("Total iterations: %d", iteration_count);
        $display("Final time: %.6f", t_real);
        $display("Final position x: %.9f", x_real);
        $display("Final velocity u: %.9f", u_real);
        $display("\nStatistics:");
        $display("  Position range: [%.6f, %.6f]", x_min, x_max);
        $display("  Velocity range: [%.6f, %.6f]", u_min, u_max);
        $display("  Amplitude: %.6f", (x_max - x_min)/2.0);
        $display("\nOutput files created:");
        $display("  ✓ vanderpol_data.csv (for plotting)");
        $display("  ✓ vanderpol_results.txt (detailed report)");
        $display("========================================\n");
        
        $fclose(csv_file);
        $fclose(txt_file);
        #100;
        $finish;
    end

endmodule