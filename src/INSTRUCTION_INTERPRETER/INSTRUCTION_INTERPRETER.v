/*
TODO


*/

module instruction_interpreter (
    input [31:0] instruction,

    output reg [4:0]    reg1,
    output reg [4:0]    reg2,
    output reg [4:0]    reg3,
    output reg [4:0]    s_r_amount,
    output reg [31:0]   im_data,
    output reg          register_write_word_enable,
    output reg          register_write_byte_enable,
    output reg [4:0]    alu_opcode,
    output reg [1:0]    jump_mux_signal,        // 0 -> pc+4 , 1 -> pc + Address , 2 -> pc = reg1 , 3 -> pc = pc [31:18] | Address | 00 
    output reg          write_back_on_register_mux_signal,
    output reg          alu_input_mux_signal,
    output              PC_enable,
    output reg          memwrite_enable_a,  // WORD    
    output reg          memwrite_enable_b,  // BYTE  
    output reg          memread_enable_a,  // WORD    
    output reg          memread_enable_b,  // BYTE  
);

    assign PC_enable = (instruction[31:26] == 0) ? 0 : 1;
    assign register_write_byte_enable = (instruction[31:26] == 5'b011010) ? 1 : 0;
    assign register_write_word_enable = (instruction[31:26] == 5'b011000 || 
                                        (instruction[31:26]>=1 && instruction[31:26] <=23) ) ? 1 : 0;

    assign memwrite_enable_a = (instruction[31:26] == 5'b011001) ? 1 : 0; 
    assign memwrite_enable_b = (instruction[31:26] == 5'b011011) ? 1 : 0; 
    assign memread_enable_a =  (instruction[31:26] == 5'b011000) ? 1 : 0; 
    assign memread_enable_b =  (instruction[31:26] == 5'b011010) ? 1 : 0; 

    always @(instruction) begin

        if (instruction[31:26] == 0) begin
            //TODO: Stop the whole thing! maybe there's nothing else to do since PC_Enable is assigned but still ...!
        end
        else if (instruction[31:26]>=1 && instruction[31:26] <=15)
        begin
            reg3 = instruction[25:21];
            reg1 = instruction[20:16];
            reg2 = instruction[15:11];
            s_r_amount = instruction[10:6];
            alu_opcode = instruction[29:26];
            jump_mux_signal = 0;
            write_back_on_register_mux_signal = 1;
            alu_input_mux_signal = 0;
            memory_write_enable_signal = 0;
        end
        else if (instruction[31:26] >=16 && instruction[31:26] <=23) begin
            reg3 = instruction[25:21];
            reg1 = instruction[20:16];
            reg2 = 5'bz;
            im_data = {{16 {instruction[15]}}, instruction[15:0]};
            s_r_amount = 5'bz;
            
            jump_mux_signal = 0;
            write_back_on_register_mux_signal = 1;
            alu_input_mux_signal = 1;
            memory_write_enable_signal = 0;

            case(instruction[29:26])
                4'b0010: begin
                    alu_opcode = 5'b00001;
                end

                4'b0011: begin
                    alu_opcode = 5'b00010;
                end

                4'b0100: begin
                    alu_opcode = 5'b00011;
                end

                4'b0101: begin
                    alu_opcode = 5'b00100;
                end

                4'b0110: begin
                    alu_opcode = 5'b01001;
                end

                4'b0111: begin
                    alu_opcode = 5'b01010;
                end
                default: begin
                    alu_opcode = 5'b00000;
            endcase

        end
        else if (instruction[31:26] >= 24 && instruction[31:26] <= 27) begin
            //wrong
            reg1 = instruction[25:21];
            reg3 = instruction[25:21];
            if (instruction[31:26] == 5'b011011)
                reg2 = instruction[20:16];
            else 
                reg2 = instru //to do

            if (instruction[31:26] == 24 || instruction[31:26] == 25)
                memory_byte_word_select = 1;
            else
                memory_byte_word_select = 0;

            im_data = {{16 {instruction[15]}}, instruction[15:0]};
            s_r_amount = 5'bz;
            jump_mux_signal = 0;
            write_back_on_register_mux_signal = 0;
            alu_input_mux_signal = 1;
            alu_opcode = 5'b00001;
            memory_write_enable_signal = instruction[26];
        end 
        else begin
            reg1 = instruction[25:21];
            reg2 = instruction[20:16];
            reg3 = 5'bz;
            im_data = {{16 {instruction[15]}}, instruction[15:0]};
            s_r_amount = 5'bz;
            if (instruction[31:26] == 5'b011101)
                jump_mux_signal = 2;
            else if (instruction[31:26] == 5'011100)
                jump_mux_signal = 3;
            else 
                jump_mux_signal = 1;
            write_back_on_register_mux_signal = 1;
            alu_input_mux_signal = 0;
            memory_write_enable_signal = 0;
            case(instruction[29:26])
                
                4'b1110: begin
                    alu_opcode = 5'b10000;
                end

                4'b1111: begin
                    alu_opcode = 5'b01111;
                end
            endcase
        end
    end
endmodule