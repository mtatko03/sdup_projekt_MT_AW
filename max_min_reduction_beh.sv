`timescale 1ns / 1ps

module max_min_reduction_beh #(
    parameter int DATA_WIDTH = 16,
    parameter int N = 1024
)(
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         start,
    input  logic signed [DATA_WIDTH-1:0] data_in,
    input  logic                         data_valid,

    output logic signed [DATA_WIDTH-1:0] min_out,
    output logic signed [DATA_WIDTH-1:0] max_out,
    output logic                         done
);

    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        DONE_STATE
    } state_t;

    state_t state;

    localparam int COUNT_WIDTH = $clog2(N + 1);

    logic [COUNT_WIDTH-1:0] sample_count;
    logic signed [DATA_WIDTH-1:0] memory [0:N-1];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            sample_count <= '0;
            min_out      <= '0;
            max_out      <= '0;
            done         <= 1'b0;
        end
        else begin
            case (state)

                IDLE: begin
                    done         <= 1'b0;
                    sample_count <= '0;
                    min_out      <= '0;
                    max_out      <= '0;

                    if (start) begin
                        state <= LOAD;
                    end
                end

                LOAD: begin
                    done <= 1'b0;

                    if (data_valid) begin
                        memory[sample_count] <= data_in;

                        if (sample_count == 0) begin
                            min_out <= data_in;
                            max_out <= data_in;
                        end
                        else begin
                            if (data_in < min_out)
                                min_out <= data_in;

                            if (data_in > max_out)
                                max_out <= data_in;
                        end

                        if (sample_count == N - 1) begin
                            done  <= 1'b1;
                            state <= DONE_STATE;
                        end
                        else begin
                            sample_count <= sample_count + 1;
                        end
                    end
                end

                DONE_STATE: begin
                    done <= 1'b1;

                    if (!start) begin
                        done         <= 1'b0;
                        sample_count <= '0;
                        state        <= IDLE;
                    end
                end

                default: begin
                    state        <= IDLE;
                    sample_count <= '0;
                    done         <= 1'b0;
                end

            endcase
        end
    end

endmodule
