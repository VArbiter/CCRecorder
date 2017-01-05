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

##### Special Thanks

- Most of the _**`Core Code To Use AvFoundation`**_ was came from [_**`SBVideoCapture`**_ ](https://github.com/PandaraWen/SBVideoCaptureDemo) (By _**Pandara**_.) .
- The _**`UIView Category`**_ was came from _**`LBFramework`**_ (By _**Baoming Fu**_.) .

---

_**Contact Me :**_ <elwinfrederick@163.com> 

> Plus : Do not _**`ASK`**_ or _**`WONDERING`**_ why I use the prefix of _**`CC`**_ &gt; That's the abbreviation of my girlfriend's name .