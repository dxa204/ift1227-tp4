library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity controller is
    port (op, funct: in STD_LOGIC_VECTOR (5 downto 0);
          zero: in STD_LOGIC;
          memtoreg, memwrite: out STD_LOGIC;
          pcsrc, alusrc: out STD_LOGIC;
          regdst, regwrite: out STD_LOGIC;
          jump, jal: out STD_LOGIC;  -- Added 'jal' as an output signal
          alucontrol: out STD_LOGIC_VECTOR (2 downto 0));
end;

architecture struct of controller is
    component maindec
        port (op: in STD_LOGIC_VECTOR (5 downto 0);
              memtoreg, memwrite: out STD_LOGIC;
              branch, alusrc: out STD_LOGIC;
              regdst, regwrite: out STD_LOGIC;
              jump, jal: out STD_LOGIC;  -- Added 'jal' to maindec outputs
              aluop: out STD_LOGIC_VECTOR (1 downto 0));
    end component;
    component aludec
        port (funct: in STD_LOGIC_VECTOR (5 downto 0);
              aluop: in STD_LOGIC_VECTOR (1 downto 0);
              alucontrol: out STD_LOGIC_VECTOR (2 downto 0));
    end component;
    signal aluop: STD_LOGIC_VECTOR (1 downto 0);
    signal branch: STD_LOGIC;
begin
    md: maindec port map (op, memtoreg, memwrite, branch, alusrc, regdst, regwrite, jump, jal, aluop);  -- Added 'jal' signal
    ad: aludec port map (funct, aluop, alucontrol);
    pcsrc <= branch and zero;
end;
