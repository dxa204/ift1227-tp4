library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all;
use STD.TEXTIO.all;

-- Define the entity
entity imem is
    port ( 
        a  : in  STD_LOGIC_VECTOR(5 downto 0);
        rd : out STD_LOGIC_VECTOR(31 downto 0)
    );
end imem;

-- Architecture definition
architecture behave of imem is
begin
    process(a)
        type ramtype is array (63 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
        variable mem: ramtype;
    begin
        -- Initialize memory with the divInt4 and jal instructions
        mem(0)  := X"02001002"; -- divInt4 $a0, $v0  | OpCode: 000000 (R-type), rs: $v0(2), rd: $a0(4), shamt: 0, funct: 000010
        mem(1)  := X"0C000008"; -- jal 0x00000008    | OpCode: 000011 (J-type), address: 0000000000000000000000000008
        
        -- Additional instructions to demonstrate functionality
        mem(2)  := X"20020005"; -- addi $v0, $0, 5
        mem(3)  := X"2003000c"; -- addi $v1, $0, 12
        mem(4)  := X"2067fff7"; -- addi $a3, $v1, -9
        mem(5)  := X"00e22025"; -- or   $a0, $a3, $v0
        mem(6)  := X"00642824"; -- and  $a1, $v1, $a0
        mem(7)  := X"00a42820"; -- add  $a1, $a1, $a0
        mem(8)  := X"10a7000a"; -- beq  $a1, $a3, label
        mem(9)  := X"0064202a"; -- slt  $a0, $v1, $a0
        mem(10) := X"10800001"; -- beq  $a0, $0, label
        mem(11) := X"20050000"; -- addi $a1, $0, 0
        mem(12) := X"00e2202a"; -- slt  $a0, $a3, $v0
        mem(13) := X"00853820"; -- add  $a3, $a0, $a1
        mem(14) := X"00e23822"; -- sub  $a3, $a3, $v0
        mem(15) := X"ac670044"; -- sw   $a3, 68($v1)
        mem(16) := X"8c020050"; -- lw   $v0, 80($0)
        mem(17) := X"08000011"; -- j    label
        mem(18) := X"20020001"; -- addi $v0, $0, 1
        mem(19) := X"ac02003C"; -- sw   $v0, 60($0) 

        -- Fill the rest of memory with no-operation instructions
        for ii in 20 to 63 loop
            mem(ii) := X"00000000"; -- No-Op
        end loop;

        -- Output the memory content based on the address
        rd <= mem(CONV_INTEGER(a));
    end process;
end behave;
