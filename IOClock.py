import subprocess

print 'Your Raspberry is still booting!'
time.sleep(1)
print 'IOClock will load in 35 seconds..!'
time.sleep(5)
print 'IOClock will load in 30 seconds..!'
time.sleep(5)
print 'IOClock will load in 25 seconds..!'
time.sleep(5)
print 'IOClock will load in 20 seconds..!'
time.sleep(5)
print 'IOClock will load in 15 seconds..!'
time.sleep(5)
print 'IOClock will load in 10 seconds..!'
time.sleep(5)
print 'IOClock will load in 05 seconds..!'
time.sleep(5)
print 'IOClock is loading ....!'


subprocess.check_call(["/usr/share/applications/chromium.desktop", kiosk http://104.236.28.57/ioclock.php, incognito])
