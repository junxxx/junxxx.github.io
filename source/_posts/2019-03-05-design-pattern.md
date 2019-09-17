---
layout: post
title: "Design pattern"
date: 2019-03-05 Tue 10:28 PM
categories: soft design
---

学习系统的最好方式就是做出一个系统。

学习设计模式也是，最佳实践便是写代码，多写代码，再多写代码。
当代码量达到一定程度的时候，便会有优化的需求，这个时候站在前人的肩膀上，使用设计模式便可以写出优雅的代码。

设计模式，是程序员们在多年的实践中总结出来的解决特定问题的优秀实现方案。是一种可以低耦合，高内聚的代码组织形式。

### 单例模式
单例类似全局变量，在整个系统的生命周期内只有一个实例。
 
单例的代码实现非常简单：
1. 类的构造方法为私有，即不允许其它调用的地方实例化，以保证‘单例’的全局唯一。
1. 一个私有的静态变量。
1. 一个可供外部调用获取实例的公有方法。

在web开发中，最常见的使用场景便是数据库连接。
```
class Singleton {
    private static $instance;
    private function __construct() {}

    public static function getInstance() {
        if (empty(self::$instance)) {
            self::$instance = new static();
        }
        return self::$instance;
    }
}
```

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
