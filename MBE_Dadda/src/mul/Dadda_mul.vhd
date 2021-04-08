library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dadda_mul is
	port(	A,B : in std_logic_vector(31 downto 0);
			P : out std_logic_vector(63 downto 0));
end entity;

architecture MIXED of dadda_mul is 

	component MUX_ENCODED is
		 port(	in_0,in_1,in_2,in_3, in_4, in_5: in std_logic_vector(32 downto 0);
				sel: in std_logic_vector(2 downto 0);
				output: out std_logic_vector(32 downto 0);
				sel_out: out std_logic);
	end component;
	
	component half_adder is
		 port(	a,b : in std_logic;
				s,c_out  : out std_logic);
	end component;
	
	component full_adder is
		 port(	a,b,c_in: in std_logic;
				s,c_out   : out std_logic);
	end component;
	
	type s_matrix is array(6 downto 0,16 downto 0) of std_logic_vector(63 downto 0);
	type op_type is array(16 downto 0) of std_logic_vector(32 downto 0);
	type matrix_array is array(0 to 5, 63 downto 0) of integer;
	type matrix_in is array(16 downto 0) of std_logic_vector(63 downto 0);
	type dim_array is array(0 to 6) of integer;
	
	signal ov: std_logic;
	signal m_in : matrix_in;
	signal A_x2 : std_logic_vector(32 downto 0);
	signal A_x2_n : std_logic_vector(32 downto 0);
	signal A_ext : std_logic_vector(32 downto 0);
	signal A_n : std_logic_vector(32 downto 0);
	signal A_ext_n : std_logic_vector(32 downto 0);
	signal B_ext : std_logic_vector(34 downto 0);
	signal stage : s_matrix;
	signal p_operand : op_type;
	signal MSB : std_logic_vector(16 downto 0);
	signal addend : std_logic_vector(63 downto 0);
	
	constant dim : dim_array := (16,12,8,5,3,2,1);
	
	constant half_array : matrix_array := ((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
											(0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
											(0,0,0,0,0,0,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0),
											(0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
											(0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0),
											(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0));

	constant full_array : matrix_array := ((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,2,3,3,4,4,4,4,3,3,2,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
											(0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,2,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,3,3,2,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
											(0,0,0,0,0,0,0,0,1,1,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0),
											(0,0,0,0,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,0,0,0,0,0,0,0,0),
											(0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0),
											(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0));

begin
	A_ext <= '0' & A;
	A_n <= not A_ext;
	A_x2 <= A & '0';
	A_x2_n <= not A_x2;
	B_ext <= "00" & B & '0';
	
	
	mux_encoder_gen: for i in 0 to 16 generate
		dec_i : MUX_ENCODED port map(in_0 => (others => '0'), in_1 => A_ext, in_2 => A_x2, in_3 => A_n,in_4 => A_x2_n, in_5 => (others => '1'), sel => B_ext(2*i+2 downto 2*i),
									output => p_operand(i), sel_out => MSB(i)); 
	end generate;
	
	m_in(0)(35 downto 0) <= (not MSB(0)) & MSB(0) & MSB(0) & p_operand(0);
	m_in(15)(63 downto 30) <= (not MSB(15)) & p_operand(15);
	m_in(15)(28) <= MSB(14);
	m_in(16)(63 downto 32) <= p_operand(16)(31 downto 0);
	m_in(16)(30) <= MSB(15);
	
	signal_assignment: for i in 1 to 14 generate
		m_in(i)(2*i+34 downto 2*i) <= '1' & (not MSB(i)) & p_operand(i);
		m_in(i)(2*i-2) <= MSB(i-1);
	end generate;
	
	--stage_0_assignment
	column_1_a : for j in 0 to 35 generate
		row_1_a : for i in 0 to 16 generate
			stage(0,i)(j) <= m_in(i)(j);
		end generate;
	end generate;
	
	column_1_b : for j in 36 to 63 generate
		row_1_b : for i in (((j+1)/2-17)) to 16 generate
			stage(0,i-((j+1)/2-17))(j) <= m_in(i)(j);
		end generate;
	end generate;
	
	-- other stage assignment
	stages_assignement: for i in 0 to 5 generate
		column: for j in 0 to 63 generate
			
			f: for k in 0 to full_array(i,j)-1 generate
				g: if  j<63 generate
					full_gen: full_adder port map(a => stage(i,3*k)(j), b => stage(i,3*k+1)(j), c_in => stage(i,3*k+2)(j),
												  s => stage(i+1,k)(j), c_out => stage(i+1,dim(i+1)-k)(j+1));
				end generate;
				m: if j=63 generate
					full_gen: full_adder port map(a => stage(i,3*k)(j), b => stage(i,3*k+1)(j), c_in => stage(i,3*k+2)(j),
												  s => stage(i+1,k)(j), c_out => ov);
				end generate;
			end generate;
			
			h: if half_array(i,j) = 1 generate
				half_gen: half_adder port map(a => stage(i,full_array(i,j)*3)(j), b => stage(i,full_array(i,j)*3+1)(j),
											  s => stage(i+1,full_array(i,j))(j), c_out => stage(i+1,dim(i+1)-full_array(i,j))(j+1));
			end generate;
			
			n: if  j>0 generate
			-- (full_array(i,j)*3+half_array(i,j)*2) to dim(1)
				downing: for l in full_array(i,j)+half_array(i,j) to dim(i+1)-full_array(i,j-1)-half_array(i,j-1) generate
					stage(i+1,l)(j) <= stage (i,l+full_array(i,j)*2+half_array(i,j))(j);
				end generate;
			end generate;
			
			p: if  j=0 generate
				downing: for l in 0 to 1 generate
					stage(i+1,l)(j) <= stage (i,l)(j);
				end generate;
			end generate;
			
		end generate;
	end generate;
	
	addend <= stage(6,1)(63 downto 2)&'0'&stage(6,1)(0);
	
	P <= std_logic_vector(unsigned(stage(6,0))+unsigned(addend));
	
end architecture;
