def main():
    time = input("What time is it? ").strip()
    time_sum = convert(time)
    if 7 <= time_sum <= 8:
        print("breakfast time")
    elif 12 <= time_sum <=13:
        print("lunch time")
    elif 18 <= time_sum <= 19:
        print("dinner time")

def convert(t):
    hh, mm = t.split(":")
    hh = float(hh)
    mm = float(mm)/60
    return hh + mm



if __name__ == "__main__":
    main()
