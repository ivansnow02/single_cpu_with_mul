`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: multiply.v
//   > 描述  ：乘法器模块，低效率的迭代乘法算法，使用两个乘数绝对值参与运算
//   > 作者  : LOONGSON
//   > 日期  : 2016-04-14
//*************************************************************************
module multiply(              // 乘法器
    input         clk,        // 时钟
    input         mult_begin, // 乘法开始信号
    input  [31:0] mult_op1,   // 乘法源操作数1
    input  [31:0] mult_op2,   // 乘法源操作数2
    output [63:0] product,    // 乘积
    output reg    mult_end    // 乘法结束信号
);

    //乘法正在运算信号和结束信号
    reg [4:0] mult_count;
    reg mult_valid;
    initial begin
        mult_valid = 0;
    end
    always @(posedge clk)
    begin
        if (mult_begin && !mult_valid)
        begin
            mult_valid <= 1'b1;
            mult_count <= 5'd0;
        end
        else if (mult_count == 5'd31)
        begin
            mult_valid <= 1'b0;
            mult_count <= 5'd0;
        end
        else if (mult_valid)
        begin
            mult_count <= 5'd1 + mult_count;
        end
        if (mult_count == 5'd31)
        begin
            mult_end <= 1'b1;
        end
        else
        begin
            mult_end <= 1'b0;
        end
    end

    //两个源操作取绝对值，正数的绝对值为其本身，负数的绝对值为取反加1
    wire        op1_sign;      //操作数1的符号位
    wire        op2_sign;      //操作数2的符号位
    wire [31:0] op1_absolute;  //操作数1的绝对值
    wire [31:0] op2_absolute;  //操作数2的绝对值
    assign op1_sign = mult_op1[31];
    assign op2_sign = mult_op2[31];
    assign op1_absolute = op1_sign ? (~mult_op1+1) : mult_op1;
    assign op2_absolute = op2_sign ? (~mult_op2+1) : mult_op2;

    //加载被乘数
    reg  [31:0] multiplicand;
    always @ (posedge clk)
    begin
        if (mult_begin && !mult_valid) 
        begin   // 乘法开始，加载被乘数，为乘数1的绝对值
            multiplicand <= op1_absolute;
        end
    end

    reg [63:0] product_temp;
    reg mult_ctrl;
    always @ (posedge clk)  // 乘积
    begin
        if (mult_begin && !mult_valid)
        begin
              product_temp[31:0] <= op2_absolute;
              product_temp[63:32] <= 32'd0;
        end
        else if (mult_valid)
        begin
            mult_ctrl = product_temp[0];
            product_temp[63:32] = product_temp[63:32] + (mult_ctrl ? multiplicand : 32'd0);
            product_temp = product_temp>>1;
        end
    end 
    
    //乘法结果的符号位和乘法结果
    reg product_sign;
    always @ (posedge clk)  // 乘积
    begin
        if (mult_begin && !mult_valid)
        begin
              product_sign <= op1_sign ^ op2_sign;
        end
    end 
    //若乘法结果为负数，则需要对结果取反+1
    assign product = product_sign ? (~product_temp+1) : product_temp;
endmodule
