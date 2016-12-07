#CCRecorder

## Version 1.1.1

#### CCRecorder is a Recorder Based On _**`GPUImage`**_ and _**`SBVideoCapture`**_ . It can recording multiple videos and _**Merge them into a square video file**_ , also , add Filters .(Only _BilateralFilter && GaussianBlurFilter (for Beauty issues)_ , but you can add more filters by yourself.)

---

##### How To Custom

-  Add **`CCMacro.pch`** to your file . and **`SET`** the _**`Prefix Header`**_ in _**`Build Settings`**_.
-  Add **`UIView+CCRecordToolsKit.h/.m`** to your relevant files , or `copy` that code , or `change the source code` in views.
-  Add **`CCFileManager.h/.m`** , or you can rewrite the method by yourself .
-  The `MOST IMPORTANT` is Copy **`CCRecorderHandler.h/.m`** , and Add **`GPUImage`** .

---

##### Simple Use

- Import _**`ENTIRE PROJECT`**_ to your current project
- To jump to the recorder's view .
- `First` , in your ViewController _**`#import "CCRecordViewController"`**_
- `Second` , _**CCRecordViewController *recordeViewController = [[CCRecordViewController alloc] initWithNibName:@"CCRecordViewController" bundle:[NSBundle mainBundle]];**_
- `Third` , 
- _**[self.navigationController pushViewController:recordeViewController animated:YES];**_ 
- `OR`
- _**[self presentViewController:recordeViewController animated:YES completion:^{**_
- _**// Do sth. after present complete .**_
- _**}];**_
- `Finally` , implement the _**Delegate Method**_ , and _**SET**_ the button actions.


---

##### Vendors

- **GPUImage**

---

##### Dependence Framework

- **AVFoundation.framework**
- **QuartzCore.framework**
- **CoreGraphics.framework**
- **CoreMedia.framework**
- **MediaPlayer.framework** _**(if needs to play the record file.)**_
- And of course , **Foundation.framework** && **UIKit.framework**

---
##### More Details
- You can find _**MORE UI DETAILS**_ in _**`CCRecordViewController`**_

---

##### Developing Log

2016-07-21 18:28:38 Create Project .

2016-07-21 19:22:13 Main Interface Build .

2016-07-22 14:37:18 Add RecorderHandler .

2016-07-22 17:35:31 A little bit adjustment in GPUImage , for get more interfaces.

2016-07-22 19:06:57 One more step further to ... so called _**a little bit adjustment in GPUImage .**_ Well , to let it expose more interfaces. _(Hope not to cause any unknown crash.)_

2016-07-25 18:43:49 NO CRASH ! HAHA ! And successfully add the bilatera filter to the recorder . BUT , in the end , so called _"a little bit adjustment in GPUImage"_ was not in use . Also , I put that Torch && flash in function , focus mode too.

2016-07-25 19:48:19 Make CCRecorder can change the camera .

2016-07-27 18:39:32 Add a timer indicator with a _**progress bar**_.

2016-07-27 19:06:41 Finished with delegate methods .

2016-08-01 17:11:43 Set Front Camera as default camera and set beauty filter on when intial CCRecorder . Adjust _**Progress Bar IN FUNCTION**_.

2016-08-01 18:53:05 Besides some little BUGs , _**CCRecorder is COMPLETED**_ .

2016-08-01 19:26:51 Make CCRecorder _**support long press and tap**_.

2016-08-02 16:02:24 Fix transform and clip issues .

2016-08-02 17:19:30 Make it can record with filters.

2016-08-03 15:22:27 Almost finished except a critical **BUG** - _Lost the first frame , so that make the merging file looks like have a interruption._ 

2016-08-03 16:33:00 Add a controller for playing .

2016-08-03 18:36:34 Fix Focus issues .

2016-08-15 19:24:09 Finally , _**COMPLETE !**_ 

2016-09-13 14:14:45 Fix BUGS .
	
---
##### Special Thanks

- Most of the _**`Core Code To Use AvFoundation`**_ was came from _**`SBVideoCapture`**_ (By _**Pandara**_.) .
- The _**`UIView Category`**_ was came from _**`LBFramework`**_ (By _**Baoming Fu**_.) .

---

_**Contact Me :**_ <elwinfrederick@163.com> 

> Plus : Do not _**`ASK`**_ me why I use the prefix of _**`CC`**_ &gt; That's the abbreviation of my girlfriend's name .