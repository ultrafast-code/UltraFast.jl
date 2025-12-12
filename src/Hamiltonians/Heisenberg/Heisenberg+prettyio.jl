using PrettyTables

# Base.show(io::IO, h::Heisenberg) = parameter_info(io, h)

# function parameter_info(io, h::Heisenberg)
#     table_data = [
#         ["J_x" h.J_x 1.0];
#         ["J_y" h.J_y 1.0];
#         ["mag0" h.mag0 true];
#         ["parallel" h.parallel false];
#         ["marshall_sign_rule" h.marshall_sign_rule true]
#     ]
    
#     # Create highlighters
#     # blue_highlighter = Highlighter(
#     #     (data, i, j) -> j == 2,
#     #     foreground = :blue
#     # )
    
#     # green_highlighter = Highlighter(
#     #     (data, i, j) -> j == 2 && data[i, j] == data[i, 3],
#     #     foreground = :green
#     # )
    
#     # # Create the table with custom formatting
#     # table = pretty_table(io, table_data, header=["Heisenberg", "Value", "Default value"], highlighters = (green_highlighter, blue_highlighter))
    
#     println(io, "Heisenberg parameters:")
#     println(io, "-----------------------")
#     for row in table_data

# #        println(io, row[1], ": ", row[2], " (default: ", row[3], ")")
#     end
#     println(io, "-----------------------")
# end