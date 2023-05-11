module blinkspeed (
    input               CLK,
    input               RST,
    input       [0:0]   BTN,
    output  reg [2:0]   LED
);

/* チャタリング除去回路を接続 */
wire btnon;

debounce d0 (.CLK(CLK), .RST(RST), .BTNIN(BTN), .BTNOUT(btnon));

/* 速度設定用カウンタ */
reg [1:0] speed;

always @( posedge CLK ) begin
    if ( RST )
        speed <= 2'h0;
    else if ( btnon )
        speed <= speed + 2'h1;
end

/* システムクロックを分周 */
reg [26:0] cnt27;

always @( posedge CLK ) begin
    if ( RST )
        cnt27 <= 27'h0;
    else
        cnt27 <= cnt27 + 27'h1;
end

/* LED用カウンタのイネーブルを作成 */
reg ledcnten;

always @* begin
    case ( speed )
        2'h0:   ledcnten = (cnt27      ==27'h7ffffff);
        2'h1:   ledcnten = (cnt27[25:0]==26'h3ffffff);
        2'h2:   ledcnten = (cnt27[24:0]==25'h1ffffff);
        2'h3:   ledcnten = (cnt27[23:0]==24'hffffff);
        default ledcnten = 1'b0;
    endcase
end

/* LED用5進カウンタ */
reg [2:0] cnt3;

always @( posedge CLK ) begin
    if ( RST )
        cnt3 <= 3'h0;
    else if ( ledcnten )
        if ( cnt3==3'd4)
            cnt3 <=3'h0;
        else
            cnt3 <= cnt3 + 3'h1;
end

/* LEDデコーダ */
always @* begin
    case ( cnt3 )
        3'd0:   LED = 3'b100;
        3'd1:   LED = 3'b010;
        3'd2:   LED = 3'b001;
        3'd3:   LED = 3'b111;
        3'd4:   LED = 3'b000;
        default:LED = 3'b000;
    endcase
end

endmodule