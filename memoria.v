module memoria(clock, addr, data, wren, q);

input clock, wren;
input [3:0]addr;
input [3:0]data;

reg [3:0]m[15:0];

output reg [7:0]q;

initial
begin

	m[0]  <= 4'b0101;
	m[4]  <= 4'b0100;
	m[5]  <= 4'b0101;
	m[9]  <= 4'b1001;
	m[10] <= 4'b1010;
	m[14] <= 4'b1110;
	m[15] <= 4'b1111;

end

always @(posedge clock)
begin
	if(wren) //escrita
	begin
		m[addr] <= data;
		q <= {addr, data};
	end
	else //leitura
	begin
		q <= {addr, m[addr]};
	end
end

endmodule
