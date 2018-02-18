LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY atan_cordic IS
	GENERIC(
    vsize: INTEGER := 32;
	 iter: INTEGER := 13
	);
	PORT(
		SIGNAL clk	:	IN std_logic;
		SIGNAL clk_en: IN std_logic;
		SIGNAL xin	:	IN std_logic_vector(5 DOWNTO 0);
		SIGNAL atanop	:  OUT std_logic_vector(vsize-1 DOWNTO 0)
		);
END ENTITY atan_cordic;

ARCHITECTURE rtl OF atan_cordic IS
ALIAS slv IS std_logic_vector;

TYPE vector IS
   RECORD
       x		: SIGNED(vsize-1 DOWNTO 0);
       y		: SIGNED(vsize-1 DOWNTO 0);
       z		: SIGNED(vsize-1 DOWNTO 0);
   END RECORD;
	--ROM contains arctan(2^-i) values
	TYPE ROM IS ARRAY (13 DOWNTO 0) OF SIGNED (vsize-1 DOWNTO 0);
	CONSTANT ATAN: ROM:=
	(0 => "00011101101011000110011100000101",
	 1 => "00001111101011011011101011111100",
	 2 => "00000111111101010110111010100110",
	 3 => "00000011111111101010101101110110",
	 4 => "00000001111111111101010101011011",
	 5 => "00000000111111111111101010101010",
	 6 => "00000000011111111111111101010101",
	 7 => "00000000001111111111111111101010",
	 8 => "00000000000111111111111111111101",
	 9 => "00000000000011111111111111111111",
	 10 =>"00000000000001111111111111111111",
	 11 =>"00000000000000111111111111111111",
	 12 =>"00000000000000011111111111111111", 
	 13 =>"00000000000000001111111111111111"
	);
	
	 TYPE VEC_ARRAY IS ARRAY (iter-1 DOWNTO 0) OF vector;
	
	CONSTANT half_pi: SIGNED(vsize-1 DOWNTO 0):= "01100100100001111110110101010001";--pi/2
	
	--Function implements a cordic step
FUNCTION cordic_step(co : vector; angle : SIGNED; num : INTEGER) RETURN vector IS
	VARIABLE nco: vector;
BEGIN
	IF ((co.x >=0) AND (co.y >=0)) OR ((co.x<=0) AND (co.y<=0)) THEN
		nco.z := co.z + angle;
		nco.x := co.x + SHIFT_RIGHT(co.y, num);
		nco.y := co.y - SHIFT_RIGHT(co.x, num);
	ELSE
		nco.z := co.z - angle;
		nco.x := co.x - SHIFT_RIGHT(co.y, num);
		nco.y := co.y + SHIFT_RIGHT(co.x, num);
	END IF;
	RETURN nco;
END;

	SIGNAL CO_ARR	: VEC_ARRAY;

BEGIN
	CO_ARR(0).y <= SIGNED'("00000000000000010000000000000000");--y = 0;
	CO_ARR(0).x(31 DOWNTO 22)<= TO_SIGNED(0,10);
	CO_ARR(0).x(21 DOWNTO 16) <= abs(SIGNED(xin));--x = absolute(input). Negative values were giving errors with testing. Arctan is an odd function so this is corrected later.
	CO_ARR(0).x(15 DOWNTO 0)<= TO_SIGNED(0,16);
	CO_ARR(0).z <= TO_SIGNED(0,vsize);--z = 0
	
	C0: PROCESS
	BEGIN
		WAIT UNTIL clk'EVENT AND clk='1' AND clk_en = '1';
		FOR i in 0 TO 3	LOOP--3 steps/clock cycle
			CO_ARR((3*i)+1) <= cordic_step (CO_ARR((3*i)), ATAN((3*i)), (3*i)+1);
			CO_ARR((3*i)+2) <= cordic_step (CO_ARR((3*i)+1), ATAN((3*i)+1), (3*i)+2);
			CO_ARR((3*i)+3) <= cordic_step (CO_ARR((3*i)+2), ATAN((3*i)+2), (3*i)+3);
		END LOOP;
		
		IF(SIGNED(xin) >= 0) THEN--Vectoring mode property with negative correction
			atanop <= slv(half_pi - CO_ARR(iter-1).z);
		ELSE
			atanop <= slv(-(half_pi - CO_ARR(iter-1).z));
		END IF;
		
		IF(SIGNED(xin) = 0) THEN--If input = 0, z = arctan(0) = 0.
			atanop <= slv(TO_SIGNED(0,vsize));
		END IF;
	END PROCESS C0;
	
END ARCHITECTURE rtl;