class packet_in extends uvm_sequence_item;
    /* rand logic [31:0] A;
     rand logic [31:0] B;*/
	
	rand logic [31:0] A;
	rand logic [31:0] B;
	
	constraint myrange{ A[30:23] inside{[128:128]};
						B[30:23] inside{[128:128]};};
	
    `uvm_object_utils_begin(packet_in)
        `uvm_field_int(A, UVM_ALL_ON|UVM_HEX)
        `uvm_field_int(B, UVM_ALL_ON|UVM_HEX)
    `uvm_object_utils_end

    function new(string name="packet_in");
        super.new(name);
    endfunction: new
endclass: packet_in
