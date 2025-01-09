# Sliding Window, window size fix to 2
# extended representation
# point double and point addition 有分開，且有Schedule過
# modular mul use MM
# modular div use TA version
# modular add, sub 都mod
# pre-calculated沒移到外面
# 有計算point add, double數量，有預估CYCLE數
# inverse只算一次
# div 都乘兩次，如果q_in_bin[i] = 0也乘，只是是乘1

import random
q = pow(2,255)-19
q_inv = 21330121701610878104342023554231983025602365596302209165163239159352418617883 # q*q_inv % 2^255 = 2^255-1 = -1 mod 2^255
R = pow(2,255)%q
count_mod_add_sub = 0
count_mod_mul = 0
count_mul = 0 # 255bit multiplier

count_point_addition = 0
count_point_double = 0
count_div_mul = 0

class number:
	def __init__(self, value: int):
		self.value = value # 255 bit

	def __add__(self, other: 'number') -> 'number': 
		r = self.value + other.value
		if(r>q):
			r -= q
		assert r == ((self.value + other.value) % q)
		global count_mod_add_sub
		count_mod_add_sub += 1
		return number(r)

	def __sub__(self, other: 'number') -> 'number':
		if(self.value >= other.value):
			r = self.value - other.value
		else:
			r = q - other.value
			r += self.value
		assert r == ((self.value - other.value) % q)
		global count_mod_add_sub
		count_mod_add_sub += 1
		return number(r)

	def MM(self,value1: int, value2: int) -> int: # Montgomery multiplication: (value1 * value2)>>255 mod q
		r = value1 * value2 #xy
		tmp = (((r%pow(2,255))*q_inv)%pow(2,255))*q  #r%pow(2,255)*(-q^(-1)%pow(2,255)) -> x*y mod R = ( x mod R * y mod R ) mod R
		r = (r + tmp)>>255
		if(r>=q):
			r -= q
		global count_mul
		count_mul += 3
		return r

	def __mul__(self, other: 'number') -> 'number': # mod mul: value1 * value2 mod q
		r = self.MM(self.value,R*R%q)
		r = self.MM(r,other.value)
		assert r == ((self.value * other.value) % q)
		global count_mod_mul
		count_mod_mul += 1
		return number(r)

	def __truediv__(self, other: 'number') -> 'number': # mod div: value1 / value2 mod q
		#calculate value2 ^ (q-2) mod q (ie. value2^-1 mod q)
		q_minus_2_in_bin = "111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101011"
		r = number(1)
		for i in range(255):
			r = r*r # modular mul: __mul__
			global count_div_mul
			count_div_mul += 1
			div_mul_op2 = other
			if(q_minus_2_in_bin[i]=="0"):
				div_mul_op2 = number(1)
			r = r*div_mul_op2 # modular mul: __mul__ # other is Z_reg (value2)
			count_div_mul += 1
		#calculate value1/value2 mod p
		r = r*self # modular mul: __mul__
		return r
	
	def __eq__(self, other: 'number') -> bool: 	# used for debug
		return self.value==other.value
	

d = number(0x52036cee2b6ffe738cc740797779e89800700a4d4141d8ab75eb4dca135978a3)
class point:
	def __init__(self, number_X: number, number_Y: number, number_T: number = number(1) , number_Z: number = number(1)):
		""" extended """
		self.X = number_X
		self.Y = number_Y
		self.Z = number_Z
		self.T = number_T if number_T != number(1) else self.X * self.Y * self.Z 
		

	def __add__(self, other: 'point') -> 'point':
		""" extended representation's point addition/double"""
		X_reg = self.X
		Y_reg = self.Y
		Z_reg = self.Z
		T_reg = self.T

		A2_lut = other.Y - other.X
		B2_lut = other.Y + other.X
		Z_lut = other.Z
		Td_lut = other.T * d


		if(self.X==other.X and self.Y==other.Y and self.Z==other.Z and self.T==other.T):
			""" extended representation's point double """
			t1 = Z_reg * Z_reg

			A = X_reg * X_reg
			t2 = X_reg + Y_reg

			B = Y_reg * Y_reg
			C = t1 + t1 

			t2 = t2 * t2

			H = A + B
			G = A - B

			Y_reg = G * H
			F = C + G
			E = H - t2

			Z_reg = F * G

			T_reg = E * H

			X_reg = E * F

			global count_point_double
			count_point_double += 1
			return point(X_reg,Y_reg,T_reg,Z_reg)
		else:
			""" extended representation's point addition """
			C = T_reg * Td_lut
			t2 = Z_reg + Z_reg

			D = t2 * Z_lut
			B1 = Y_reg + X_reg
			A1 = Y_reg - X_reg

			A = A1 * A2_lut
			C = C + C

			B = B1 * B2_lut
			G = D + C
			F = D - C

			Z_reg = F * G
			H = B + A
			E = B - A

			Y_reg = G * H
			
			X_reg = E * F
			
			T_reg = E * H
			global count_point_addition
			count_point_addition += 1
			return point(X_reg,Y_reg,T_reg,Z_reg)

	def __mul__(self, M: int) -> 'point':
		""" Sliding window with w = 2 method """
		r = point(number(0), number(1))  # the zero point
		M_in_bin = "{:0255b}".format(M)
		precal_10 = self+self
		precal_11 = precal_10 + self
		i = 0
		flag = 0
		while (i < 255):
			if(flag == 0):
				r = r + r
			else:
				r = r + r
				r = r + r

			if(M_in_bin[i] == "0"):
				i = i + 1
				flag = 0
			else:
				if(M_in_bin[i:i+2] == "10"):
					r = r + precal_10
					flag = 1
					i = i + 2
				elif(M_in_bin[i:i+2] == "11"):
					r = r + precal_11
					flag = 1
					i = i + 2
		return r

	def reduce(self) -> 'point':
		#print("project point back to normal coordinate")
		inv = number(1)/self.Z
		x = inv * self.X
		y = inv * self.Y
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
	#scalar_M = 0x17e0aa3c03983ca8ea7e9d498c778ea6eb2083e6ce164dba0ff18e0242af9fc3
	#x = number(0x2e2c9fbf00b87ab7cde15119d1c5b09aa9743b5c6fb96ec59dbf2f30209b133c)
	#y = number(0x116943db82ba4a31f240994b14a091fb55cc6edd19658a06d5f4c5805730c232)
	
	#testcase 3
	#scalar_M = 0x1759edc372ae22448b0163c1cd9d2b7d247a8333f7b0b7d2cda8056c3d15eef7
	#x = number(0x5b90ea17eaf962ef96588677a54b09c016ad982c842efa107c078796f88449a8)
	#y = number(0x6a210d43f514ec3c7a8e677567ad835b5c2e4bc5dd3480e135708e41b42c0ac6)
	point_P = point(x, y)
	point_G = (point_P * scalar_M).reduce()
	print("point P:")
	print(point_P)
	print("point G:")
	print(point_G)
	print("# of 255bit mul:",count_mul)
	print("# of modular mul:",count_mod_mul)
	print("# of modular add & sub:",count_mod_add_sub)


	print("number of point double: ", count_point_double)
	print("number of point addition: ", count_point_addition)
	print("number of mul in division: ", count_div_mul)
	print("approximate cycle: ", (count_point_double*10  + count_point_addition*9)+ count_div_mul)  # ignore idle, read, output, pre-cal, div-mul *X, *Y

