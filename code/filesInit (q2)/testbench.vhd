library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;  -- Use NUMERIC_STD for proper type conversions.

entity testbench is
    -- Entity declaration empty for testbench
end testbench;

architecture test of testbench is
    component mips
        port(
            clk, reset: in STD_LOGIC;
            writedata, dataadr: out STD_LOGIC_VECTOR(31 downto 0);
            memwrite: out STD_LOGIC
        );
    end component;

    -- Signals
    signal writedata, dataadr: STD_LOGIC_VECTOR(31 downto 0);
    signal clk, reset, memwrite: STD_LOGIC;
    signal PC, ra: STD_LOGIC_VECTOR(31 downto 0);  -- Assuming these are needed for jal test

begin
    -- Instantiate the MIPS component
    dut: mips port map (
        clk => clk,
        reset => reset,
        writedata => writedata,
        dataadr => dataadr,
        memwrite => memwrite
    );

    -- Clock generation
    clock_process: process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        if now > 1000 ns then  -- Terminate simulation after a specific time
            wait;
        end if;
    end process;

    -- Reset generation
    reset_process: process
    begin
        reset <= '1';
        wait for 20 ns;  -- Hold reset for 20 ns
        reset <= '0';
        wait for 10 ns;  -- Wait some time after reset
    end process;

    -- Testbench Logic to simulate divInt4 and jal operations
    test_process: process
    begin
        -- Assume here that writedata is used to simulate instructions and dataadr as addresses
        -- Example encodings are hypothetical
        wait until reset = '0';  -- Wait for reset to be de-asserted
        wait until rising_edge(clk);

        -- Simulating divInt4 instruction
        dataadr <= std_logic_vector(to_unsigned(0, 32));  -- Instruction address for divInt4
        writedata <= std_logic_vector(to_unsigned(268435458, 32)); -- Encoded divInt4 instruction
        memwrite <= '1';  -- Write instruction to the processor
        wait until rising_edge(clk);
        memwrite <= '0';  -- End write cycle
        wait for 100 ns; -- Wait for the instruction to execute

        -- Here check for the results through some output or state change

        -- Simulating jal instruction
        dataadr <= std_logic_vector(to_unsigned(4, 32));  -- Next instruction address
        writedata <= std_logic_vector(to_unsigned(201326595, 32)); -- Encoded jal instruction
        memwrite <= '1';
        wait until rising_edge(clk);
        memwrite <= '0';
        wait for 100 ns; -- Allow time for jal to execute

        -- Check results based on expected changes in PC and/or other outputs

        wait;
    end process;

end test;
