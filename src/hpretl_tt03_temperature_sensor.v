//	Copyright 2023 Harald Pretl
//
//	Licensed under the Apache License, Version 2.0 (the "License");
//	you may not use this file except in compliance with the License.
//	You may obtain a copy of the License at
//
//		http://www.apache.org/licenses/LICENSE-2.0
//
//	Unless required by applicable law or agreed to in writing, software
//	distributed under the License is distributed on an "AS IS" BASIS,
//	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//	See the License for the specific language governing permissions and
//	limitations under the License.

`default_nettype none

`include "tempsense.v"
`include "seg7.v"
`include "delay_cell.v"

module hpretl_tt03_temperature_sensor (
	input [7:0]		io_in,
	output [7:0]	io_out
);

	// PCB IO assignement:
	// io_in[0] = 10kHz clock or pushbutton or dipswitch
	// io_in[7:1] = dipswitch[8:2]
	// io_out[6:0] = 7-segment LED
	// io_out[7] = decimal point

	// VDAC number of bits
	localparam N_VDAC = 5;

	// definition of external inputs
	wire clk = io_in[0];
	wire reset = io_in[1];
	wire en_quick_transition = io_in[2]; // if set to 1 then TRANSITION is only a short period
	wire [N_VDAC-1:0] tempsens_cfg = io_in[7:3];

	// definition of external outputs
	wire [6:0] led_out;
	wire dot_out;
	assign io_out[6:0] = led_out;
	assign io_out[7] = dot_out;

	// definition of internal wires and regs
    wire tempsens_en;
    wire tempsens_precharge;
	wire tempsens_precharge_del;
	wire next_state;
	wire tempsens_measure;
	wire [N_VDAC-1:0] tempsens_dat;
	reg [1:0] ctrl_state;
	wire [3:0] digit;

	// control state machine
	localparam RESET = 2'd0;
	localparam PRECHARGE = 2'd1;
	localparam TRANSITION = 2'd2;
	localparam MEASURE = 2'd3;

	// VDAC max value
	localparam VMAX = {N_VDAC{1'b1}};

	// assign control signals based on state
	assign tempsens_en = (ctrl_state == RESET) ? 1'b0 : 1'b1;
	assign tempsens_precharge = (ctrl_state == PRECHARGE) ? 1'b1 : 1'b0;
	assign tempsens_dat = (ctrl_state == PRECHARGE) ? VMAX : tempsens_cfg;
	assign tempsens_measure = ((ctrl_state == MEASURE) || ((ctrl_state == TRANSITION) & next_state)) ? 1'b1 : 1'b0;
	assign next_state = ~tempsens_precharge_del & en_quick_transition;
	//assign digit = {2'b00,ctrl_state};
	assign digit = 4'b0000;

	// state machine implementation
    always @(posedge clk) begin
        if (reset) begin
			// if reset, set state to RESET
			ctrl_state <= RESET;
        end else begin
			// normal operation, cycle through states
			case (ctrl_state)
				RESET:		ctrl_state <= PRECHARGE;
				PRECHARGE:	ctrl_state <= TRANSITION;
				TRANSITION:	ctrl_state <= MEASURE;
				MEASURE:	ctrl_state <= PRECHARGE;
				default:	ctrl_state <= RESET;
			endcase
		end
	end

    // instantiate temperature-dependent delay
    tempsense #(.DAC_RESOLUTION(N_VDAC)) temp1 (
        .i_dac_data(tempsens_dat),
        .i_dac_en(tempsens_en),
        .i_precharge_n(tempsens_measure),
        .o_tempdelay(dot_out)
    );

	// instantiate delay cell to make a delayed transition when switching VDAC
	delay_cell del1 (
		.i_in(tempsens_precharge),
		.o_del(tempsens_precharge_del)
	);

    // instantiate segment display
    seg7 disp1 (
        .i_disp(digit),
        .o_segments(led_out)
    );

endmodule // hpretl_tt03_temperature_sensor
