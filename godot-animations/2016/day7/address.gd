var data: String

var supports_tls = null
var supports_ssl = null

var brackets = []
var abba_regions = []
var aba_regions = []

func _init(_data):
	data = _data
	
	compute_abba_regions()
	compute_aba_regions()
	
func compute_abba_regions():
	var in_brackets = false
	var i = 0
	while i < (data.length() - 3):
		if data[i] == "[":
			in_brackets = true
			brackets.append(i)
			i += 1
			continue
			
		if data[i] == "]":
			in_brackets = false
			brackets.append(i)
			i += 1
			continue
			
		if abba_at_pos(i):
			if in_brackets:
				supports_tls = false
				abba_regions.append([i, false])
			else:
				if supports_tls == null:
					supports_tls = true
				abba_regions.append([i, true])
			i += 4
			continue
		
		i += 1
	
func abba_at_pos(pos):
	var a = data[pos]
	var b = data[pos+1]
	
	if a == b:
		return false
	if data[pos+2] != b:
		return false
	if data[pos+3] != a:
		return false
		
	return true
	
func compute_aba_regions():
	precompute_hypernets()
	
	for possible_aba in find_aba_positions():
		var possible_bab = check_for_bab(possible_aba)
		if possible_bab:
			aba_regions.append(possible_aba)
			aba_regions.append_array(possible_bab)
			supports_ssl = true
			
	
var hypernet_sequences = []
func precompute_hypernets():
	var l_bracket_pos = data.find("[")
	
	while l_bracket_pos > 0:
		var r_bracket_pos = data.find("]", l_bracket_pos)
		var seq_start = l_bracket_pos + 1
		var sequence = data.substr(seq_start, r_bracket_pos - seq_start)
		hypernet_sequences.append([seq_start, sequence])
		
		l_bracket_pos = data.find("[", r_bracket_pos)
	
# Return an array of all possible ABA positions. Does not check for
# corresponding BAB sequences.
func find_aba_positions():
	var aba_positions = []
	
	var in_brackets = false
	for i in range(0, data.length() - 2):
		var a = data[i]
		var b = data[i+1]
		
		if a == "[":
			in_brackets = true
			continue
		if a == "]":
			in_brackets = false
			continue
		if data[i+2] != a:
			continue
		if a == b || b == "[" || in_brackets:
			continue
			
		aba_positions.append(i)
		
	return aba_positions

func check_for_bab(aba_position):
	var bab_positions = []
	
	var a = data[aba_position]
	var b = data[aba_position+1]
	
	for hyper_seq in hypernet_sequences:
		var seq_start = hyper_seq[0]
		var seq = hyper_seq[1]
		
		for i in range(0, seq.length() - 2):
			if seq[i] == b && seq[i+1] == a && seq[i+2] == b:
				bab_positions.append(i + seq_start)
				
	if !bab_positions.is_empty():
		return bab_positions
