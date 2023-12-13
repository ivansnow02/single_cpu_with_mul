`timescale 1ns / 1ps
//*************************************************************************
//   > 文件�?: inst_rom.v
//   > 描述  ：异步指令存储器模块，采用寄存器搭建而成，类似寄存器�?
//   >         内嵌好指令，只读，异步读
//   > 作�??  : LOONGSON
//   > 日期  : 2016-04-14
//*************************************************************************
module inst_rom(
    input      [4 :0] addr, // 指令地址
    output reg [31:0] inst       // 指令
    );

    wire [31:0] inst_rom[8:0];  // 指令存储器，字节地址7'b000_0000~7'b111_1111
    //------------- 指令编码 ---------|指令地址|--- 汇编指令 -----|- 指令结果 -----//
    assign inst_rom[ 0] = 32'h240B0006; // 00H: addiu $t3, $zero, 6         | $t3 = $zero + 6
    assign inst_rom[ 1] = 32'h24080001; // 04H: addiu $t0, $zero, 1         | $t0 = $zero + 1
    assign inst_rom[ 2] = 32'h240A0001; // 08H: addiu $t2, $zero, 1         | $t2 = $zero + 1
    assign inst_rom[ 3] = 32'h114B0003; // 0CH: beq    $t2, $t3, ending     | if $t2 == $t3 then ending
    assign inst_rom[ 4] = 32'h254A0001; // 10H: addiu $t2, $t2, 1           | $t2 = $t2 + 1
    assign inst_rom[ 5] = 32'h01080018; // 14H: mul    $t0, $t0, $t2         | $t0 * $t2 = Hi and Lo registers
    assign inst_rom[ 6] = 32'h08000003; // 18H: j      loop                 | jump to loop
    assign inst_rom[ 7] = 32'h240D0001; // 1CH: addiu $t5, $zero, 1         | $t5 = $zero + 1
    assign inst_rom[ 8] = 32'h08000007; // 20H: j      ending               | jump to ending

    //读指�?,�?4字节
    always @(*)
    begin
        case (addr)
            5'd0 : inst <= inst_rom[0 ];
            5'd1 : inst <= inst_rom[1 ];
            5'd2 : inst <= inst_rom[2 ];
            5'd3 : inst <= inst_rom[3 ];
            5'd4 : inst <= inst_rom[4 ];
            5'd5 : inst <= inst_rom[5 ];
            5'd6 : inst <= inst_rom[6 ];
            5'd7 : inst <= inst_rom[7 ];
            5'd8 : inst <= inst_rom[8 ];
            default: inst <= 32'd0;
        endcase
    end
endmodule