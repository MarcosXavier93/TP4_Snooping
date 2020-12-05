module arbiter(bus0, bus1, bus2, mem_entrada, barramento_saida, mem_saida);

input [14:0]bus0, bus1, bus2;
input [7:0]mem_entrada;

output reg [14:0]barramento_saida;
output reg [8:0]mem_saida;

parameter Invalid = 2'b00;
parameter Shared = 2'b01;
parameter Modified = 2'b10;
parameter Exclusive = 2'b11;

// Messages e CPU
parameter Nothing = 3'b000;
parameter ReadMiss = 3'b001;
parameter ReadHit = 3'b010;
parameter WriteMiss = 3'b011;
parameter WriteHit = 3'b100;
parameter Invalidate = 3'b101;
parameter MemoryData = 3'b110;

//BUS
`define ID 14:13 
`define Message 12:10
`define SharedBlock 9
`define WriteBack 8 
`define Address 7:4 
`define Data 3:0

//MEM
`define MemWren 8
`define MemAddress 7:4
`define MemData 3:0

always @(bus0, bus1, bus2)
begin
	
	//se a mensagem de P0 é válida, processa mensagem
	if(bus0[`Message] != Nothing)
	begin

		if(bus0[`WriteBack])
		begin
			mem_saida[`MemWren] <= 1'b1;
			mem_saida[`MemAddress] <= bus0[`Address];
			mem_saida[`MemData] <= bus0[`Data];
		end
		else
			mem_saida[`MemWren] <= 1'b0;

		if(bus0[`Message] == ReadMiss)
		begin
			mem_saida[`MemAddress] <= bus0[`Address];
			mem_saida[`MemData] <= bus0[`Data];
		end

		barramento_saida <= bus0;

	end
	//se a mensagem de P1 é válida, processa mensagem
	else if(bus1[`Message] != Nothing)
	begin

		if(bus1[`WriteBack])
		begin
			mem_saida[`MemWren] <= 1'b1;
			mem_saida[`MemAddress] <= bus1[`Address];
			mem_saida[`MemData] <= bus1[`Data];
		end
		else
			mem_saida[`MemWren] <= 1'b0;

		if(bus1[`Message] == ReadMiss)
		begin
			mem_saida[`MemAddress] <= bus1[`Address];
			mem_saida[`MemData] <= bus1[`Data];
		end

		barramento_saida <= bus1;

	end
	//se a mensagem de P2 é válida, processa mensagem
	else if(bus2[`Message] != Nothing)
	begin

		if(bus2[`WriteBack])
		begin
			mem_saida[`MemWren] <= 1'b1;
			mem_saida[`MemAddress] <= bus2[`Address];
			mem_saida[`MemData] <= bus2[`Data];
		end
		else
			mem_saida[`MemWren] <= 1'b0;

		if(bus2[`Message] == ReadMiss)
		begin
			mem_saida[`MemAddress] <= bus2[`Address];
			mem_saida[`MemData] <= bus2[`Data];
		end

		barramento_saida <= bus2;

	end
	//caso contrário, processa dado da memória
	else
	begin
		
		mem_saida[`MemWren] <= 1'b0;

		barramento_saida[`ID] <= 2'b11;
		barramento_saida[`Message] <= MemoryData;
		barramento_saida[`SharedBlock] <= 1'b0;
		barramento_saida[`WriteBack] <= 1'b0;
		barramento_saida[`Address] <= mem_entrada[`MemAddress];
		barramento_saida[`Data] <= mem_entrada[`MemData];

	end
end

endmodule

module maq_emissora(bit_escolha, op, estado_op, estado_prox_emissor, estado_wb_emissor, emissor_bus);

input bit_escolha; //escolha qual das maquinas de estado
reg [1:0] estado; //estado atual da mauqiona
reg teste;
input op; //leitura ou escrita
input estado_op; //se a op de leitura ou escrita de miss ou hit

output reg [1:0] estado_prox_emissor; //qual o proximo estado?
output reg estado_wb_emissor; //vai ter write-back?
output reg [1:0] emissor_bus; //bus geral que liga todos os processadores

parameter exclusive = 2'b10;
parameter shared   = 2'b01;
parameter invalid  = 2'b00;

parameter read  = 1'b0;
parameter write = 1'b1;

parameter read_miss = 2'b11;
parameter write_miss = 2'b01;
parameter invalidate = 2'b10;

parameter hit = 1'b1;
parameter miss = 1'b0;


initial 
	begin 
		estado = 2'b00;
	end

always @(op or bit_escolha) begin
	if(bit_escolha == 0) begin
		estado_wb_emissor = 0;
		emissor_bus = 0;

		case(estado)
			exclusive: begin
				if(estado_op == hit) begin
					estado_prox_emissor = exclusive;
				end
				else if (op == read) begin
					estado_prox_emissor = shared;
					estado_wb_emissor = 1'b1;
					emissor_bus = read_miss;
					end
				else if (op == write) begin
					estado_prox_emissor = exclusive;
					estado_wb_emissor = 1'b1;
					emissor_bus = write_miss;
				end
			end

			shared: begin
				if(op == read) begin
					estado_prox_emissor = shared;
					if(estado_op == miss) begin
						emissor_bus = read_miss;
					end
				end
				else if(op == write) begin
					estado_prox_emissor = exclusive;
					if(estado_op == hit) begin
						emissor_bus = invalidate;
					end
					else if(estado_op == miss) begin
						emissor_bus = write_miss;
					end
				end
			end
			invalid: begin
				if(op == read) begin
					estado_prox_emissor = shared;
					emissor_bus = read_miss;
				end
				else if(op == write) begin
					estado_prox_emissor = exclusive;
					emissor_bus = write_miss;
				end
			end
		endcase
	end
	estado = estado_prox_emissor;
end
endmodule


module maq_receptora(bit_escolha, receptor_bus, estado, estado_prox_receptor, estado_wb_receptor, aborta_acesso_mem);

input bit_escolha; //escolha qual das maquinas de estado
input [1:0] receptor_bus; //bus geral que liga todos os processadores
input [1:0] estado; //estado atual da mauqiona

output reg [1:0] estado_prox_receptor; //qual o proximo estado?
output reg estado_wb_receptor; //vai ter write-back?
output reg aborta_acesso_mem;

parameter exclusive = 2'b10;
parameter shared   = 2'b01;
parameter invalid  = 2'b00;

parameter read  = 1'b0;
parameter write = 1'b1;

parameter read_miss = 2'b11;
parameter write_miss = 2'b01;
parameter invalidate = 2'b10;

parameter hit = 1'b1;
parameter miss = 1'b0;


always @(estado or bit_escolha) begin
	if(bit_escolha == 1) begin
		estado_wb_receptor = 0;
		aborta_acesso_mem = 0;
		estado_prox_receptor = estado; //porque no invalido ele mantem

		case(estado)
			exclusive: begin
				if(receptor_bus == write_miss) begin
					aborta_acesso_mem = 1'b1;
					estado_wb_receptor = 1'b1;
					estado_prox_receptor = invalid;
				end
				else if(receptor_bus == read_miss) begin
					estado_prox_receptor = shared;
					aborta_acesso_mem = 1'b1;
					estado_wb_receptor = 1'b1;
				end
			end
			shared: begin
				if(receptor_bus == write_miss) begin
					estado_prox_receptor = invalid;
				end
				else if(receptor_bus == read_miss) begin
					estado_prox_receptor = shared;
				end
				else if(receptor_bus == invalidate) begin
					estado_prox_receptor = invalid;
				end
			end
		endcase
	end
end
endmodule


module cache(clock, cpuIn, busIn, busOut);

// states
parameter Invalid = 2'b00;
parameter Shared = 2'b01;
parameter Modified = 2'b10;
parameter Exclusive = 2'b11;

// Messages e CPU
parameter Nothing = 3'b000;
parameter ReadMiss = 3'b001;
parameter ReadHit = 3'b010;
parameter WriteMiss = 3'b011;
parameter WriteHit = 3'b100;
parameter Invalidate = 3'b101;
parameter MemoryData = 3'b110;

//CPU
`define cpuId 10:9
`define Instruction 8
`define cpuAddress 7:4
`define cpuData 3:0

//BUS
`define ID 14:13 
`define Message 12:10
`define SharedBlock 9
`define WriteBack 8 
`define Address 7:4 
`define Data 3:0 

//b
`define Tag 7:6
`define State 5:4
`define LineData 3:0

parameter PID = 2'b00;
input clock;

input[10:0]cpuIn;

input [14:0]busIn;

reg [7:0]b[3:0];

reg waiting_data, writing_back;

output reg [14:0]busOut;
initial
begin

	case(PID)
		
		/* B[INDEX]*/
	
		2'b00:
			begin 
			/*B0 - TAG | STATE | DATA  */ b[2'b00] <= {2'b00, 2'b00,  4'b0101};
			/*B2 - TAG | STATE | DATA  */ b[2'b10] <= {2'b00, 2'b01,   4'b0100};
			/*B3 - TAG | STATE | DATA  */ b[2'b11] <= {2'b00, 2'b01, 4'b1111};
			/*B1 - TAG | STATE | DATA  */ b[2'b01] <= {2'b10, 2'b00,  4'b0101};
			end
		2'b01:
			begin
			/*B0 - TAG | STATE | DATA  */ b[2'b00] <= {2'b00, 2'b00,  4'b0101};
			/*B2 - TAG | STATE | DATA  */ b[2'b10] <= {2'b11, 2'b10, 4'b1101};
			/*B3 - TAG | STATE | DATA  */ b[2'b11] <= {2'b00, 2'b01,  4'b1111};
			/*B1 - TAG | STATE | DATA  */ b[2'b01] <= {2'b10, 2'b01,   4'b1001};
			end
		2'b10:
		begin
			/*B0 - TAG | STATE | DATA  */ b[2'b00] <= {2'b11, 2'b01,  4'b1010};
			/*B2 - TAG | STATE | DATA  */ b[2'b10] <= {2'b00, 2'b01,  4'b0100};
			/*B3 - TAG | STATE | DATA  */ b[2'b11] <= {2'b00, 2'b00, 4'b0101};
			/*B1 - TAG | STATE | DATA  */ b[2'b01] <= {2'b10, 2'b00, 4'b0101};
			end
	
	endcase
	
	
	waiting_data <= 1'b0;
	busOut[`ID] <= PID;
end


	always@(posedge clock)
	begin
	
		if(waiting_data && (busIn[`Message] == MemoryData))
		begin
		
			b[{busIn[6], busIn[4]}][`LineData] <= busIn[`cpuData];
			b[{busIn[6], busIn[4]}][`Address] <= busIn[`cpuAddress];
			
			if(busIn[`SharedBlock])
				b[{busIn[6], busIn[4]}][`State] <= Shared;
			else
				b[{busIn[6], busIn[4]}][`State] <= Exclusive;
				
			waiting_data <= 1'b0;
			
		end
		
		if(writing_back)
		begin
		
			writing_back <= 1'b0;
			waiting_data <= 1'b1;
		end
		
		//comportamento executer
		if(cpuIn[`cpuId] == PID)
		begin
			
			case(b[{cpuIn[6], cpuIn[4]}][`State])
			
				Invalid:
				begin
					if((cpuIn[`Instruction] == 1'b1) && (b[{cpuIn[6], cpuIn[4]}][`Tag] != {cpuIn[7], cpuIn[5]})) //Write & Miss
					begin
						busOut[`Message] <= WriteMiss;
						busOut[`Address] <= cpuIn[`cpuAddress];
						
						b[{cpuIn[6], cpuIn[4]}][`State] <= Modified;
						b[{cpuIn[6], cpuIn[4]}][`LineData] <= cpuIn[`cpuData];
						b[{cpuIn[6], cpuIn[4]}][`Tag] <= {cpuIn[7], cpuIn[5]};
					end
					else if((cpuIn[`Instruction] == 1'b1) && (b[{cpuIn[6], cpuIn[4]}][`Tag] == {cpuIn[7], cpuIn[5]})) //Write & Hit
					begin
					
						busOut[`Message] <= WriteMiss;
						busOut[`Address] <= cpuIn[`cpuAddress];
						
						
						b[{cpuIn[6], cpuIn[4]}][`State] <= Modified;
						b[{cpuIn[6], cpuIn[4]}][`LineData] <= cpuIn[`cpuData];
						b[{cpuIn[6], cpuIn[4]}][`Tag] <= {cpuIn[7], cpuIn[5]};
					end
					
					//MESI
					
					else if((cpuIn[`Instruction] == 1'b0) && (b[{cpuIn[6], cpuIn[4]}][`Tag] != {cpuIn[7], cpuIn[5]})) //Read & Miss
					begin
						busOut[`Message] <= ReadMiss;
						busOut[`Address] <= cpuIn[`cpuAddress];
						
						waiting_data <= 1'b1;
					end
					else if((cpuIn[`Instruction] == 1'b0) && (b[{cpuIn[6], cpuIn[4]}][`Tag] == {cpuIn[7], cpuIn[5]})) //Read & Hit
					begin
					
						busOut[`Message] <= ReadMiss;
						busOut[`Address] <= cpuIn[`cpuAddress];
						
						waiting_data <= 1'b1;
					end
				end
				
				Shared:
				begin
					if((cpuIn[`Instruction] == 1'b0) && (b[{cpuIn[6], cpuIn[4]}][`Tag] != {cpuIn[7], cpuIn[5]})) //Read & Miss
					begin
						busOut[`Message] <= ReadMiss;
						busOut[`Address] <= cpuIn[`cpuAddress];
						
						waiting_data <= 1'b1;
					end
					else if ((cpuIn[`Instruction] == 1'b0) && (b[{cpuIn[6], cpuIn[4]}][`Tag] == {cpuIn[7], cpuIn[5]})) //Read & Hit
					begin
						busOut[`Message] <= Nothing;
					end
					else if((cpuIn[`Instruction] == 1'b1) && (b[{cpuIn[6], cpuIn[4]}][`Tag] == {cpuIn[7], cpuIn[5]})) //Write & Hit
					begin
						busOut[`Message] <= Invalidate;
						busOut[`Address] <= cpuIn[`cpuAddress];
						
						b[{cpuIn[6], cpuIn[4]}][`State] <= Modified;
						b[{cpuIn[6], cpuIn[4]}][`LineData] <= cpuIn[`cpuData];
					end
					else if((cpuIn[`Instruction] == 1'b1) && (b[{cpuIn[6], cpuIn[4]}][`Tag] != {cpuIn[7], cpuIn[5]})) //Write & Miss
					begin
						busOut[`Message] <= WriteMiss;
						busOut[`Address] <= cpuIn[`cpuAddress];
						
						b[{cpuIn[6], cpuIn[4]}][`State] <= Modified;
						b[{cpuIn[6], cpuIn[4]}][`LineData] <= cpuIn[`cpuData];
						b[{cpuIn[6], cpuIn[4]}][`Tag] <= {cpuIn[7], cpuIn[5]};
					end
				end		
				
				Modified:
				begin
					if((cpuIn[`Instruction] == 1'b0) && (b[{cpuIn[6], cpuIn[4]}][`Tag] != {cpuIn[7], cpuIn[5]})) //Read & Miss
					begin
					//problema
						busOut[`Message] <= MemoryData;
						busOut[`WriteBack] <= 1'b1;
						busOut[`Address] <= {b[{cpuIn[6], cpuIn[4]}][7], cpuIn[6], b[{cpuIn[6], cpuIn[4]}][6], cpuIn[4]};
						busOut[`Data] <= b[{cpuIn[6], cpuIn[4]}][`Data];
												
						writing_back <= 1'b1;
					end
					else if((cpuIn[`Instruction] == 1'b1) && (b[{cpuIn[6], cpuIn[4]}][`Tag] != {cpuIn[7], cpuIn[5]})) //Write & Miss
					begin
					//problema
						busOut[`Message] <= MemoryData;
						busOut[`WriteBack] <= 1'b1;
						busOut[`Address] <= {b[{cpuIn[6], cpuIn[4]}][7], cpuIn[6], b[{cpuIn[6], cpuIn[4]}][6], cpuIn[4]};
						busOut[`Data] <= b[{cpuIn[6], cpuIn[4]}][`Data];
						
						b[{cpuIn[6], cpuIn[4]}][`LineData] <= cpuIn[`cpuData];
						b[{cpuIn[6], cpuIn[4]}][`Tag] <= {cpuIn[7], cpuIn[5]};
						
						writing_back <= 1'b1;
					end
					else if((cpuIn[`Instruction] == 1'b1) && (b[{cpuIn[6], cpuIn[4]}][`Tag] == {cpuIn[7], cpuIn[5]})) //Write & Hit
					begin
						busOut[`Message] <= Nothing;
					end
					else if((cpuIn[`Instruction] == 1'b0) && (b[{cpuIn[6], cpuIn[4]}][`Tag] == {cpuIn[7], cpuIn[5]})) //Read & Hit
					begin
						busOut[`Message] <= Nothing;
					end
				end
				
				Exclusive: //MESI
				begin
					if((cpuIn[`Instruction] == 1'b0) && (b[{cpuIn[6], cpuIn[4]}][`Tag] == {cpuIn[7], cpuIn[5]})) //Read & Hit
					begin
						busOut[`Message] <= Nothing;
					end
					else if((cpuIn[`Instruction] == 1'b0) && (b[{cpuIn[6], cpuIn[4]}][`Tag] != {cpuIn[7], cpuIn[5]})) //Read & Miss
					begin
						busOut[`Message] <= ReadMiss;
						busOut[`Address] <= cpuIn[`cpuAddress];
						
						waiting_data <= 1'b1;
					end
					else if((cpuIn[`Instruction] == 1'b1) && (b[{cpuIn[6], cpuIn[4]}][`Tag] != {cpuIn[7], cpuIn[5]})) //Write & Miss
					begin
						b[{cpuIn[6], cpuIn[4]}][`State] <= Modified;
						b[{cpuIn[6], cpuIn[4]}][`LineData] <= cpuIn[`cpuData];
						b[{cpuIn[6], cpuIn[4]}][`Tag] <= {cpuIn[7], cpuIn[5]};
						
						busOut[`Message] <= WriteMiss;
						busOut[`Address] <= cpuIn[`cpuAddress];
					end  
					else if((cpuIn[`Instruction] == 1'b1) && (b[{cpuIn[6], cpuIn[4]}][`Tag] == {cpuIn[7], cpuIn[5]})) //Write & Hit
					begin
						b[{cpuIn[6], cpuIn[4]}][`State] <= Modified;
						b[{cpuIn[6], cpuIn[4]}][`LineData] <= cpuIn[`cpuData];
						
						busOut[`Message] <= WriteHit;
					end
				end
				
			endcase
		end
		else
		begin
			busOut[`Message] <= Nothing;
			busOut[`WriteBack] <= 1'b0;
		end
	
		//comportamento listener
		if((busIn[`ID] != PID) &&
			(busIn[`Message] != Nothing) &&
			(b[{busIn[6], busIn[4]}][`Tag] == {busIn[7], busIn[5]})) 
		begin
		
			case(b[{busIn[6], busIn[4]}][`State]) //b[INDEX][state]
					
				Shared:
				begin
					
					if((busIn[`Message] == WriteMiss) || (busIn[`Message] == Invalidate))
					begin
						b[{busIn[6], busIn[4]}][`State] <= Invalid;
						busOut[`Message] <= Nothing;
					
					end
					else if(busIn[`Message] == ReadMiss)
					begin
						
						b[{busIn[6], busIn[4]}][`State] <= Shared;
						
						busOut[`Message] <= MemoryData;
						busOut[`SharedBlock] <= 1'b1;
						busOut[`WriteBack] <= 1'b0;
						busOut[`Address] <= busIn[`Address];
						busOut[`Data] <= b[{busIn[6], busIn[4]}][`LineData];
					end
				end
				
				
				Modified:
				begin
					
					if(busIn[`Message] == ReadMiss)
					begin
					
						b[{busIn[6], busIn[4]}][`State] <= Shared;
										
						busOut[`Message] <= MemoryData;
						busOut[`SharedBlock] <= 1'b1;
						busOut[`WriteBack] <= 1'b1;
						busOut[`Address] <= busIn[`Address];
						busOut[`Data] <= b[{busIn[6], busIn[4]}][`LineData];
						
					end
					else if(busIn[`Message] == WriteMiss)
					begin

						b[{busIn[6], busIn[4]}][`State] <= Invalid;
						busOut[`Message] <= Nothing;
						
					end
				end
				
				Exclusive:
				begin
					if(busIn[`Message] == ReadMiss)
					begin
		
						b[{busIn[6], busIn[4]}][`State] <= Shared;
						
						busOut[`Message] <= MemoryData;
						busOut[`SharedBlock] <= 1'b1;
						busOut[`WriteBack] <= 1'b0;
						busOut[`Address] <= busIn[`Address];
						busOut[`Data] <= b[{busIn[6], busIn[4]}][`LineData];
					end
					else if(busIn[`Message] == Invalidate || busIn[`Message] == WriteMiss)
					begin
				
						b[{busIn[6], busIn[4]}][`State] <= Invalid;
						busOut[`Message] <= Nothing;
					end	
				end	
			endcase	
		end
	end
	
endmodule

module Snooping (clock, cpu);

/*input bit_escolha;
input op;
input estado_op;
input [1:0] estado;

wire [1:0]emissor_bus;
wire [1:0]estado_prox_emissor;
wire estado_wb_emissor;

input [1:0] receptor_bus;
wire aborta_acesso_mem;
wire [1:0]estado_prox_receptor;
wire estado_wb_receptor;
*/

input clock;
wire [14:0] bus0, bus1, bus2, bus;
input [10:0] cpu;
wire [8:0] arbiter_mem;
wire [7:0] mem_arbiter;


maq_emissora me1(bit_escolha, op, estado_op, estado_prox_emissor, estado_wb_emissor, emissor_bus);
maq_receptora mr1 (bit_escolha, receptor_bus, estado, estado_prox_receptor, estado_wb_receptor, aborta_acesso_mem);

cache #(2'b00) p0(clock, cpu, bus, bus0);
cache #(2'b01) p1(clock, cpu, bus, bus1);
cache #(2'b10) p2(clock, cpu, bus, bus2);
	
arbiter arbs(bus0, bus1, bus2, mem_arbiter, bus, arbiter_mem);
	
memoria m(clock, arbiter_mem[`MemAddress], arbiter_mem[`MemData], arbiter_mem[`MemWren], mem_arbiter);


endmodule 