# Imports the monkeyrunner modules used by this program
from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice

# Connects to the current device, returning a MonkeyDevice object
device = MonkeyRunner.waitForConnection()

# Installs the Android package. Notice that this method returns a boolean, so you can test
# to see if the installation worked.
device.installPackage('/home/thao/app-release.apk')

# sets a variable with the package's internal name
package = 'org.rumie.learncloud'

# sets a variable with the name of an Activity in the package
activity = '.ui.MainActivity'

# sets the name of the component to start
runComponent = package + '/' + activity

# Runs the component
device.startActivity(component=runComponent)

# Presses the Menu button
# device.press('KEYCODE_MENU', MonkeyDevice.DOWN_AND_UP)

MonkeyRunner.sleep(4.0) 

# Takes a screenshot
result = device.takeSnapshot()

# Writes the screenshot to a file
result.writeToFile('/home/thao/shot1.png','png')


