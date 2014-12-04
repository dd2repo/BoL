##Taschenrechner GUI in Python
##by YL aka dd2
from tkinter import * 

window = Tk()
window.title("Rechozilla")
window.geometry("180x180")
##window.wm_iconbitmap('tcl\myicon.ico')
window.resizable(0, 0)

eingabex = Entry(window)
eingabex.pack(fill=BOTH)

def rechnenplus():
	try:
		x = float(eingabex.get())
		y = float(eingabey.get())
	except:
		label1.configure(text="Es ist ein Fehler aufgetreten!")
	try:
		label1.configure(text=(x+y))
	except:
		label1.configure(text="Es ist ein Fehler aufgetreten!")

def rechnenminus():
	try:
		x = float(eingabex.get())
		y = float(eingabey.get())
	except:
		label1.configure(text="Es ist ein Fehler aufgetreten!")
	try:
		label1.configure(text=(x-y))
	except:
		label1.configure(text="Es ist ein Fehler aufgetreten!")

def rechnenmal():
	try:
		x = float(eingabex.get())
		y = float(eingabey.get())
	except:
		label1.configure(text="Es ist ein Fehler aufgetreten!")
	try:
		label1.configure(text=(x*y))
	except:
		label1.configure(text="Es ist ein Fehler aufgetreten!")

def rechnengeteilt():
	try:
		x = float(eingabex.get())
		y = float(eingabey.get())
	except:
		label1.configure(text="Es ist ein Fehler aufgetreten!")
	try:
		label1.configure(text=(x/y))
	except:
		label1.configure(text="Es ist ein Fehler aufgetreten!")

buttonplus = Button(window, text="+", command=rechnenplus)
buttonplus.pack(fill=BOTH)

buttonminus = Button(window, text="-", command=rechnenminus, height=1, width=1)
buttonminus.pack(fill=BOTH)

buttonmal = Button(window, text="*", command=rechnenmal, height=1, width=1)
buttonmal.pack(fill=BOTH)

buttongeteilt = Button(window, text="/", command=rechnengeteilt, height=1, width=1)
buttongeteilt.pack(fill=BOTH)

eingabey = Entry(window)
eingabey.pack(fill=BOTH)

text2 = Label (window, text="=")
text2.pack()

label1 =  Label (text="Ausgabe") 
label1.pack()

window.mainloop()
