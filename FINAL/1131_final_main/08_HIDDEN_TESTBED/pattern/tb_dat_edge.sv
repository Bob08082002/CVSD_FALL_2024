package dat_0;
integer pat_num = 0;
// M: all0, X: all0, Y: all0
reg [767:0] input_data  = 768'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_1;
integer pat_num = 1;
// M: all0, X: all0, Y: all1
reg [767:0] input_data  = 768'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_2;
integer pat_num = 2;
// M: all0, X: all0, Y: rand
reg [767:0] input_data  = 768'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001cb76317ed6b7e5053aeec6a34289c51439af5241c10162118e7bf8ce3fa5276;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_3;
integer pat_num = 3;
// M: all0, X: all1, Y: all0
reg [767:0] input_data  = 768'h0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_4;
integer pat_num = 4;
// M: all0, X: all1, Y: all1
reg [767:0] input_data  = 768'h0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_5;
integer pat_num = 5;
// M: all0, X: all1, Y: rand
reg [767:0] input_data  = 768'h0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6f946993d4cfcbaf423470ff3b32bd2d36e9b1d2c465541c7b51e1e80adbbd71;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_6;
integer pat_num = 6;
// M: all0, X: rand, Y: all0
reg [767:0] input_data  = 768'h0000000000000000000000000000000000000000000000000000000000000000ff4df5bc8a3c4b34be4ab2853e8c9e8420ac0c07dd28e8e98b5cbda2c94a084c0000000000000000000000000000000000000000000000000000000000000000;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_7;
integer pat_num = 7;
// M: all0, X: rand, Y: all1
reg [767:0] input_data  = 768'h00000000000000000000000000000000000000000000000000000000000000006138a6360627178bcc404bdc5d5e9851c155012d111a3e044388dcfa037f3bf0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_8;
integer pat_num = 8;
// M: all0, X: rand, Y: rand
reg [767:0] input_data  = 768'h00000000000000000000000000000000000000000000000000000000000000007f25cf27a452ecc097dd8afded29394f5f17b3ae650d19da0aab4cc9d9af64bc5414167f1bb38b6f63ade1e9b8d4f6fc7ac3f9ad9920f56ae4897c9303cde243;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_9;
integer pat_num = 9;
// M: all1, X: all0, Y: all0
reg [767:0] input_data  = 768'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_10;
integer pat_num = 10;
// M: all1, X: all0, Y: all1
reg [767:0] input_data  = 768'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_11;
integer pat_num = 11;
// M: all1, X: all0, Y: rand
reg [767:0] input_data  = 768'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000a1c7584939ae48375cc63ec2a84c036dbc5d286189e865754131c63a7859f08;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_12;
integer pat_num = 12;
// M: all1, X: all1, Y: all0
reg [767:0] input_data  = 768'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_13;
integer pat_num = 13;
// M: all1, X: all1, Y: all1
reg [767:0] input_data  = 768'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_14;
integer pat_num = 14;
// M: all1, X: all1, Y: rand
reg [767:0] input_data  = 768'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0e8f12a2ec577976edafdb5a9c804813ae003dd13f1dd16447f3e46d2b2602b1;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_15;
integer pat_num = 15;
// M: all1, X: rand, Y: all0
reg [767:0] input_data  = 768'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5f519e628ea004d5b09b44d627e5f9f9f5ba4c97e069432c3f87159298b81fdf0000000000000000000000000000000000000000000000000000000000000000;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_16;
integer pat_num = 16;
// M: all1, X: rand, Y: all1
reg [767:0] input_data  = 768'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed3ab062ed3cedef803580cb5212326d233829b4add68cfbe9a0015bca4ac98dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_17;
integer pat_num = 17;
// M: all1, X: rand, Y: rand
reg [767:0] input_data  = 768'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff508b351f2fffdbddebf670dea4f1e3e50aa5dd78d5540a51887d464fd7c7d97a8cf248f471143af21780fa063a4f581e2d80dcd9a52c02ddd82987abc46b6942;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_18;
integer pat_num = 18;
// M: rand, X: all0, Y: all0
reg [767:0] input_data  = 768'h2b0fb9f72198acd2a7173994cbc66b0770529b45f78f251857219d0ad28a7b2100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_19;
integer pat_num = 19;
// M: rand, X: all0, Y: all1
reg [767:0] input_data  = 768'h65cd5a2e05ba0bae9e45061290e76c08a023dffabf22c95257db2d014464c4220000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_20;
integer pat_num = 20;
// M: rand, X: all0, Y: rand
reg [767:0] input_data  = 768'hfc58264d76e87708527432ab126833aaaf3bd32bb7f0762e23d41b7e2cab6e050000000000000000000000000000000000000000000000000000000000000000472ec6c9422ea76564e6089b9cd1df92571b7a586f6cf300c183e59452f67f5e;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_21;
integer pat_num = 21;
// M: rand, X: all1, Y: all0
reg [767:0] input_data  = 768'h3bf66cba49e8dfc07985d60e1c3de91179b8ad8e64919cb2c78db974638b819fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_22;
integer pat_num = 22;
// M: rand, X: all1, Y: all1
reg [767:0] input_data  = 768'h2938a6e222a255afb259c93fbe0643103c2d76acd1e8a87c78e22357594deb4bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_23;
integer pat_num = 23;
// M: rand, X: all1, Y: rand
reg [767:0] input_data  = 768'hf5117063df99c04a20de9efaa2836273642238d2f5d06ea3430a529a43fde58effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0995c71cc56e9123b0d11f8ffb46c91adf8331ea1e9796802c184eb8e6a8a92b;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_24;
integer pat_num = 24;
// M: rand, X: rand, Y: all0
reg [767:0] input_data  = 768'hbcea55b3c34b3f5a64ed40b0fbf541ee822a6fd852bd86c85b3fab840517fab1b3d5110eba4dbb127cd57120854bdf8624d1c3110d3f6dbbe30a5c760d2b74220000000000000000000000000000000000000000000000000000000000000000;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_25;
integer pat_num = 25;
// M: rand, X: rand, Y: all1
reg [767:0] input_data  = 768'h7da29e9628f0dec3fe3a7908ac05ad2e702b5b578cad51394c7ca824d05ac6002015cf46c634940a0f5c3bc0b2e013104c529624d1f5ed8ac972abca9f7a302dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage

package dat_26;
integer pat_num = 26;
// M: rand, X: rand, Y: rand
reg [767:0] input_data  = 768'h48a6c1fe69b81e5fba16d584ae50f654a3a5612c33f392ab708752488b8beb3cb19cacfd123d88c0f716df7335630d94834745e4005c49ef377183a4567056abf7e9a0f83227a52c50fbc7860a2b26b36b24d99107b78cce2ae528740b44b0ad;
reg [511:0] golden_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endpackage