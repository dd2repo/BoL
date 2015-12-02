# Taschenrechner GUI in Python
# by YL aka dd2
from tkinter import *

window = Tk()
window.title("AWE Projekt Encryption/Decryption")
window.geometry("500x160")

eingabe = Text(window, width=200, height=4)
eingabe.pack()


def c2n():
    alphabet = "abcdefghijklmnopqrstuvwxyz"
    k = 3
    c = ''
    code = ''
    try:
        code = str(eingabe.get('1.0',END))
        code = code.lower()
        code = code.replace("\n","")
    except:
        label1.configure(text="Es ist ein Fehler aufgetreten!")
    finally:
        if code.isalpha():
            for z in code:
                if z == ' ':
                    c += z
                elif z in alphabet:
                    c += alphabet[(alphabet.index(z) + k) % (len(alphabet))]
            label1.configure(text=(str(c)))
        else:
            label1.configure(text="Bitte nur Buchstaben eingeben, keine Zahlen, Sonderzeichen etc.")

def n2c():
    alphabet = "abcdefghijklmnopqrstuvwxyz"
    k = 3
    c = ''
    code = ''
    try:
        code = str(eingabe.get('1.0',END))
        code = code.lower()
        code = code.replace("\n","")
    except:
        label1.configure(text="Es ist ein Fehler aufgetreten!")
    finally:
        if code.isalpha():
            for z in code:
                if z == ' ':
                    c += z
                elif z in alphabet:
                    c += alphabet[(alphabet.index(z) - k) % (len(alphabet))]
            label1.configure(text=(str(c)))
        else:
            label1.configure(text="Bitte nur Buchstaben eingeben, keine Zahlen, Sonderzeichen etc.")


buttonc2n = Button(window, text="caesar -> original", command=c2n)
buttonc2n.pack(fill=BOTH)

buttonn2c = Button(window, text="original -> caesar", command=n2c, height=1, width=1)
buttonn2c.pack(fill=BOTH)

text2 = Label(window, text="=")
text2.pack()

label1 = Label(text="Output will be displayed here!")
label1.pack()

window.mainloop()
