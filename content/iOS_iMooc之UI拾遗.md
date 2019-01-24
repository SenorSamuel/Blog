## iMooc之UI拾遗

![SamuelChan/20180626154542.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180626154542.png)

### 一.UITableView

#### UITableView重用机制实现原理
```objc

cell = [tableView dequeueReusableCellWithIdentifier:identifier];

For performance reasons, a table view’s data source should generally reuse UITableViewCell
objects when it assigns cells to rows in its tableView:cellForRowAtIndexPath: method. A table
view maintains a queue or list of UITableViewCell objects that the data source has marked for
reuse. Call this method from your data source object when asked to provide a new cell for the
table view. This method dequeues an existing cell if one is available or creates a new one using
the class or nib file you previously registered. If no cell is available for reuse and you did not
register a class or nib file, this method returns nil.

If you registered a class for the specified identifier and a new cell must be created, this method
initializes the cell by calling its initWithStyle:reuseIdentifier: method. For nib-based cells, this
method loads the cell object from the provided nib file. If an existing cell was available for reuse,
this method calls the cell’s prepareForReuse method instead.
```
使用了两个NSMutableSet来管理,`_waitUsedQueue`和`_usingQueue`

- 新建cell,加入`_usingQueue`
- 重用cell,从`_waitUsedQueue`移除,加入`_usingQueue`
- reloadData,将`_usingQueue`全部移到`_waitUsedQueue`中

#### 数据源同步
> 多线程修改数据源如何保证数据源同步

- 并发访问 →→数据拷贝 : 可能会造成内存开销
![SamuelChan/20180624212558.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180624212558.png)

- 串行访问 → 数据很多的情况下,会非常耗时
![SamuelChan/20180624212917.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180624212917.png)

### 二. 事件传递&&视图响应
1. CALayer和UIView关系: 
UIView.layer == CALayer
CALayer.content == backingStore ==  bitmap
UIView.backgroundColor == CALayer.backgroundColor
UIView负责接收事件传递和响应,CALayer负责视图显示/渲染,体现了`单一原则`的设计原则

2. 事件传递

```objc
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent * )event;

- (BOOL)pointInside(CGPoint)point withEvent:(UIEvent *)event;
```
![SamuelChan/20180624215851.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180624215851.png)

![SamuelChan/20180624220426.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180624220426.png)


3.默认事件是沿着响应链向上传递,如果到最终到UIApplicationDelegate都没有处理事件,那么事件就不被处理
![SamuelChan/20180624222931.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180624222931.png)

4.UIControl,UIGesture和响应链

> When a control-specific event occurs, the control calls any associated action methods right away. Action methods are dispatched through the current UIApplication object, which finds an appropriate object to handle the message, following the responder chain if needed.

**UIControl类的事件分发由UIApplication负责,如果UIControl不处理,那么事件响应会跟随响应者链条**

> A window delays the delivery of touch objects to the view so that the gesture recognizer can analyze the touch first. During the delay, if the gesture recognizer recognizes a touch gesture, then the window never delivers the touch object to the view, and also cancels any touch objects it previously sent to the view that were part of that recognized sequence.

**如果hitTest返回的View有手势,那么事件就分别开始手势识别和响应响应链,假设手势识别失败,那么就与正常处理相同; 如果手势识别成功,那么调用响应者的touchsCancelled:withEvent,cancel之前传递的所有响应对象**

**手势识别是需要一点时间的。在手势还是Possible 状态的时候，事件传递给了响应链的第一个响应对象（baseView 或者 testView）**

![SamuelChan/20180625143948.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180625143948.png)

case 1: 点击BaseView : 
>  base view touchs Began				
    base view touchs Moved			
    base view touchs Moved  			
    single Tapped			
   base view touchs Cancelled

case2: 点击testView :
>  test view touchs Began		
    single Tapped		
    test view touchs Cancelled		

case 3: 点击testBtn
>  click testbtn

case 4: gesture.`cancelsTouchesInView` == NO(default是YES)  + 点击testView
>  手势识别了,也不会取消之前的UIEvent				
    test view touchs Began		
    single Tapped		
    test view touchs Ended
    
case 5: gesture.`delaysTouchesBegan ` == YES(default是NO)  + 点击testView
>   single Tapped		


参考资料
- [Using Responders and the Responder Chain to Handle Events](https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/using_responders_and_the_responder_chain_to_handle_events) 

### 三.图像显示原理

![SamuelChan/20180625223604.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180625223604.png)

#### 卡顿 && 掉帧
- iOS设备的帧率大概是60FPS, 1/60 = 16.7 ms
- 如果CPU和GPU在16.7ms内没有准备好下一帧画面,在Vsync信号到来时,该帧就会被丢弃

![SamuelChan/20180625223817.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180625223817.png)

#### 绘制原理 && 异步绘制
![SamuelChan/20180625225300.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180625225300.png)

系统绘制
![SamuelChan/20180625225537.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180625225537.png)

异步绘制
[layer.delegate displayLayer:] : 代理负责生成bitmap,并提交到layer.contents中
![SamuelChan/20180625230018.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180625230018.png)

#### 离屏渲染

![SamuelChan/20180625232041.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180625232041.png)

#### 界面优化方案
	
![SamuelChan/20180626154235.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180626154235.png)


#### 参考资料
- [iOS触摸事件那点儿事](https://blog.gocy.tech/2016/11/19/iOS-touch-handling/)
- [AsyncDisplayKit近一年的使用体会及疑难点](http://qingmo.me/2017/07/21/asyndisplaykit/)

