
import csv

def csv_to_lua_advanced_vs_simple(file_name, skiplines, skipcolumns, num_commas_advanced, num_commas_simple):
    # For this to work, it will expect two files: file_name + "-advanced.csv" and file_name + "-simple.csv", and will output a file called file_name + ".lua"

    # initialize the var meant to capture empty lines worth of commas used for spreadsheet and code readability
    all_commas_advanced = ''
    for i in range(num_commas_advanced):
        all_commas_advanced += ','
    
    all_commas_simple = ''
    for i in range(num_commas_simple):
        all_commas_simple += ','

    # initialize runtime variables
    cur_line_num = 0
    cur_line = ''
    cur_item = ''
    cur_amount = ''
    element_parity = 0  # Didn't know what to call this. It's used to flip back and forth between 'item name' and 'item amount' entries.

    # Open the file to write to
    lua_file = open(file_name + '.lua', 'w')
    
    # Lua: Header stuff 
    lua_file.write('return function(advanced)\n')
    lua_file.write('  if advanced then\n')
    lua_file.write('    return {\n')

    # Lua: parse Advanced mode
    # initialize the 'longest item name' for making the lua code lined up neatly    
    longest_item_name = 0
    csv_file = open(file_name + '-advanced.csv', 'r')
    csv_reader = csv.reader(csv_file)
    for row in csv_reader:
        if cur_line_num > skiplines:
            if longest_item_name < len(row[0]):
                longest_item_name = len(row[0])
        cur_line_num += 1
    csv_file.close()

    # Prep the advanced csv file. Yes I opened it twice. Don't know how to reset the iterator?
    cur_line_num = 0
    csv_file = open(file_name + '-advanced.csv', 'r')
    csv_reader = csv.reader(csv_file)

    # Lua: Each row, formatted like:    ["item-name"]     = {{"ingredient-1-name", ingredient-1-amount}, {"ingredient-2-name", ingredient-2-amount}, ... {"ingredient-n-name", ingredient-n-amount}, }
    for row in csv_reader:
        if (cur_line_num > skiplines and ','.join(row) == all_commas_advanced):   # Skip the first skiplines of lines, used for google sheets stuff; if an all comma row is seen, enter a carraige return
            cur_line = '\n'
        elif (cur_line_num > skiplines and ','.join(row) != all_commas_advanced): # Skip the first skiplines of lines, still
            element_parity = 0
            cur_line = '      [\"' + row[0]
            cur_line += '\"]'
            for i in range(longest_item_name - len(row[0])):
                cur_line += ' '
            cur_line += ' = {'
            for i in range(len(row)):
                if i > skipcolumns + 1:
                    if row[i] != '':
                        if element_parity == 0:
                            cur_amount = row[i]
                            element_parity = 1
                        else:
                            cur_item = row[i]
                            cur_line += '{"' + cur_item + '", '
                            cur_line += cur_amount + '}, '
                            element_parity = 0
            cur_line += '},\n'
        lua_file.write(cur_line)
        cur_line_num += 1
    
    # Bridge
    lua_file.write('    }\n')
    lua_file.write('    else return {\n')

    # Re-initialize runtime variables
    cur_line_num = 0
    cur_line = ''
    cur_item = ''
    cur_amount = ''
    element_parity = 0  # Didn't know what to call this. It's used to flip back and forth between 'item name' and 'item amount' entries.

    # Lua: parse Simple mode
    # initialize the 'longest item name' for making the lua code lined up neatly    
    longest_item_name = 0
    csv_file = open(file_name + '-simple.csv', 'r')
    csv_reader = csv.reader(csv_file)
    for row in csv_reader:
        if cur_line_num > skiplines:
            if longest_item_name < len(row[0]):
                longest_item_name = len(row[0])
        cur_line_num += 1
    csv_file.close()

    # Prep the Simple csv file once more.
    cur_line_num = 0
    csv_file = open(file_name + '-simple.csv', 'r')
    csv_reader = csv.reader(csv_file)

    # Lua: Each row, formatted like:    ["item-name"]     = {{"ingredient-1-name", ingredient-1-amount}, {"ingredient-2-name", ingredient-2-amount}, ... {"ingredient-n-name", ingredient-n-amount}, }
    for row in csv_reader:
        if (cur_line_num > skiplines and ','.join(row) == all_commas_simple):   # Skip the first skiplines of lines, used for google sheets stuff; if an all comma row is seen, enter a carraige return
            cur_line = '\n'
        elif (cur_line_num > skiplines and ','.join(row) != all_commas_simple): # Skip the first skiplines of lines, still
            element_parity = 0
            cur_line = '      [\"' + row[0]
            cur_line += '\"]'
            for i in range(longest_item_name - len(row[0])):
                cur_line += ' '
            cur_line += ' = {'
            for i in range(len(row)):
                if i > skipcolumns + 1:
                    if row[i] != '':
                        if element_parity == 0:
                            cur_amount = row[i]
                            element_parity = 1
                        else:
                            cur_item = row[i]
                            cur_line += '{"' + cur_item + '", '
                            cur_line += cur_amount + '}, '
                            element_parity = 0
            cur_line += '},\n'
        lua_file.write(cur_line)
        cur_line_num += 1

    csv_file.close()

    lua_file.write('    }\n')
    lua_file.write('  end\n')
    lua_file.write('end')

    # Close files; it's been a long day, go home, get a shower, eat a pint of ice cream, watch some tele, sleep.
    lua_file.close()

csv_to_lua_advanced_vs_simple('gm-mw-van', 3, 5, 56, 36)