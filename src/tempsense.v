//  Copyright 2022-2023 Manuel Moser and Harald Pretl
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

`ifndef __TEMPSENSE__
`define __TEMPSENSE__

`default_nettype none
`timescale 1ns/1ps
`ifndef SIMULATION
`include "vdac.v"
`endif
//`include "/foss/pdks/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
//`include "/foss/pdks/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v"

module tempsense #( parameter DAC_RESOLUTION = 6, parameter CAP_LOAD = 3 )(
      input wire [DAC_RESOLUTION-1:0]     i_dac_data,
      input wire                          i_dac_en,
      input wire                          i_precharge_n,
      output wire                         o_tempdelay
  );

`ifdef SIMULATION
      integer capstate;
      
      wire precharge_del_n;
      assign #300 precharge_del_n = i_precharge_n;
      assign o_tempdelay = i_dac_en & (~precharge_del_n);
`else
      // Voltage-mode digital-to-analog converter (VDAC)
      wire dac_vout_ana_;
      vdac #(.BITWIDTH(DAC_RESOLUTION)) dac (
            .i_data(i_dac_data),
            .i_enable(i_dac_en),
            .vout_ana_(dac_vout_ana_)
      );

      // Digitally-controled delay cell (dcdel)
      wire dcdel_capnode_ana_;
      wire dcdel_out;
      wire dcdel_out_n;
      wire tie0 = 1'b0;
      (* keep = "true" *) wire [0:CAP_LOAD-1] dummy_ana_;

      sky130_fd_sc_hd__einvp_1 dcdc (.A(i_precharge_n), .TE(dac_vout_ana_), .Z(dcdel_capnode_ana_));
      
      sky130_fd_sc_hd__inv_1 inv1 (.A(dcdel_capnode_ana_),.Y(dcdel_out_n));
      sky130_fd_sc_hd__inv_1 inv2 (.A(dcdel_out_n),.Y(o_tempdelay));

      genvar i;
	generate
		for (i=0; i < CAP_LOAD; i=i+1) begin : capload
			(* keep = "true" *) sky130_fd_sc_hd__einvp_1 cap (.A(dcdel_capnode_ana_), .TE(tie0), .Z(dummy_ana_[i]));
		end
  	endgenerate
`endif

endmodule // tempsense
`endif
