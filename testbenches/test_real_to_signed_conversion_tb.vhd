LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity test_real_to_signed_conversion_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of test_real_to_signed_conversion_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 50;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    function to_signed
    (
        real_number : real
    )
    return signed 
    is
        variable returned_signed : signed(63 downto 0) := (others => '0');
        variable high_bits : integer := 0;
        variable low_bits : integer := 0;
        constant abs_real_number : real := abs(real_number);
    begin

        high_bits := integer(abs_real_number / 2.0**32);
        low_bits := integer(abs_real_number - real(high_bits)*2.0**32);
        returned_signed := to_signed(high_bits, 32) & to_signed(low_bits, 32);
        if real_number < 0.0 then
            returned_signed := - returned_signed;
        end if;
        
        return returned_signed;
    end to_signed;

    signal testi : signed(63 downto 0) := to_signed(282718638473376.0 + 1.0);
------------------------------------------------------------------------
    function more_than_1
    (
        number : real
    )
    return std_logic 
    is
        variable return_value : std_logic;
    begin
        if number > 0.5 then
           return_value := '1';
       else
          return_value := '0';
      end if;
     return return_value; 
        
    end more_than_1;
------------------------------------------------------------------------
    function to_signed_2
    (
        real_number : real
    )
    return signed 
    is
        variable testii : real := real_number;
        variable returned_value : signed(63 downto 0) := (others => '1');

    begin
        for i in 0 to 63 loop
            testii := testii/2.0;
            returned_value(i) := more_than_1((testii)-floor(testii));
        end loop;

        return returned_value;
    end to_signed_2;
------------------------------------------------------------------------
    signal testi2 : signed(63 downto 0) := to_signed_2(282718638473376.0);
    signal correct_value : real := 282718638473376.0;

    function to_signed_3
    (
        real_number : real
    )
    return signed 
    is
        variable returned_signed : signed(63 downto 0) := (others => '0');
        variable high_bits : integer := 0;
        variable low_bits : integer := 0;
        constant abs_real_number : real := abs(real_number);
        variable testii : real := real_number;
        variable returned_value : signed(63 downto 0) := (others => '1');
    begin

        high_bits := integer(abs_real_number / 2.0**32);
        low_bits := integer(abs_real_number - real(high_bits)*2.0**32);

        for i in 0 to 63 loop
            testii := testii/2.0;
            returned_value(i) := more_than_1((testii)-floor(testii));
        end loop;

        returned_signed := returned_value(63 downto 31) & to_signed(low_bits, 31);
        if real_number < 0.0 then
            returned_signed := - returned_signed;
        end if;
        
        return returned_signed;
    end to_signed_3;

    signal testi3 : signed(63 downto 0) := to_signed_3(282718638473376.0);
    signal testi4 : signed(63 downto 0) := to_signed_3(8164017986371745.0);
begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)

        -- constant check_value : signed(39 downto 0) := (34 => '1', others => '0');
    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;
            -- check(testi = check_value, "fail");


        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
