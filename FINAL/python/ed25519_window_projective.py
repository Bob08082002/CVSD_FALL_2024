# Window, with variable window size
# projective representation
# point double and point addition 沒分開，都用point addition做，且沒schedule過
# modular mul use MM
# modular div use TA version
# modular add, sub 都mod
#
#
import random
q = pow(2,255)-19
q_inv = 21330121701610878104342023554231983025602365596302209165163239159352418617883 # q*q_inv % 2^255 = 2^255-1 = -1 mod 2^255
#print((q*(-1*q_inv)) % pow(2,255))   # 1
#print((q*q_inv) % pow(2,255))        # 57896044618658097711785492504343953926634992332820282019728792003956564819967
R_mod_q = pow(2,255)%q

window_size = 4

count_mod_add_sub = 0
count_mod_mul = 0
count_mul = 0 # 255bit multiplier



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
		tmp = (((r%pow(2,255))*q_inv)%pow(2,255))*q  # ((-xyq^-1) mod R) * q = {[(xy mod R) * (-q^-1 mod R)] mod R } * q = {[((xy) mod R) * q_inv ] mod R } * q
		r = (r + tmp)>>255 # / R == / pow(2,255) == >> 255
		if(r>=q): # mod q
			r -= q
		global count_mul
		count_mul += 3
		return r

	def __mul__(self, other: 'number') -> 'number': # mod mul: value1 * value2 mod q
		# MM has Commutative property
		r = self.MM(self.value,R_mod_q*R_mod_q%q)  # R*R mod q = ((R mod q)*(R mod q)) mod q
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
			if(q_minus_2_in_bin[i]=="1"):
				r = r*other # modular mul: __mul__
		#calculate value1/value2 mod q
		r = self*r # a * (b^-1) mod q # modular mul: __mul__
		return r
	
	def __eq__(self, other: 'number') -> bool: 	# used for debug
		return self.value==other.value
	

d = number(0x52036cee2b6ffe738cc740797779e89800700a4d4141d8ab75eb4dca135978a3)
class point:
	def __init__(self, number_X: number, number_Y: number, number_Z: number = number(1)):
		""" projective """
		self.X = number_X
		self.Y = number_Y
		self.Z = number_Z
		

	def __add__(self, other: 'point') -> 'point': # point addition of projective
		""" projective representation's point addition"""
		Z1Z2 = self.Z*other.Z
		X1X2Y1Y2 = self.X*other.X*self.Y*other.Y
		X3 = Z1Z2*(self.X*other.Y+other.X*self.Y)*(Z1Z2*Z1Z2-d*X1X2Y1Y2)
		Y3 = Z1Z2*(self.Y*other.Y+self.X*other.X)*(Z1Z2*Z1Z2+d*X1X2Y1Y2)
		Z3 = (Z1Z2*Z1Z2-d*X1X2Y1Y2)*(Z1Z2*Z1Z2+d*X1X2Y1Y2)
		return point(X3,Y3,Z3)

	def __mul__(self, M: int) -> 'point': # Scalar Multiplication
		""" window with variable w method """
		r = point(number(0), number(1))  # the zero point
		M_in_bin = "{:0255b}".format(M)
		# pre-computation
		precal_P = [self,] # store 1P, 2P, ... (2^w-1)P # ex: 1P, 2P, ... 15P if w = 4
		for i in range(pow(2, window_size) - 2):
			precal_P.append(precal_P[i] + self)

		i = 0
		while (i + window_size) < 255:
			# r <- point_double_repeat(r, w)
			for _ in range(window_size):
				r = r + r # point double 
			

			di = M_in_bin[i: i+window_size]
			if(di != "0"*window_size): # add pre-calculated LUT
				idx_of_precal_P = int(di, 2) - 1 
				r = r + precal_P[idx_of_precal_P]

			i += window_size
		
		# Double and Add rest bits
		while i < 255:
			r = r + r # point double
			if(M_in_bin[i] == "1"):
				r = r + self  # point addition
			i += 1
			

		return r

	def reduce(self) -> 'point':
		#print("project point back to normal coordinate")
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
	print(point_G) # x: 47f6a5d15e1a09495f9216eba5253538db62c06ad333adbcc86932c069f00d26
				   # y: 465032bc1d1cace745d1b3bad5ca1115805ab1512361151d1c84c68aa2f54468
	print("# of 255bit mul:",count_mul)
	print("# of modular mul:",count_mod_mul)
	print("# of modular add & sub:",count_mod_add_sub)
