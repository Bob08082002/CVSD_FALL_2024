import pandas as pd

box = "S8"

# Load the Excel file
file_path = f'./{box}.xlsx'
df = pd.read_excel(file_path)

# Display the contents to confirm it loaded correctly
df.head()


# Define a function to generate Verilog code from the DataFrame
def generate_verilog_code(df):
    verilog_code = []
    verilog_code.append("always@(*)begin")
    verilog_code.append("\tcase({"+f"{box}_in[5], {box}_in[0]"+"})")
    
    # Loop through each row and generate corresponding Verilog code
    for idx, row in df.iterrows():
        s1_value = row[box]
        condition = f"2'b{s1_value[0]}{s1_value[-1]}"
        verilog_code.append(f"\t\t{condition}:begin")
        verilog_code.append(f"\t\t\tcase({box}_in[4:1])")
        
        for col in df.columns[1:]:
            binary_index = col[1:5]  # Extract the binary part (e.g., '0000' from 'x0000x')
            value = row[col]
            verilog_code.append(f"\t\t\t\t4'b{binary_index}: {box}_out = {value};")
        
        verilog_code.append("\t\t\tendcase")
        verilog_code.append("\t\tend")
    
    verilog_code.append("\tendcase")
    verilog_code.append("end")
    
    return "\n".join(verilog_code)

# Generate the Verilog code
verilog_code = generate_verilog_code(df)

# Save the generated Verilog code to a text file
output_path = f'./{box}_verilog.txt'
with open(output_path, 'w') as file:
    file.write(verilog_code)

