library verilog;
use verilog.vl_types.all;
entity memoria is
    port(
        clock           : in     vl_logic;
        addr            : in     vl_logic_vector(3 downto 0);
        data            : in     vl_logic_vector(3 downto 0);
        wren            : in     vl_logic;
        q               : out    vl_logic_vector(7 downto 0)
    );
end memoria;
