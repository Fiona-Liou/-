#healing playlist

import random


file_path = r"C:\\Users\\HSUAN\\Desktop\\Python\\songs.txt"

def main():
    file_path = r"C:\Users\HSUAN\Desktop\Python\songs.txt"
    songs_dict = load_songs_list(file_path)       # Load songs
    score = mood_quiz()                       # Ask questions
    user_type = classify_user(score)              # Classify user type
    recommend_songs(user_type, songs_dict)         # Recommend songs

def load_songs_list(file_path):
    songs_dict = {
        "high_stress": [],
        "high_anxiety": [],
        "high_anxiety_insomnia": [],
        "healthy": []
    }
    current_type = None

    with open(file_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line.startswith("# High Overall Stress"):
                current_type = "high_stress"
            elif line.startswith("# High Anxiety-Insomnia"):
                current_type = "high_anxiety_insomnia"
            elif line.startswith("# High Anxiety"):
                current_type = "high_anxiety"
            elif line.startswith("# Healthy"):
                current_type = "healthy"
            elif line and current_type:
                songs_dict[current_type].append(line)

    return songs_dict

def safe(prompt):
    while True:
        ans = input(prompt).strip().lower()
        if ans in ["a", "b", "c", "d"]:
            return ans
        else:
            print("Please enter only a, b, c, or d.")

def mood_quiz():
    score = {
        "stress": 0,
        "anxiety": 0,
        "insomnia": 0
    }

    print("Welcome to the Mood Music Recommender! ")
    print("Let's find the perfect tunes to match your mood! ")

    input("✨ Press Enter to begin your small mood quiz... ✨\n")

    print("1️⃣ How have you been sleeping lately?")
    print("   a) Like a baby \n   b) Okay \n   c) Hard to fall asleep \n   d) What is sleep? ")
    ans = safe("Your answer (a/b/c/d): ")
    if ans == "c": score["insomnia"] += 1
    if ans == "d": score["insomnia"] += 2

    print("\n2️⃣ How often do you feel overwhelmed?")
    print("   a) Rarely \n   b) Sometimes \n   c) Often \n   d) Always ")
    ans = safe("Your answer (a/b/c/d): ")
    if ans == "c": score["stress"] += 1
    if ans == "d": score["stress"] += 2

    print("\n3️⃣ Do you get anxious without clear reasons?")
    print("   a) Never \n   b) Occasionally \n   c) Frequently \n   d) Constantly ")
    ans = safe("Your answer (a/b/c/d): ")
    if ans == "c": score["anxiety"] += 1
    if ans == "d": score["anxiety"] += 2

    print("\n4️⃣ What kind of music helps you calm down?")
    print("   a) Soft piano 🎹\n   b) Acoustic chill 🌿\n   c) Something with lyrics 🎤\n   d) Loud beats and noise 🔊")
    ans = safe("Your answer (a/b/c/d): ")
    if ans == "c": score["anxiety"] += 1
    if ans == "d": score["stress"] += 1; score["insomnia"] += 1

    print("\n5️⃣ After a long day, how do you feel?")
    print("   a) Peaceful \n   b) A bit tired \n   c) On edge \n   d) Like I need to scream ")
    ans = safe("Your answer (a/b/c/d): ")
    if ans == "c": score["stress"] += 1
    if ans == "d": score["stress"] += 1; score["anxiety"] += 1

    return score

def classify_user(score):
    if score["insomnia"] >= 2:
        return "high_anxiety_insomnia"
    elif score["anxiety"] >= 2:
        return "high_anxiety"
    elif score["stress"] >= 2:
        return "high_stress"
    else:
        return "healthy"


def recommend_songs(user_type, songs_dict):
    print("\n💡 Based on your answers, your emotional vibe is:")
    if user_type == "high_stress":
        print("\n💥 High Overall Stress Type")
        print("You might be juggling a lot right now. Music with a gentle beat and positive energy could help lift the weight off.")
    elif user_type == "high_anxiety":
        print("\n🌊 High Anxiety Type")
        print("Your mind might be swirling with thoughts. Soothing, mid-tempo music with heartfelt lyrics might ease your mind.")
    elif user_type == "high_anxiety_insomnia":
        print("\n🌙 High Anxiety-Insomnia Type")
        print("You're possibly feeling anxious *and* sleep-deprived 😵‍💫! Time to release some energy with rhythmic, uplifting music.")
    elif user_type == "healthy":
        print("\n🌟 Healthy Type")
        print("You seem pretty balanced today! Why not explore something new and fun to keep your vibes high? ")

    print("Here are 5 songs recommended for you: ")
    if user_type == "healthy":
        all_songs = songs_dict["high_stress"] + songs_dict["high_anxiety"] + songs_dict["high_anxiety_insomnia"]
        songs = random.sample(all_songs, 5)
    else:
        songs = random.sample(songs_dict[user_type], 5)
    i = 1
    for song in songs:
        print(f"{i}. {song}")
        i += 1

    #for i, song in enumerate(songs, 1):
        #print(f"{i}. {song}")




if __name__ == "__main__":
    main()
