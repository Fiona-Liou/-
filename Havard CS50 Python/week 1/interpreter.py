def main():
    expression = input("Expression: ")
    x, y, z = expression.split(" ")
    x = float(x)
    z = float(z)
    ans = formula(x, y, z)
    print(ans)


def formula(x, y, z):
    if y == "+":
        return x + z
    elif y == "-":
        return x - z
    elif y == "/":
        return x / z
    else:
        return x * z

main()
