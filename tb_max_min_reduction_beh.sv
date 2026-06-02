`timescale 1ns / 1ps

module tb_max_min_reduction_beh;

    parameter int DATA_WIDTH = 16;
    parameter int N = 1024;

    logic clk;
    logic rst_n;
    logic start;
    logic signed [DATA_WIDTH-1:0] data_in;
    logic data_valid;

    logic signed [DATA_WIDTH-1:0] min_out;
    logic signed [DATA_WIDTH-1:0] max_out;
    logic done;

    logic signed [DATA_WIDTH-1:0] test_memory [0:N-1];
    logic signed [DATA_WIDTH-1:0] reference_min;
    logic signed [DATA_WIDTH-1:0] reference_max;

    int i;

    max_min_reduction_beh #(
        .DATA_WIDTH(DATA_WIDTH),
        .N(N)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .data_in(data_in),
        .data_valid(data_valid),
        .min_out(min_out),
        .max_out(max_out),
        .done(done)
    );

    // Zegar 100 MHz, okres 10 ns
    always #5 clk = ~clk;

    initial begin
        clk        = 1'b0;
        rst_n      = 1'b0;
        start      = 1'b0;
        data_in    = '0;
        data_valid = 1'b0;

        // Reset
        #30;
        rst_n = 1'b1;

        // Generowanie danych testowych 16-bit signed
        for (i = 0; i < N; i++) begin
            test_memory[i] = $signed($urandom_range(0, 65535));
        end

        // Obliczenie wartoœci referencyjnych
        reference_min = test_memory[0];
        reference_max = test_memory[0];

        for (i = 1; i < N; i++) begin
            if (test_memory[i] < reference_min)
                reference_min = test_memory[i];

            if (test_memory[i] > reference_max)
                reference_max = test_memory[i];
        end

        // Start modu³u
        @(negedge clk);
        start = 1'b1;

        // Dajemy modu³owi jeden cykl na przejœcie z IDLE do LOAD
        @(posedge clk);

        // Podawanie 1024 próbek
        for (i = 0; i < N; i++) begin
            @(negedge clk);
            data_in    = test_memory[i];
            data_valid = 1'b1;
        end

        // Ostatnia próbka zostaje z³apana na najbli¿szym posedge
        @(posedge clk);

        // Wy³¹czamy data_valid dopiero po przyjêciu ostatniej próbki
        @(negedge clk);
        data_valid = 1'b0;

        // Czekamy na done, ale z zabezpieczeniem czasowym
        fork
            begin
                wait(done == 1'b1);

                $display("================================");
                $display("RESULT FROM MODULE:");
                $display("MIN = %0d", min_out);
                $display("MAX = %0d", max_out);

                $display("REFERENCE RESULT:");
                $display("MIN = %0d", reference_min);
                $display("MAX = %0d", reference_max);

                if ((min_out == reference_min) && (max_out == reference_max))
                    $display("Verification: PASSED");
                else
                    $display("Verification: FAILED");

                $display("DONE = %0d", done);
                $display("================================");

                #20;
                start = 1'b0;

                #50;
                $finish;
            end

            begin
                #50000;
                $display("================================");
                $display("ERROR: Timeout. DONE was not asserted.");
                $display("MIN OUT = %0d", min_out);
                $display("MAX OUT = %0d", max_out);
                $display("REF MIN = %0d", reference_min);
                $display("REF MAX = %0d", reference_max);
                $display("DONE = %0d", done);
                $display("================================");
                $finish;
            end
        join_any

    end

endmodule
