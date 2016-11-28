`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2016 10:32:08 PM
// Design Name: 
// Module Name: ScopeSettings
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


module ScopeSettings
    #(parameter DATA_BITS = 12, SAMPLE_PERIOD_BITS = 6, SCALE_FACTOR_SIZE = 10,
      parameter TRIGGER_THRESHOLD_ADJUST = 3 << (DATA_BITS - 7))
    (input clock,
     input [15:0] sw,
     input btnu, input btnd, input btnc, input btnl,
     input signed [DATA_BITS-1:0] signalMinChannel1,
     input signed [DATA_BITS-1:0] signalMaxChannel1,
     input [DATA_BITS-1:0] signalPeriod,
     output reg signed [DATA_BITS-1:0]triggerThreshold = 0,
     output reg [SCALE_FACTOR_SIZE-1:0]verticalScaleFactorTimes8Channel1 = 8,
     output reg [SCALE_FACTOR_SIZE-1:0]verticalScaleFactorTimes8Channel2 = 8,
     output reg [SAMPLE_PERIOD_BITS-1:0]samplePeriod = 0,
     output reg channelSelected
    );
    
    wire [SCALE_FACTOR_SIZE-1:0] optimalScale;
    wire [SCALE_FACTOR_SIZE-1:0] biggestScaleToSeeMaxChannel1 = (512 * 8 / `ABS(signalMaxChannel1));
    wire [SCALE_FACTOR_SIZE-1:0] biggestScaleToSeeMinChannel1 = (512 * 8 / `ABS(signalMinChannel1));
    
    assign optimalScale = (biggestScaleToSeeMaxChannel1 > biggestScaleToSeeMinChannel1) ? 
                            biggestScaleToSeeMinChannel1 : biggestScaleToSeeMaxChannel1;
    
    always @(posedge clock) begin
        // manual adjust
        case (sw[3:0])
          4'b0000: 
             // adjust trigger threshold
             if (btnu) triggerThreshold <= triggerThreshold + TRIGGER_THRESHOLD_ADJUST;
             else if (btnd) triggerThreshold <= triggerThreshold - TRIGGER_THRESHOLD_ADJUST;
         4'b0001:
            // adjust vertical scaling channel1
            if (btnu) verticalScaleFactorTimes8Channel1 <= verticalScaleFactorTimes8Channel1 * 2;
            else if (btnd) verticalScaleFactorTimes8Channel1 <= verticalScaleFactorTimes8Channel1 / 2;
         4'b0010:
            // adjust vertical scaling channel2
             if (btnu) verticalScaleFactorTimes8Channel2 <= verticalScaleFactorTimes8Channel2 * 2;
             else if (btnd) verticalScaleFactorTimes8Channel2 <= verticalScaleFactorTimes8Channel2 / 2;
         4'b0100:
            // adjust sample rate
            if (btnu) samplePeriod <= samplePeriod + 1;
            else if (btnd) samplePeriod <= samplePeriod - 1;
         4'b1000:
            // select channel to trigger on
            if (btnu) channelSelected = ~channelSelected;
            else if (btnd) channelSelected = ~channelSelected;
       endcase
       
       // autoset
       if (btnl) begin
            triggerThreshold <= (signalMaxChannel1 + signalMinChannel1) / 2;
            // / 64 = / 512 * 8
            verticalScaleFactorTimes8Channel1 <= optimalScale;
            samplePeriod <= (3 * signalPeriod / 1280);
       end
            
       // reset to default settings
       if (btnc) begin
            triggerThreshold <= 0;
            verticalScaleFactorTimes8Channel1 <= 8;
            samplePeriod <= 0;
       end
    end
endmodule
