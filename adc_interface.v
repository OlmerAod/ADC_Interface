module adc_interface(clk,
							SCLK, 
							data_bus_in, 
							transfer_sw,
							CS,
							ADC_Din, 
							data_bus_out, 
							ADC_Dout, 
							ready);

input clk;
input transfer_sw;
output reg CS = 1'b1;
reg [4:0] counter = 5'b11111;

//Master to ADC transfer + counter logics
input [15:0] data_bus_in;

reg [15:0] data_bus_in_reg = 0;

output ADC_Din;
assign ADC_Din = data_bus_in_reg[15];

output SCLK;
assign SCLK = counter[0]&&~CS;

output ready;
assign ready = ~CS;

always@(posedge clk)
begin
	if (counter[0] == 0)
	data_bus_in_reg <= data_bus_in_reg << 1;
	
	if(transfer_sw)
		begin
		CS <= 1'b0;
		data_bus_in_reg <= data_bus_in;
		end
	
	if (~CS)
		counter <= counter-1;
	if (counter == 5'b00000)
		CS <= 1'b1;
end


// ADC => Master transfer logics
output [15:0] data_bus_out;
reg [15:0] data_bus_out_reg;
input ADC_Dout;

assign data_bus_out = transfer_sw?data_bus_out_reg:0;

always@(posedge clk)
begin
	if (~CS && counter[0] == 0) 
	begin
		data_bus_out_reg <= data_bus_out_reg << 1;
		data_bus_out_reg[0] <= ADC_Dout;
	end
end

endmodule