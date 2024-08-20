package main

import "core:encoding/ansi"
import "core:encoding/json"
import "core:fmt"
import "core:strings"

Colours :: enum {
	Red,
	Green,
	Yellow,
	Blue,
	Magenta,
	Cyan,
}

Colour_Values :: [Colours]string {
	.Red     = ansi.CSI + ansi.FG_RED + ansi.SGR,
	.Green   = ansi.CSI + ansi.FG_GREEN + ansi.SGR,
	.Yellow  = ansi.CSI + ansi.FG_YELLOW + ansi.SGR,
	.Blue    = ansi.CSI + ansi.FG_BLUE + ansi.SGR,
	.Magenta = ansi.CSI + ansi.FG_MAGENTA + ansi.SGR,
	.Cyan    = ansi.CSI + ansi.FG_CYAN + ansi.SGR,
}

pretty_print :: proc(json_str: string) {
	str, _ := loop_tokens(json_str)
	fmt.println(str)
}

loop_tokens :: proc(json_str: string) -> (string, json.Error) {
	parser := json.make_parser_from_string(json_str)
	builder := strings.builder_make()
	colour := Colours.Red
	Colour_Values_var := Colour_Values

	new_line := true
	indent := 0

	for {
		token := parser.curr_token
		prev := parser.prev_token

		switch token.kind {
		case .EOF:
			return strings.to_string(builder), nil
		case .Invalid:
			return "", nil
		case .Open_Brace, .Open_Bracket:
			//rainbow
			strings.write_string(&builder, Colour_Values_var[colour])
			iter_colour_forward(&colour)

			//Look ahead if followed by closing
			new_line = true
			indent += 1

		case .Close_Brace, .Close_Bracket:
			//rainbow
			strings.write_string(&builder, "\n")
			iter_colour_backward(&colour)
			strings.write_string(&builder, Colour_Values_var[colour])

			//look ahead if followed by comma
			new_line = true
			indent -= 1

		case .Colon, .Ident:
			//White
			new_line = false

		case .Comma:
			new_line = true

		case .True, .False:
			//Yellow
			strings.write_string(&builder, Colour_Values_var[Colours.Yellow])
			new_line = false

		case .Integer, .Float:
			//Blue
			strings.write_string(&builder, Colour_Values_var[Colours.Blue])
			new_line = false

		case .String:
			if is_key(&prev.kind) {
				//Magenta
				add_indent(&indent, &builder)
				strings.write_string(&builder, Colour_Values_var[Colours.Magenta])
				new_line = false
			} else {
				//Green
				strings.write_string(&builder, Colour_Values_var[Colours.Green])
				new_line = false
			}

		case .Null:
			//Red
			strings.write_string(&builder, Colour_Values_var[Colours.Red])
			new_line = false

		case .NaN, .Infinity:
			//Cyan
			strings.write_string(&builder, Colour_Values_var[Colours.Cyan])
			new_line = false
		}

		strings.write_string(&builder, token.text)
		if new_line {
			strings.write_string(&builder, "\n")
		}

		json.advance_token(&parser)
	}
}

add_indent :: proc(indent: ^int, builder: ^strings.Builder) {
	for i := 0; i < indent^; i += 1 {
		strings.write_string(builder, "  ")
	}
}

is_key :: proc(prev_token: ^json.Token_Kind) -> bool {
	if prev_token^ != json.Token_Kind.Colon {
		return true
	}

	return false
}

iter_colour_forward :: proc(colour: ^Colours) {
	switch colour^ {
	case .Red:
		colour^ = .Green
	case .Green:
		colour^ = .Yellow
	case .Yellow:
		colour^ = .Blue
	case .Blue:
		colour^ = .Magenta
	case .Magenta:
		colour^ = .Cyan
	case .Cyan:
		colour^ = .Red
	}
}

iter_colour_backward :: proc(colour: ^Colours) {
	switch colour^ {
	case .Red:
		colour^ = .Cyan
	case .Green:
		colour^ = .Red
	case .Yellow:
		colour^ = .Green
	case .Blue:
		colour^ = .Yellow
	case .Magenta:
		colour^ = .Blue
	case .Cyan:
		colour^ = .Magenta
	}
}
