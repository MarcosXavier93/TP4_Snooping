library verilog;
use verilog.vl_types.all;
entity cache is
    generic(
        Invalid         : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        \Shared\        : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        Modified        : vl_logic_vector(0 to 1) := (Hi1, Hi0);
        Exclusive       : vl_logic_vector(0 to 1) := (Hi1, Hi1);
        Nothing         : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        ReadMiss        : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        ReadHit         : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        WriteMiss       : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        WriteHit        : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        Invalidate      : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi1);
        MemoryData      : vl_logic_vector(0 to 2) := (Hi1, Hi1, Hi0);
        PID             : vl_logic_vector(0 to 1) := (Hi0, Hi0)
    );
    port(
        clock           : in     vl_logic;
        cpuIn           : in     vl_logic_vector(10 downto 0);
        busIn           : in     vl_logic_vector(14 downto 0);
        busOut          : out    vl_logic_vector(14 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Invalid : constant is 1;
    attribute mti_svvh_generic_type of \Shared\ : constant is 1;
    attribute mti_svvh_generic_type of Modified : constant is 1;
    attribute mti_svvh_generic_type of Exclusive : constant is 1;
    attribute mti_svvh_generic_type of Nothing : constant is 1;
    attribute mti_svvh_generic_type of ReadMiss : constant is 1;
    attribute mti_svvh_generic_type of ReadHit : constant is 1;
    attribute mti_svvh_generic_type of WriteMiss : constant is 1;
    attribute mti_svvh_generic_type of WriteHit : constant is 1;
    attribute mti_svvh_generic_type of Invalidate : constant is 1;
    attribute mti_svvh_generic_type of MemoryData : constant is 1;
    attribute mti_svvh_generic_type of PID : constant is 1;
end cache;
