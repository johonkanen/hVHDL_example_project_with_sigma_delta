LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

    use work.multiplier_pkg.all;

entity test_first_order_filter_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of test_first_order_filter_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 200;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal y : integer := 0;
    signal memory : integer := 0;
    signal u : integer := 0;
    signal filter_out : real := 0.0;

    signal y2 : integer := 0;
    signal reference_filter : real := 0.0;


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

        function "*"
        (
            left, right : integer
        )
        return integer
        is
        begin
            return work.multiplier_pkg.radix_multiply(left, right, 32, 30);
        end "*";

        constant filter_gain : integer := 3;

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            u <= 2**25;

            y      <= u/2**(filter_gain + 1) + y-y/2**(filter_gain + 1);
            -- memory <= u/2**filter_gain + y-y/2**filter_gain;

            y2 <= y2 + (u-y2)/2**(filter_gain+1);

            filter_out <= real(y)/2.0**25;
            reference_filter <= reference_filter + (real(u)/2.0**25 - reference_filter)/16.0;


        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
