library verilog;
use verilog.vl_types.all;
entity Snooping is
    port(
        clock           : in     vl_logic;
        cpu             : in     vl_logic_vector(10 downto 0)
    );
end Snooping;
