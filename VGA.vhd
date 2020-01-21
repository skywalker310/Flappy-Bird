-------------------------------------------------------------------------------
--
-- Project					: FlappyBird
-- File name				: VGA.vhd
-- Title						: Flappy Bird game 
-- Description				:  
--		
-- Notes						: This model is designed for synthesis
--								: Compile with VHDL'93
--
-------------------------------------------------------------------------------
--
-- Revisions
--			Date		Author			Revision		Comments
--		3/11/2008		W.H.Robinson	Rev A			Creation
--		3/13/2012		W.H.Robinson	Rev B			Update for DE2-115 Board
--
--			
-------------------------------------------------------------------------------

-- Always specify the IEEE library in your design


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.ALL;

-- Entity declaration
-- 		Defines the interface to the entity

ENTITY VGA IS


	PORT
	(
-- 	Note: It is easier to identify individual ports and change their order
--	or types when their declarations are on separate lines.
--	This also helps the readability of your code.

    -- Clocks
    
    CLOCK_50	: IN STD_LOGIC;  -- 50 MHz
 
    -- Buttons 
    
    KEY 		: IN STD_LOGIC_VECTOR (3 downto 0);         -- Push buttons

    -- Input switches
    
    SW 			: IN STD_LOGIC_VECTOR (17 downto 0);         -- DPDT switches

    -- VGA output
    
    VGA_BLANK_N : out std_logic;            -- BLANK
    VGA_CLK 	 : out std_logic;            -- Clock
    VGA_HS 		 : out std_logic;            -- H_SYNC
    VGA_SYNC_N  : out std_logic;            -- SYNC
    VGA_VS 		 : out std_logic;            -- V_SYNC
    VGA_R 		 : out unsigned(7 downto 0); -- Red[9:0]
    VGA_G 		 : out unsigned(7 downto 0); -- Green[9:0]
    VGA_B 		 : out unsigned(7 downto 0); -- Blue[9:0]
	 LEDG : out std_logic_vector(8 downto 0);       -- Green LEDs (active high)
    LEDR : out std_logic_vector(17 downto 0);      -- Red LEDs (active high)
		
	-- LED displays

    HEX0 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX1 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX2 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX3 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX4 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX5 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX6 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX7 : out std_logic_vector(6 downto 0)       -- 7-segment display (active low)
	 
	);
END VGA;


-- Architecture body 
-- 		Describes the functionality or internal implementation of the entity

ARCHITECTURE structural OF VGA IS

COMPONENT VGA_SYNC_module

	PORT(	clock_50Mhz		: IN	STD_LOGIC;
			red		: in std_logic_vector(3 downto 0);
			green		: in std_logic_vector(3 downto 0);
			blue		: in STD_LOGIC_VECTOR(3 downto 0);
			red_out		: out unsigned(3 downto 0);
			green_out	: out unsigned(3 downto 0);
			blue_out		: out unsigned(3 downto 0);
			horiz_sync_out, vert_sync_out, video_on, pixel_clock
				: OUT	STD_LOGIC;
			pixel_row, pixel_column: OUT STD_LOGIC_VECTOR(10 DOWNTO 0));

END COMPONENT;

COMPONENT bird

   PORT(pixel_row, pixel_column		: IN std_logic_vector(10 DOWNTO 0);
		  flap				: in std_logic;
		  rom_in				: out std_logic_vector(11 downto 0);
		  rom_out			: in std_logic_vector(11 downto 0);
		  bg_in				: out std_logic_vector(17 downto 0);
		  bg_out				: in std_logic_vector(11 downto 0);
		  enable				: in std_logic;
		  draw				: out std_logic;
        Vert_sync	: IN std_logic);
       
END COMPONENT;

component bird_image
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
	);
end component;

component background
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
	);
end component;

component pipes
	PORT(clk									: IN std_logic;
		  pixel_row, pixel_column		: IN std_logic_vector(10 downto 0);
		  seed								: IN std_logic_vector(7 downto 0);
		  static_pipes						: IN std_logic;
		  stop_pipes						: IN std_logic;
		  restart_game						: IN std_logic;
		  Draw								: OUT std_logic;
		  score_counter					: OUT std_logic_vector(11 downto 0)
		  );
end component;

component score_counter
	PORT(
		clk	  : in std_logic;
		col_pos : IN STD_LOGIC_VECTOR (10 downto 0);
		enable  : in std_logic;
		reset : IN STD_LOGIC;
		counter : inout std_logic_vector(11 downto 0)
		);
end component;

component bcd_seven
	port(bcd: in std_logic_vector(3 downto 0);
			seven: out std_logic_vector(7 downto 1));
end component;

SIGNAL red_int 	: STD_LOGIC_vector(3 downto 0);
SIGNAL green_int 	: STD_LOGIC_vector(3 downto 0);
SIGNAL blue_int 	: STD_LOGIC_vector(3 downto 0);
SIGNAL video_on_int : STD_LOGIC;
SIGNAL vert_sync_int : STD_LOGIC;
SIGNAL horiz_sync_int : STD_LOGIC; 
SIGNAL pixel_clock_int : STD_LOGIC;
SIGNAL pixel_row_int :STD_LOGIC_VECTOR(10 DOWNTO 0); 
SIGNAL pixel_column_int :STD_LOGIC_VECTOR(10 DOWNTO 0);

signal rom_in: std_logic_vector(11 downto 0); 
signal rom_out: std_logic_vector(11 downto 0);

signal bird_draw: std_logic;
signal bg_in: std_logic_vector(17 downto 0);
signal bg_out: std_logic_vector(11 downto 0);

signal pipe_draw: std_logic;

signal HEX0_n, HEX1_n, HEX2_n: std_logic_vector(6 downto 0);
signal digit_0, digit_1, digit_2: std_logic_vector(3 downto 0);

signal bird_enable: std_logic := '1';
signal pipe_enable: std_logic := '1';

type play_state is (not_playing, playing);
signal state: play_state;

BEGIN

	VGA_HS <= horiz_sync_int;
	VGA_VS <= vert_sync_int;
	
	VGA_R(3 downto 0) <= "0000";
	VGA_G(3 downto 0) <= "0000";
	VGA_B(3 downto 0) <= "0000";


	U1: VGA_SYNC_module PORT MAP
		(clock_50Mhz		=>	CLOCK_50,
		 red					=>	red_int,
		 green				=>	green_int,	
		 blue					=>	blue_int,
		 red_out				=>	VGA_R(7 downto 4),
		 green_out			=>	VGA_G(7 downto 4),
		 blue_out			=>	VGA_B(7 downto 4),
		 horiz_sync_out	=>	horiz_sync_int,
		 vert_sync_out		=>	vert_sync_int,
		 video_on			=>	VGA_BLANK_N,
		 pixel_clock		=>	VGA_CLK,
		 pixel_row			=>	pixel_row_int,
		 pixel_column		=>	pixel_column_int
		);

	U2: bird PORT MAP
		(pixel_row		=> pixel_row_int,
		 pixel_column	=> pixel_column_int,
		 Vert_sync		=> vert_sync_int,
		 flap				=> KEY(0),
		 rom_out			=> rom_out,
		 rom_in			=> rom_in,
		 bg_in			=> bg_in,
		 bg_out			=> bg_out,
		 enable			=> bird_enable,
		 draw				=> bird_draw
		);
		
	U3: bird_image port map
		(address			=> rom_in,
		 clock			=> CLOCK_50,
		 q					=> rom_out
		);
		 
	U4: background port map
		(address			=> bg_in,
		 clock			=> CLOCK_50,
		 q					=> bg_out
		);
		
	U5: pipes port map
		(clk				=> vert_sync_int,
		 pixel_row		=> pixel_row_int,
		 pixel_column	=> pixel_column_int,
		 seed				=> SW(7 downto 0),
		 draw				=> pipe_draw,
		 static_pipes	=> SW(15),
		 stop_pipes		=> not pipe_enable,
		 restart_game	=> SW(16),
		 score_counter(11 downto 8) => digit_2, 
		 score_counter(7 downto 4) => digit_1,
		 score_counter(3 downto 0) => digit_0
		);

	segment1: bcd_seven port map (bcd => digit_0, seven => HEX0_n);
	segment2: bcd_seven port map (bcd => digit_1, seven => HEX1_n);
	segment3: bcd_seven port map (bcd => digit_2, seven => HEX2_n);
	HEX0 <= not HEX0_n;
	HEX1 <= not HEX1_n;
	HEX2 <= not HEX2_n;
		
	bird_enable <= SW(17);
	pipe_enable <= SW(17);
		
draw: process (pixel_row_int, pixel_column_int)
begin
	if bird_draw = '1' and pipe_draw = '0' and rom_out /= "000000000000" then
		red_int <= rom_out(11 downto 8);
		green_int <= rom_out(7 downto 4);
		blue_int <= rom_out(3 downto 0);
	elsif pipe_draw = '1' and bird_draw = '0' then
		red_int <= "0000";
		green_int <= "1000";
		blue_int <= "0000";
	elsif pipe_draw = '1' and bird_draw = '1' then
		red_int <= "1000";
		green_int <= "0000";
		blue_int <= "0000";

	else
		red_int <= bg_out(11 downto 8);
		green_int <= bg_out(7 downto 4);
		blue_int <= bg_out(3 downto 0);
	end if;
	
	
end process;

END structural;

