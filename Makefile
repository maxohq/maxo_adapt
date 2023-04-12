release:
	mix hex.publish

record:
	vhs < examples/example.tape

gen_tape:
	elixir examples/gen_tape.exs
