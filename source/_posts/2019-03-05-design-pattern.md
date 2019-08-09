---
layout: post
title: "Design pattern"
date: 2019-03-05 Tue 10:28 PM
categories: soft design
---
当我们学习一门新的技术或方法的时候，一定要弄清楚这技术是为了解决什么具体的问题。
这么做之后有什么好处。

### 观察者模式
日常开发过程中，经常会遇到如下的场景：  
当用户登录成功时，给用户发送消息推送。当某笔账单回款100%时，执行某些特定的业务逻辑，比如给用户账户加钱或是通知其它模块。
一般来讲，我们实现时会直接采用如下的过程式编码：
```
...
$res = Login();
if ($res) {
    notify();
}
if ($condition) {
    //do something
}
```
当需要推送的类型越来越多，代码越加越多，时间久了会越来越难维护。  
这个时候，为了分离单一职责，让特定的类负责特定的功能。采用**观察者模式**可以很好地解决这个问题。

观察者模式的核心是把客户元素（观察者）从一个中心类（主体）中分离开来。当主体知道事件发生时，观察者需要被通知。同时，我们希望主体与观察者之间的关系没有硬编码。

```
class Login implements Observable {
    private $observers;
    //...
    function __construct() {
        $this->observers = array();
    }

    function attach(Observer $observer) {
        $this->observers[] = $observer;
    }

    function detach(Observer $observer){
        $newobservers = array();
        foreach($this->observers as $obs) {
            if($obs !== $observer) {
                $newobservers[] = $obs;
            }
        }
        $this->observers = $newobservers;
    }

    function notify() {
        foreach($this->observers as $obs) {
            $obs->update($this);
        }
    }
}
```
未完待续...

