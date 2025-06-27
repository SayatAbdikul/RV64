import subprocess

print("Hello, pick the test you want to run:")
print("1. Core Test")
print("2. ALU Test")
print("3. Register File Test")
print("4. PC Test")
print("5. Instruction Memory Test")
print("6. Core Execute Unit Test")
choice = input("Enter your choice (1-6): ")
if choice not in {'1', '2', '3', '4', '5', '6'}:
    print("Invalid choice. Exiting.")
    exit(1)
# Run the selected test based on user input
commands = {
    '1': ["verilator -Wall --trace -cc rtl/upper.sv rtl/store.sv rtl/control_flow.sv rtl/core.sv rtl/pc.sv rtl/ram.sv rtl/core_execute_unit.sv rtl/alu.sv rtl/i_decoder.sv rtl/register_file.sv --top core --exe test/core_tb.cpp", 
          "make -C obj_dir -f Vcore.mk Vcore",
          "./obj_dir/Vcore"],
    '2': ["verilator -Wall --trace -cc rtl/alu.sv --top alu --exe test/alu_tb.cpp",
          "make -C obj_dir -f Valu.mk Valu",
          "./obj_dir/Valu"],
    '3': ["verilator -Wall --trace -cc rtl/register_file.sv --top register_file --exe test/register_file_tb.cpp",
          "make -C obj_dir -f Vregister_file.mk Vregister_file",
          "./obj_dir/Vregister_file"],
    '4': ["verilator -Wall --trace -cc rtl/pc.sv --top pc --exe test/pc_tb.cpp",
          "make -C obj_dir -f Vpc.mk Vpc",
          "./obj_dir/Vpc"],
    '5': ["verilator -Wall --trace -cc rtl/ram.sv --top ram --exe test/inst_memory_tb.cpp",
          "make -C obj_dir -f Vram.mk Vram",
          "./obj_dir/Vram"],
    '6': ["verilator -Wall --trace -cc rtl/core_execute_unit.sv rtl/alu.sv rtl/register_file.sv --top core_execute_unit --exe test/core_execute_unit_tb.cpp",
          "make -C obj_dir -f Vcore_execute_unit.mk Vcore_execute_unit",
          "./obj_dir/Vcore_execute_unit"]
}

for cmd in commands[choice]:
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    print(f"Command: {cmd}")
    print(f"Output:\n{result.stdout}")
    if result.stderr:
        print(f"Error:\n{result.stderr}")
    print("-" * 40)