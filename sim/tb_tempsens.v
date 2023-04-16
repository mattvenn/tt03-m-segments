`default_nettype none
`define SIMULATION
`include "hpretl_tt03_temperature_sensor.v"
`timescale 1us/1ns

module tb_tempsens;

    reg CLK = 0;
    reg RESET = 1;
    reg EN_QUICK_TRANS = 0;
    reg [4:0] TEMPSENS_CFG = 3;
    wire TEMPSENS_PWM;
    wire [6:0] LEDDISP;


    initial begin
        $dumpfile ("tb_tempsens.vcd");
        $dumpvars (0, tb_tempsens);

        #100 RESET = 0;

        #1000 $finish;        
    end

    // make clock 10kHz
    always #50 CLK = ~CLK;


   // wire up the inputs and outputs
    wire [7:0] inputs = {TEMPSENS_CFG, EN_QUICK_TRANS, RESET, CLK};
    wire [7:0] outputs;
    assign LEDDISP = outputs[6:0];
    assign TEMPSENS_PWM = outputs[7];

    // instantiate the DUT
    hpretl_tt03_temperature_sensor tempsens (
        .io_in  (inputs),
        .io_out (outputs)
    );

endmodule // tb_tempsens
