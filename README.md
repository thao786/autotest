Architecture:

1. A wordpress site for marketing and introducing the company
	At first it can be just a 1 page from rails
	route: site.com/ or /welcome/index
	Log In button takes users to Working Site

2. user sign in -> taken to dashboard
	Dashboard shows 2 tabs

* profile: email, account setting
* technical (default tab):
	3 big buttons: create Web based/Mobile/Hybrid test

	your apps: list of uploaded apks 
	each apks has many versions. Each apk has latest testing version. Test always use the lastest version

	2 side by side stats:
		** your total tests: X tests (X web based, X mobile, X hybrid)
			each category expandable into list
		** your total tags: X tags
			expandable into list, each tags shows their own tests




WORKFLOW:
1. user click Create Test
	-> show the Test screen: "all Chrome activities are going to be recorded for this test."

	// The ID of the extension we want to talk to.
	var editorExtensionId = "abcdefghijklmnoabcdefhijklmnoabc";

	// Make a simple request:
	chrome.runtime.sendMessage(editorExtensionId, {openUrlInEditor: url},
	function(response) {
	if (!response.success)
		handleError(url);
	});


	There's 2 menu bars on top showing buttons (Web page and Mobile): There is big buttons: REPLAY

	WEB menu:
	* open web page
	* scrolling
	* click
	* type

	MOBILE menu: require users to upload apks first. Always show how many phones are currently turned on.
	* turn on a phone (all users latest apk should be installed). it can be a phone or an emulator. 
		When a phone is turned on, a new window is open in a new window which listens to all activities on the phone screenshot
	* other activities: same as web based

	There is no locking of web pages and mobile screen. Users can go through the whole session without stopping to redefine anything. They can fix stuff at the end of session. 

	The plugin should pop up notification everytime user perform any action (which is sent to server)

	When editing test, user can remove/add arbitrary actions.

	Plugin will send EVERY action to server. SERVER needs to decide if the action is valid (if session is valid, if a phone is being turned on).
2. how to edit a Test?
	User need to click on a step, and hit INSERT a chunk of steps
	they have to bring the site to that state themselves, and then click INSERT. and then all of those new steps will be insert in the space in between
3. how to pick up where a test was left off? 
	same as 2. Just click on the last step.
4. how to record a test?
	ALWAYS run test non-headless mode to record all screenshots. Then show the screenshot to user (similar to videos), but much less screenshot/data space




DESIGN:
	A session ID is unique to a test, which is stored in the test table. The test table doesn't remember any previous ID. How does Test.com know a session is stopped, or an user has stopped working on it? ITS STOPPED BEING VALID IF ITS BEEN 30 MINUTES AND NO NEW ACTION WAS ADDED.
    SessionId in EVENT references sessionID from test. When create an event, the sessionID must belong to an active test, and current user must own the test suite.



DATA
    PLAN
        has many Users
        a monthly price and limits
	USER
		has many APKs
		has many suites
    SUITE
        has many tests
        title -> name
	TEST
		belongs to 1 suite
		has many STEPs
		session id
		session id last access at
		cache steps
		last updated timestamp
	STEP
		devicetype: mobile or web
		time
		action: click/scroll/type/resize
	DRAFT: 
	    timestamp, webpage, action, value, sessionID 
	APK
		has 1 user
		name
		has many versions
		has 1 current version being used.
	APK_VERSION
		number
		date uploaded
    HISTORY:ENTRY
        which one pass, which one fail




CONTROLLERS:
1. API: for plugin to acquire info about sessions
2. 




QUESTIONS
1. so the drop down suggestion just appear the 1st time a step is created?? 
	When test is being REPLAY, suggestion will appear below the step. User can choose to change from it




DATA to add

SUITE
    description
    active: bool
    last ran:
TEST
    active: bool
    last ran: date
STEP
    active: bool
    
    
Actions bar should appear on top of LAST RAN field
Order of suite and test can be: created/updated/last ran














