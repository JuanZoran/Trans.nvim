import pyttsx3
import sys

a = pyttsx3.init()

a.say(sys.argv[1])
a.runAndWait()
