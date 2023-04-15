//  Copyright 2023 Harald Pretl
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//		http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

`ifndef __DELAY_CELL__
`define __DELAY_CELL__

`default_nettype none
//`include "/foss/pdks/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
//`include "/foss/pdks/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v"

module delay_cell #(parameter NDELAY = 3) (
	input wire	i_in,
	output wire	o_del
);

	wire [0:NDELAY] del;
	wire [0:NDELAY-1] del_n;

	assign del[0] = i_in;
	assign o_del = del[NDELAY];

	genvar i;
	generate
		for (i=0; i < NDELAY; i=i+1) begin : delay_chain
`ifdef SIMULATION
			#1 del_n[i] = ~del[i];
			#1 del[i+1] = ~del_n[i];
`else
			sky130_fd_sc_hd__inv_1 inv1 (.A(del[i]),.Y(del_n[i]));
			sky130_fd_sc_hd__inv_1 inv2 (.A(del_n[i]),.Y(del[i+1]));
`endif
		end
  	endgenerate

endmodule // delay_cell
`endif
