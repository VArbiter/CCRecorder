#CCRecorder

## Version 0.5.50

#### CCRecorder is a Recorder Based On _**`GPUImage`**_ and _**`SBVideoCapture`**_ . It can recording multiple videos and _**Merge them into a square video file**_ , also , add Filters .(Only _BilateralFilter && GaussianBlurFilter (for Beauty issues)_ , but you can add more filters by yourself.)

---

##### How To Custom

-  Add **`CCMacro.pch`** to your file . and **`SET`** the _**`Prefix Header`**_ in _**`Build Settings`**_.
-  Add **`UIView+CCRecordToolsKit.h/.m`** to your relevant files , or `copy` that code , or `change the source code` in views.
-  Add **`CCFileManager.h/.m`** , or you can rewrite the method by yourself .
-  The `MOST IMPORTANT` is Copy **`CCRecorderHandler.h/.m`** , and Add **`GPUImage`** .

---

##### Simple Use

- You need to add `This Source code` to your `info.plist` .

	< key >NSMicrophoneUsageDescription</ key  >
	
	< string >Mic</ string >
	
	< key >NSCameraUsageDescription</ key >
	
	< string >Video</ string >

- Import _**`CCRecorderLibrary`**_ to your current project , or just `pod install`
- `pod 'CCRecorderLibrary' , :path => '../CCRecorderLibrary'`
- To jump to the recorder's view .
- `First` , in your ViewController _**`#import "CCRecordViewController"`**_
- `Second` , _**[[CCRecordViewController alloc] initWithNibName:@"CCRecordViewController"                                                          bundle:_ccBundle()];**_
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

Update :

	2017-05-25 11:20:27 
    filtered the files . remain only the neccessarys .
    GPUImageContext
    GPUImageOutput
    GPUImageColorConversion
    GPUImageVideoCamera
    GPUImageMovieWriter
    GPUImageFilter
    GLProgram
    GPUImageFramebuffer
    GPUImageFramebufferCache
    GPUImagePicture
    GPUImageBilateralFilter
    GPUImageGaussianBlurFilter
    GPUImageTwoPassTextureSamplingFilter
    GPUImageTwoPassFilter
    GPUImageFilterGroup

---

##### Dependence Framework (Already added in podspec)

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

- Lightly inspired by [_**`SBVideoCapture`**_ ](https://github.com/PandaraWen/SBVideoCaptureDemo) (By _**Pandara**_.) .

---

_**Contact Me :**_ <elwinfrederick@163.com> 

> <del>Plus : Do not _**`ASK`**_ or _**`WONDERING`**_ why I use the prefix of _**`CC`**_ &gt; That's the abbreviation of my girlfriend's name .</del> 
> 
> Updated (2017-08-29 23:51:05) : Not any more .
> 
    
---
as the answer for previous question :
	
	Bundle in a framework . is a resource package . 
	Complier won't do anything about it . 
	Like a folder in computer .
	this bundle is kinda a folder in recorder .
