module pattern_hdmi(
    input           CLK,
    input           RST,
    output          HDMI_CLK_N, HDMI_CLK_P,
    output  [2:0]   HDMI_N, HDMI_P
);

wire [7:0] VGA_R,  VGA_G,  VGA_B;
wire       VGA_HS, VGA_VS, VGA_DE;
wire       PCK;

/* パターン表示回路を接続 */
pattern pattern(
    .CLK    (CLK),
    .RST    (RST),
    .VGA_R  (VGA_R),
    .VGA_G  (VGA_G),
    .VGA_B  (VGA_B),
    .VGA_HS (VGA_HS),
    .VGA_VS (VGA_VS),
    .VGA_DE (VGA_DE),
    .PCK    (PCK)
);

/* HDMI信号生成IPを接続 */
rgb2dvi #(
    .kClkPrimitive("MMCM"),
    .kClkRange  (5)  // 25MHz <= fPCK < 30MHz
    )
  rgb2dvi (
    .PixelClk   (PCK),
    .TMDS_Clk_n (HDMI_CLK_N),
    .TMDS_Clk_p (HDMI_CLK_P),
    .TMDS_Data_n(HDMI_N),
    .TMDS_Data_p(HDMI_P),
    .aRst       (RST),
    .vid_pData  ({VGA_R, VGA_B, VGA_G}),
    .vid_pHSync (VGA_HS),
    .vid_pVDE   (VGA_DE),
    .vid_pVSync (VGA_VS)
);

endmodule