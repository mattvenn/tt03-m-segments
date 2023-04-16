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
	wire temp_pwm_out, temp_delay;
	assign io_out[6:0] = {in_measurement, in_transition_ph2, in_transition_ph1, in_transition_ph0, in_transition, in_precharge, in_reset};
	assign io_out[7] = temp_pwm_out;

	// definition of internal wires and regs
    wire tempsens_en;
	wire transition_del1, transition_del2;
	wire in_reset, in_precharge, in_transition, in_transition_ph0, in_transition_ph1, in_transition_ph2, in_measurement;
	wire tempsens_measure;
	wire [N_VDAC-1:0] tempsens_dat;
	reg [1:0] ctrl_state;
	wire [3:0] digit;

	// control state machine
	localparam RESET = 2'd0;
	localparam PRECHARGE = 2'd1;
	localparam TRANSITION = 2'd2;
	localparam MEASURE = 2'd3;

	// VDAC max and min value
	localparam VMAX = {N_VDAC{1'b1}};
	localparam VMIN = {N_VDAC{1'b0}};

	// create state signals based on state of state machine
	assign in_reset = (ctrl_state == RESET);
	assign in_precharge = (ctrl_state == PRECHARGE);
	assign in_transition = (ctrl_state == TRANSITION);
	assign in_transition_ph0 = in_transition & ~transition_del1 & ~transition_del2;
	assign in_transition_ph1 = in_transition &  transition_del1 & ~transition_del2;
	assign in_transition_ph2 = in_transition &  transition_del1 &  transition_del2;
	assign in_measurement = (ctrl_state == MEASURE);

	// create temperature sensor input signal based on state signals, gate output to
	assign tempsens_en = in_reset ? 1'b0 : 1'b1;
	assign tempsens_dat =		in_precharge		? VMAX : 
								in_transition_ph0	? VMIN :
								in_transition_ph1	? VMIN :
								in_transition_ph2	? tempsens_cfg :
								in_measurement		? tempsens_cfg :
								VMAX;
	assign tempsens_measure = 	in_precharge		? 1'b0 :
								in_transition_ph0	? 1'b0 :
								in_transition_ph1	? 1'b1 :
								in_transition_ph2	? 1'b1 :			
								in_measurement 		? 1'b1 :
								1'b0;
	// form a nice PWM signal (active high time is proportional the temperature)
	assign temp_pwm_out = (in_transition_ph2 | in_measurement) & temp_delay;

	// display state on number LED
	assign digit = {2'b00,ctrl_state};

	// state machine implementation for temperature sensor control
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

    // instantiate temperature-dependent delay (this is the core circuit)
    tempsense #(.DAC_RESOLUTION(N_VDAC), .CAP_LOAD(10)) temp1 (
        .i_dac_data(tempsens_dat),
        .i_dac_en(tempsens_en),
        .i_precharge_n(tempsens_measure),
        .o_tempdelay(temp_delay)
    );

	// instantiate delay cells to make a delayed transition when switching VDAC
	delay_cell #(.NDELAY(4)) del1 (
		.i_in(in_transition),
		.o_del(transition_del1)
	);
	delay_cell #(.NDELAY(4)) del2 (
		.i_in(transition_del1 & en_quick_transition),
		.o_del(transition_del2)
	);

    // instantiate segment display decoder
    seg7 disp1 (
        .i_disp(digit),
        .o_segments(led_out)
    );

endmodule // hpretl_tt03_temperature_sensor
