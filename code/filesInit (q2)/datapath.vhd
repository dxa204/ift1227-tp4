library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity datapath is
    port(   clk, reset: in STD_LOGIC;
            memtoreg, pcsrc, jal: in STD_LOGIC;  -- Added 'jal' as an input for handling the jal instruction
            alusrc, regdst: in STD_LOGIC;
            regwrite, jump: in STD_LOGIC;
            alucontrol: in STD_LOGIC_VECTOR (2 downto 0);
            zero: out STD_LOGIC;
            pc: buffer STD_LOGIC_VECTOR (31 downto 0);
            instr: in STD_LOGIC_VECTOR(31 downto 0);
            aluout, writedata: buffer STD_LOGIC_VECTOR (31 downto 0);
            readdata: in STD_LOGIC_VECTOR (31 downto 0));
end;

architecture struct of datapath is
    component alu
        port(   a, b: in STD_LOGIC_VECTOR(31 downto 0);
                f   : in STD_LOGIC_VECTOR (2 downto 0);
                z   : out STD_LOGIC;
                y   : buffer STD_LOGIC_VECTOR(31 downto 0));
    end component;
    component regfile
        port(   clk: in STD_LOGIC;
                we3: in STD_LOGIC;
                ra1, ra2, wa3: in STD_LOGIC_VECTOR (4 downto 0);
                wd3: in STD_LOGIC_VECTOR (31 downto 0);
                rd1, rd2: out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    component adder
        port(   a, b: in STD_LOGIC_VECTOR (31 downto 0);
                y: out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    component sl2
        port(   a: in STD_LOGIC_VECTOR (31 downto 0);
                y: out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    component signext
        port(   a: in STD_LOGIC_VECTOR (15 downto 0);
                y: out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    component flopr generic (width: integer)
        port(   clk, reset: in STD_LOGIC;
                d: in STD_LOGIC_VECTOR (width-1 downto 0);
                q: out STD_LOGIC_VECTOR (width-1 downto 0));
    end component;
    component mux2 generic (width: integer)
        port(   d0, d1: in STD_LOGIC_VECTOR (width-1 downto 0);
                s: in STD_LOGIC;
                y: out STD_LOGIC_VECTOR (width-1 downto 0));
    end component;
    signal writereg, srca, srcb, result: STD_LOGIC_VECTOR (31 downto 0);
    signal pcjump, pcnext, pcnextbr, pcplus4, pcbranch: STD_LOGIC_VECTOR (31 downto 0);
    signal signimm, signimmsh: STD_LOGIC_VECTOR (31 downto 0);
    
begin
    -- next PC logic
    pcjump <= pcplus4(31 downto 28) & instr(25 downto 0) & "00";
    pcreg: flopr generic map(32) port map(clk, reset, pcnext, pc);
    pcadd1: adder port map(pc, X"00000004", pcplus4);
    immsh: sl2 port map(signimm, signimmsh);
    pcadd2: adder port map(pcplus4, signimmsh, pcbranch);
    pcbrmux: mux2 generic map(32) port map(pcplus4, pcbranch, pcsrc, pcnextbr);
    pcmux: mux2 generic map(32) port map(pcnextbr, pcjump, jump or jal, pcnext);  -- Modified to include jal
    -- register file logic
    rf: regfile port map(
        clk => clk,
        we3 => regwrite or jal,  -- Write enable is asserted either on regular writes or jal
        ra1 => instr(25 downto 21),
        ra2 => instr(20 downto 16),
        wa3 => "11111" when jal = '1' else writereg,  -- Write to $ra (register 31) when jal
        wd3 => pcplus4 when jal = '1' else result,  -- Write PC + 4 to $ra when jal
        rd1 => srca,
        rd2 => writedata
    );
    -- ALU logic
    srcbmux: mux2 generic map (32) port map(writedata, signimm, alusrc, srcb);
    mainalu: alu port map(srca, srcb, alucontrol, zero, aluout);
end struct;
