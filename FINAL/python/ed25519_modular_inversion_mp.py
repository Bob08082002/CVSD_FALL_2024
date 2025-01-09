import random
import time

q = pow(2,255)-19
q_inv = 21330121701610878104342023554231983025602365596302209165163239159352418617883 # q*q_inv % 2^255 = 2^255-1 = -1 mod 2^255
R = pow(2,255)%q
count_add_sub = 0
count_mul = 0


count_inv_iter = 0


def rs_as_modular_inverse(a, m):
    U, V = m, a
    R, S = 0, 1
    global count_add_sub 
    global count_inv_iter
    while V > 1:
        count_inv_iter += 1
        if V % 2 == 0:
            V  = V >> 1
            if S % 2 == 0:
                S = S >> 1
            else:
                S = (S + m) >> 1
                count_add_sub += 1
        elif U % 2 == 0:
            U = U >> 1
            if R % 2 == 0:
                R = R >> 1
            else:
                R = (R + m) >>1
                count_add_sub += 1
        else:
            # This is where the Add-Subtract (AS) comes into play based on bitwise checks
            if U > V:
                U -= V
                R -= S
                count_add_sub += 2
                if R < 0:
                    R += m
                    count_add_sub += 1
            else:
                V -= U
                S -= R
                count_add_sub += 2
                if S < 0:
                    S += m
                    count_add_sub += 1
            # After V-U or U-V, divide by 2 if conditions are met
            if U % 2 == 0:
                U = U >> 1
                if R % 2 == 0:
                    R = R >> 1
                else:
                    R = (R + m) >> 1
                    count_add_sub += 1
            if V % 2 == 0:
                V = V >> 1
                if S % 2 == 0:
                    S = S >> 1
                else:
                    S = (S + m) >> 1
                    count_add_sub += 1
                
    # Final check for S after loop completion
    if V == 0:
        return 0  # No inverse exists
    
    if S < 0:
        S += m
    return S



def right_shift_binary_inversion(a): # a is Z_reg
    U = q
    V = a
    R = 0
    S = 1
    global count_add_sub 
    global count_inv_iter

    while V > 0:
        count_inv_iter += 1
        if U % 2 == 0: # even
            U = U >> 1
            if R % 2 == 0: # even
                R = R >> 1
            else:
                R = (R + q) >> 1
        elif V % 2 == 0:  # even
            V = V >> 1
            if S % 2 == 0:
                S = S >> 1
            else:
                S = (S + q) >> 1
        else:
            if U > V:
                U -= V
                R -= S
                count_add_sub += 2
                if R < 0:
                    R += q
                    count_add_sub += 1
            else:
                V -= U
                S -= R
                count_add_sub += 2
                if S < 0:
                    S += q
                    count_add_sub += 1

    if R > q:
        R -= q
    if R < 0:
        R += q
    return R


class number:
	def __init__(self, value: int):
		self.value = value # 255 bit

	def __add__(self, other: 'number') -> 'number': 
		global count_add_sub
		r = self.value + other.value
		count_add_sub += 1
		if(r>q):
			r -= q
			count_add_sub += 1
		assert r == ((self.value + other.value) % q)
		return number(r)

	def __sub__(self, other: 'number') -> 'number':
		global count_add_sub
		if(self.value >= other.value):
			r = self.value - other.value
			count_add_sub += 1
		else:
			r = q - other.value
			r += self.value
			count_add_sub += 2
		assert r == ((self.value - other.value) % q)
		return number(r)

	def __mul__(self, other: 'number') -> 'number': # mod mul: value1 * value2 mod q
		r = (self.value * other.value) % q

		global count_mul
		count_mul += 1
		assert r == ((self.value * other.value) % q)
		return number(r)

	def __truediv__(self, other: 'number') -> 'number': # mod div: value1 / value2 mod q
		#calculate value2 ^ (p-2) mod p
		#mod_inverse = right_shift_binary_inversion(other.value)
		mod_inverse = rs_as_modular_inverse(other.value, q)

		r = self * number(mod_inverse)
		return r
	
	def __eq__(self, other: 'number') -> bool: 	# used for debug
		return self.value==other.value

	def bit_length(self):
		return self.value.bit_length()

	

d = number(0x52036cee2b6ffe738cc740797779e89800700a4d4141d8ab75eb4dca135978a3)
class point:
	def __init__(self, number_X: number, number_Y: number, number_Z: number = number(1), number_T: number = number(1)):	
		self.X = number_X
		self.Y = number_Y
		self.Z = number_Z
		if (number_T != number(1)):
			self.T = number_T
		else:
			self.T = self.X * self.Y * self.Z

	def __add__(self, other: 'point') -> 'point':
		if ((self.X == other.X) and (self.Y == other.Y) and (self.Z == other.Z) and (self.T == other.T)):
			A = self.X * self.X
			B = self.Y * self.Y 
			C = number(2) * self.Z * self.Z
			H = A + B
			E = H - ((self.X + self.Y) * (self.X + self.Y))
			G = A - B
			F = C + G
			X3 = E * F
			Y3 = G * H			
			T3 = E * H		
			Z3 = F * G

			return point(X3,Y3,Z3,T3)

		else:
			A = (self.Y - self.X) * (other.Y - other.X)
			B = (self.Y + self.X) * (other.Y + other.X)
			C = self.T * number(2) * d * other.T
			D = self.Z * number(2) * other.Z
			E = B - A
			F = D - C
			G = D + C
			H = B + A
			X3 = E * F
			Y3 = G * H			
			T3 = E * H		
			Z3 = F * G

			return point(X3,Y3,Z3,T3)

	def __mul__(self, M: int) -> 'point':
		r = point(number(0), number(1))  # the zero point
		M_in_bin = "{:0255b}".format(M)
		
		double = self + self
		add_result_100 = double + double
		add_result_101 = self + add_result_100
		add_result_110 = double + add_result_100
		add_result_111 = self + add_result_110 

		i = 0
		while(i < 255):
			if (M_in_bin[i]=="0"):
				r = r + r
				i += 1
			else:
				if (i == 254):
					r = r + r
					if M_in_bin[i] == '1':
						r = r + self
					i += 1
				elif (i == 253):
					r = r + r
					r = r + r
					current_bit_seq = M_in_bin[253:255]
					if current_bit_seq == '10':
						r = r + double
					else:
						r = r + double
						r = r + self
					i += 2
				else:
					r = r + r
					r = r + r
					r = r + r
					current_bit_seq = M_in_bin[i:i+3]
					if current_bit_seq == '100':
						r = r + add_result_100
					elif current_bit_seq == '101':
						r = r + add_result_101
					elif current_bit_seq == '110':
						r = r + add_result_110
					else:
						r = r + add_result_111
					i += 3
		return r
							
				


	def reduce(self) -> 'point':
		x = self.X/self.Z
		y = self.Y/self.Z
		if(x.value%2==1): x.value = q-x.value
		if(y.value%2==1): y.value = q-y.value
		return point(x, y)
		
	def is_on_curve(self): # require self.Z=1
		return self.Y*self.Y-self.X*self.X == number(1) + d * self.X*self.X*self.Y*self.Y
	
	def __str__(self): # used for debug
		if(self.Z.value!=1):
			text = "The z-coordinate != 1"
		elif(self.is_on_curve()):
			text = "x: {:064x}\n".format(self.X.value) + "y: {:064x}\n".format(self.Y.value)
		else:
			text = "Invalid point"
		return text


if __name__ == "__main__":
	#testcase 1
	scalar_M = 0x259f4329e6f4590b9a164106cf6a659eb4862b21fb97d43588561712e8e5216a
	x = number(0x0fa4d2a95dafe3275eaf3ba907dbb1da819aba3927450d7399a270ce660d2fae)
	y = number(0x2f0fe2678dedf6671e055f1a557233b324f44fb8be4afe607e5541eb11b0bea2)


	#testcase 2
	# scalar_M = 0x17e0aa3c03983ca8ea7e9d498c778ea6eb2083e6ce164dba0ff18e0242af9fc3
	# x = number(0x2e2c9fbf00b87ab7cde15119d1c5b09aa9743b5c6fb96ec59dbf2f30209b133c)
	# y = number(0x116943db82ba4a31f240994b14a091fb55cc6edd19658a06d5f4c5805730c232)
	
	#testcase 3
	#scalar_M = 0x1759edc372ae22448b0163c1cd9d2b7d247a8333f7b0b7d2cda8056c3d15eef7
	#x = number(0x5b90ea17eaf962ef96588677a54b09c016ad982c842efa107c078796f88449a8)
	#y = number(0x6a210d43f514ec3c7a8e677567ad835b5c2e4bc5dd3480e135708e41b42c0ac6)


	point_P = point(x, y)
	ts = time.time()
	point_G = (point_P * scalar_M).reduce()
	tf = time.time()
	t_op = tf - ts
	print("Operation Time: {}".format(t_op))

	print("point P:")
	print(point_P)
	print("point G:")
	print(point_G)
	print("# of mod mul:",count_mul)
	print("# of mod add & sub:",count_add_sub)

	print("# of count_inv_iter", count_inv_iter)