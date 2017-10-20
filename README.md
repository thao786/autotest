Thuy:
- move HAVE MORE TEST to the list' start
    
- highlight pageload: is this the result of a click or Js? if yes, user needs to remove the step
- make click dropdownlist copyable



REDESIGN
- redesign modal errors
- mark all Interpolatable fields obvious



Thao:
- better explanation of Ruby Interpolation

- better click editing
- paginations
- run test with FireFox too
- detect browser to show Warning
- redirect sign in to /suites
- better user exprience when running test: show all warnings. Ex: we use window name to determine tabs. messing with it while using multiple tabs results in disasters

    The testing environment doesnt have google plugins so make sure its the same

- when 500 happens, email Thao
- make video private. only show temporary url
- make local do HTTPS




VIDEO SCRIPT

[open intro page]
welcome to UI Check. This guide will show you how to create tests and run it on our platform.

[sign in]

[once in /suites. create a suite]
first u need to create a suite. a test belongs to a suite. lets create one called 'testing'

[create a test]
now we can create tests. lets make one called 'browsing'. our test is now created. 

[point to the Extension red symbol on address bar]
lets try recording some steps with Google Extension. Before that make sure it is installed and activated. 

[click Record Steps. Open reddit.com and browse around]
now we are ready to record steps. Lets open reddit.com and see if UI Check can recognize the actions. When running test, browsers opened by Selenium does not have plugins or logged in state like your personal computer, so please keep that in mind.

[click Stop Recording Steps]
think I've read enough on reddit. lets look at the recorded actions. Here they are. We might want to edit those steps. Like this pageload, dont think I intentionally open the url. It was the result of my clicking on a link. so lets remove it.

edit click

create new step at last

[define some assertion]
you can choose from a list of assertions here. lets try HTMl Contained in Page. 

[click Run Test]
now we are ready to run the test. its going to take a few minutes for the test to run. ...

[click play Video]
now its done. so our assertion did not pass. the final page does not seem to contain the keyword. lets confirm in the result video.

[]
this concludes our test. thanks for watching.

