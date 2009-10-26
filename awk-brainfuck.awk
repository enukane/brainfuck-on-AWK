BEGIN{
	# source constructions
	char_pos = 0;
	char_end = 0;
	sources = "";

	# used for source manip
	bfk_string[0] = 0;
	current_pos = 0;

	# tape
	tape[0] = 0;
	tape_pos = 0;
}

{#for each line
	num_char = split($0,array_str, "");
	i = 1;
	while (i <= num_char){
		j = i -1;
		bfk_string[char_pos + j] = array_str[i];
		i++;
	}
	char_pos = char_pos + num_char;
	char_end = char_pos;
}


function do_func(char)
{
	if ( char == ">" ) {
		dprint("inc pointer");
		inc_pointer();	
	}

	if ( char == "<" ) {
		dprint("dec pointer");
		dec_pointer();
	}

	if ( char == "+" ) {
		dprint("add");
		inc_current_value();
	}

	if ( char == "-" ) {
		dprint("sub");
		dec_current_value();
	}

	if ( char == "." ) {
		dprint("show");
		print_current_value_char();
	}
}

function inc_pointer()
{
	tape_pos++;
}

function dec_pointer()
{
	tape_pos--;
}

function inc_current_value()
{
	if (tape[tape_pos] == ""){
		tape[tape_pos] = 0;
	}

	tape[tape_pos]++;
	return tape[tape_pos];
}

function dec_current_value()
{
	if (tape[tape_pos] == ""){
		tape[tape_pos] = 0;
	}

	tape[tape_pos]--;
	return tape[tape_pos];
}

function print_current_value_char()
{
	printf("%c",tape[tape_pos]);	
}


function get_current_value(){
	return tape[tape_pos];
}

function get_next_char()
{
	if ( current_pos > char_end){
		return 0;
	}
	this_char = bfk_string[current_pos];
	current_pos++;
	return this_char;
}

function jump_forward()
{
	cur = get_current_value();
	if ( cur != 0 ) {
		return;
	}
	
	stack_count = 0;

	while (1) {
		char = get_next_char();

		if( char == 0 ){ # end of file
			printf("ERROR - no match clauses\n");
			exit;
		}
		
		if( char == "[" ) { # stack
			stack_count+=1;
			continue;
		}

		if( char == "]" ) {
			if( stack_count > 0 ) {
				stack_count -= 1;
				continue;
			}
			
			# stack_count == 0
			break;
		}
	}
}

function jump_backward()
{
	stack_count = 0;

	cur = get_current_value();
	if( cur == 0 ){
		return;
	}

	if( current_pos < 2 ){
		printf("ERROR - guess only ] appears first?")
	}

	while( current_pos > -1 ){
		current_pos = current_pos - 2;

		char = get_next_char();

		if ( char == 0 ) { #end of file
			printf("ERROR - no match clauses\n");
			exit;
		}

		if( char == "]" ) {
			stack_count += 1;
			continue;
		}

		if( char == "[" ) {
			if( stack_count > 0 ) {
				stack_count -= 1;
				continue;
			}

			# stack_count == 0
			break;
		}
	}
}

function dprint(str)
{
#	printf("%s\n",str);
}

END {
	# here bfk_string is array of source string
	# char_end indicates end of the source array
	while(1)
	{
		char = get_next_char();
		if( char == ""){
			dprint("end of file");
			exit;
		}
		if( char == "[" ){
			jump_forward();
			continue;
		}

		if( char == "]" ) {
			jump_backward();
			continue;
		}

		# other character, function
		do_func(char);
	}
}
