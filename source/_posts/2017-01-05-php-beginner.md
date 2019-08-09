---
title: PHP成长笔记
layout: post
date: 2017-01-05
categories: php notes
---

## PHP的成长记录
1 `file_put_contents` + `print_r($params,true)`
<pre>$filename;
file_put_contents($filename,print_r($varable,*true*).PHP_EOL,FILE_APPEND);</pre>

2 json_decode() 默认解析出来的是object，加上参数json_decode($json_str,true)则可解析为数组array;

3 array_shift 删除数组中的第一个元素，并返回被删除的元素的值。相当于出栈。

4 设置错误显示

<code>
error_reporting(E_ALL);
ini_set('display_errors',TRUE);
</code>

设置PHP执行超时时间

<code>ini_set('max_execution_time','30');</code>

0秒为没有时间限制。

5 获取数组中个元素。
> * current() 函数返回当前被内部指针指向的数组单元的值，并不移动指针。
> * end() 将数组的内部指针指向最后一个单元
> * key() 从关联数组中取得键名
> * each() 返回数组中当前的键／值对并将数组指针向前移动一步
> * prev() 将数组的内部指针倒回一位
> * reset() 将数组的内部指针指向第一个单元
> * next() 将数组中的内部指针向前移动一位

6 array_key_exist($key,$array)--查数组里是否有指定的键名或索引;
array_shift($array)--返回移出的值;

7 POST提交表单，$_POST取不到任何值。解决思路,查看php.ini配置 enable_post_data_reading 是否开启，post_max_size设置是否过小。

8 php.ini include_path = ".:path/to/class/"。包含之后，php可以直接引用。
