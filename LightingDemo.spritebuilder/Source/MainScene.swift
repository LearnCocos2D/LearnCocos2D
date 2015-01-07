import Foundation

class MainScene: CCNode
{
    var touchLight : CCNode!
    
    func didLoadFromCCB() {
        //CCDirector.sharedDirector().displayStats = true
        self.userInteractionEnabled = true

        // check if app runs on Simulator, if so, add a warning label
#if (arch(i386) || arch(x86_64)) && os(iOS)
        var label = CCLabelTTF(string: "NOTE: iOS Simulator will not run this demo at an\nacceptable framerate (<10 fps). Run it on a device!", fontName: "Arial", fontSize: 16)
        label.position = ccp(250, 20)
        self.addChild(label);
#endif
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        touchLight.visible = true
        touchLight.position = touch.locationInNode(self)
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        touchLight.position = touch.locationInNode(self)
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        touchLight.visible = false
    }

    override func touchCancelled(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        touchLight.visible = false
    }
}
