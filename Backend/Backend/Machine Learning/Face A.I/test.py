a = int(input())

b = 0
for i in range(a):
	if (i + 1) % 2 == 0:
		b += i + 1

print(b)