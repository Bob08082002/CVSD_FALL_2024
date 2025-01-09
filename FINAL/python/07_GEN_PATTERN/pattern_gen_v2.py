from ed25519 import number, point
import random


MAX_ITER = 100

def generate_random_scalar():
    return random.getrandbits(255)

def generate_point_on_curve():
    # Constants for ed25519
    q = pow(2, 255) - 19
    a = q - 1
    d = 0x52036cee2b6ffe738cc740797779e89800700a4d4141d8ab75eb4dca135978a3

    loop = 0
    while loop < MAX_ITER:
        # print(f"Have tried {loop+1} times to find point P.")

        # Generate random y coordinate
        y = number(random.randrange(q))
        

        try:
            y_squared = (y * y).value % q
            numerator = (1 - y_squared) % q
            denominator = ((a) - d * y_squared) % q
            
            # Calculate modular inverse of denominator
            inv_denominator = pow(denominator, q-2, q)
            x_squared = (numerator * inv_denominator) % q
            
            # Try both possible x values (positive and negative square root)
            x = number(pow(x_squared, (q+3)//8, q))
            
            point_P = point(x, y)
            if point_P.is_on_curve():
                return point_P
            
            # Try negative x
            x = number(q - x.value)
            point_P = point(x, y)
            if point_P.is_on_curve():
                return point_P
                
        except:
            pass
            
        loop += 1
        continue

    raise Exception("Failed to find valid point after MAX_ITER attempts")
    



def main(pattern_num):
    with open(file_path, "w") as f:
        
        for i in range(pattern_num):
            print(f"Generating pattern {i+1}/{pattern_num}")
            
            # Generate valid input point
            point_P = generate_point_on_curve()
            scalar_M = generate_random_scalar()
            point_G = (point_P * scalar_M).reduce()
            
            input_hex = f"{scalar_M:064x}{point_P.X.value:064x}{point_P.Y.value:064x}"
            golden_hex = f"{point_G.X.value:064x}{point_G.Y.value:064x}"
            
            f.write(f"package dat_{i};\n")
            f.write(f"integer pat_num = {i};\n")
            f.write(f"// M: extract scalar, X: extract X-coord, Y: extract Y-coord\n")
            f.write(f"reg [767:0] input_data  = 768'h{input_hex};\n")
            f.write(f"reg [511:0] golden_data = 512'h{golden_hex};\n")
            f.write(f"endpackage\n")
        

if __name__ == "__main__":
    # point_p = generate_point_on_curve()
    # print(f"point_p :\n{point_p}")
    file_path = "./tb_dat_gen.sv"
    pattern_num = 300
    main(pattern_num)