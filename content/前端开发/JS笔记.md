# JS笔记

## 变量

```js
//const vs let
const var = 'string';
let var = 'string';

//未初始化的设置为undefined
let whatAmI; // 赋值undefined
const whatAmI; //报错,初始化必须设置值

//拼接字符串
let myPet = 'armadillo';
console.log('I own a pet ' + myPet + '.'); // Output: 'I own a pet armadillo.'

// JavaScript ES6
let myName = 'Samuel';
let myCity = 'GuiLin';
console.log(`My name is ${myName}. My favorite city is ${myCity}`);//Output: My name is Samuel. My favorite city is GuiLin

//console打印
console.log(earlyYears,laterYears);//Output: 21 100

```

## 选择分支

js中用于选择判断的数据都可以判断为true/false

### 1.以下情况被认为是false

- false
- 0 and -0
- "" and '' (empty strings)
- null
- undefined
- NaN (Not a Number)

### 2.`!`用于先判断`false`

### 3.相等 (三个等)

```js
To check if two things equal each other, we write === (three = signs in a row).

To check if two things do not equal each other, we write !== (an exclamation with two = signs in a row).
```

## 函数

```js

//[0,1)之间的数
Math.random() 

let calculatorIsOn = false;
const pressPowerButton = () => {
  if (calculatorIsOn) {
    console.log('Calculator turning off.');
    calculatorIsOn = false;
  } else {
    console.log('Calculator turning on.');
    calculatorIsOn = true;
  }
};
pressPowerButton();
// Output: Calculator turning on.
pressPowerButton();
// Output: Calculator turning off.

//1.多参数
const getAverage = (numberOne, numberTwo) => {
  const average = (numberOne + numberTwo) / 2 ;
  console.log(average);
};
getAverage(365, 27);// Output: 196
//2.返回值
const getSubTotal = (itemCount) => {
  return itemCount * 7.5;
};
//3.使用关键字声明
function square (number) {
  return number * number;
}
console.log(square(5));// Output: 25.
//4.函数表达式(匿名函数,分号结尾)
const square = function (number) {
  return number * number;
};
console.log(square(5));// Output: 25.

//5.箭头函数
//a.只有一个参数,参数的括号可以省略
const getSubTotal = itemCount => {
  return itemCount * 7.5;
};
//b.只有一个参数,返回值只有一句,花括号可以省略
const getSubTotal = itemCount => itemCount * 7.5;
//c.没有参数时,括号不能省略
const getSubTotal = () => itemCount * 7.5;

//6.定时函数: 15s之后退出
const defaultWaitForAppSwitch = step =>
  new Promise(resolve => {
    var s = 15;
    console.info(
      "You have " + s + " seconds to switch to " + step.appName + " app ..."
    );
    var interval = setInterval(() => {
      if (--s) {
        console.log(s + " ...");
      } else {
        clearInterval(interval);
        resolve();
      }
    }, 1000);
  });
```

> 示例代码

```js
const getUserChoice = (userInput) => {
  
  userInput = userInput.toLowerCase();
  
  if(userInput === 'rock' || userInput === 'paper' || userInput === 'scissors' || userInput === 'bomb'){
    return userInput;
  }else{
		console.log("error userChoice");
    return;
  }
};

function getComputerChoice(){
  
 switch(Math.floor(Math.random() * 3)){
   case 0:
   return 'rock';
   break;
   case 1:
   return 'paper';
   break;
   case 2:
   return 'scissors';
   break;
   default:
   return '';
   break; 
 }
}

function determineWinner (userChoice,computerChoice){
 
  if(userChoice === computerChoice ){
    return 'the game was a tie.';
  }else{
   if(userChoice === 'rock'){
   	 if(computerChoice === 'paper'){
				return "the computer won";     
     }else{
     		return "the user won";
     }
   }else if(userChoice === 'paper'){
     if(computerChoice === 'scissors'){
				return "the computer won";     
     }else{
     		return "the user won";
     }
   }else if(userChoice === 'scissors'){
     if(computerChoice === 'rock'){
				return "the computer won";     
     }else{
     		return "the user won";
     }
   }else if(userChoice === 'bomb'){
    	return 'the user won';
   }`
  }
}

function playGame (){
  
  let userChoice = getUserChoice('bomb');
  
  let computerChoice = getComputerChoice();
  
  console.log(`userChoice = ${userChoice}. computerChoice = ${computerChoice}`);
  
  console.log(determineWinner(userChoice,computerChoice));
}

playGame();

```

### 作用域

```js
//全局作用域
const color = 'blue'

const colorOfSky = () => {
  return color; // blue 
};
console.log(colorOfSky()); // blue

//局部作用域
```

### 数组

```js

//1.赋值
let bucketList = ['Rappel into a cave', 'Take a falconry class', 'Learn to juggle'];
console.log(bucketList);

//2.从零开始
let newYearsResolutions = ['Rappel into a cave', 'Take a falconry class', 'Learn to juggle'];
console.log(newYearsResolutions[0]);

let newYearsResolutions = ['123','456','789'];


//access
console.log(newYearsResolutions[2]);
//console.log(newYearsResolutions[3]);
//update
newYearsResolutions[1] = "Learn a new language";
console.log(newYearsResolutions);
//built-in length method
console.log(newYearsResolutions.length);


.join() : console.log(elements.join('-')); // expected output: Fire-Wind-Rain
.slice(): console.log(groceryList.slice(1, 4));//新数组[1,4)的元素,不会改变groceryList的元素
.splice()

var months = ['Jan', 'March', 'April', 'June'];
months.splice(1, 0, 'Feb');
// inserts at 1st index position
console.log(months);
// expected output: Array ['Jan', 'Feb', 'March', 'April', 'June']

months.splice(4, 1, 'May');
// replaces 1 element at 4th index
console.log(months);
// expected output: Array ['Jan', 'Feb', 'March', 'April', 'May']

.shift() //The shift() method removes the first element from an array and returns that removed element. This method changes the length of the array.

.unshift() 
// var array1 = [1, 2, 3]; console.log(array1.unshift(4, 5)); 
// expected output: 5 console.log(array1); // expected output: Array [4, 5, 1, 2, 3]

.concat()
var array1 = ['a', 'b', 'c'];
var array2 = ['d', 'e', 'f'];

console.log(array1.concat(array2));
// expected output: Array ["a", "b", "c", "d", "e", "f"]

```


### 循环

```js
let myPlaces = ['Shenzhen','Guangzhou','Beijing'];

let friendPlaces = ['Xinjiang','Xian','Shenzhen'];

for(let myPlacesIndex = 0;myPlacesIndex < myPlaces.length;myPlacesIndex++){
 for(let friendPlacesIndex = 0;friendPlacesIndex < friendPlaces.length;friendPlacesIndex++){
			if(myPlaces[myPlacesIndex] === friendPlaces[friendPlacesIndex]){         
         console.log(`the place in common ${myPlaces[myPlacesIndex]}`);
     	}
  }

```


### 枚举器(ITERATORS)

```js
1.forEach()

//It is an array method. It must be called upon an array.
//Any changes to the iterated array value won't be updated in the original array.
//The return value is undefined.
let groceries = ['whole wheat flour', 'brown sugar', 'salt', 'cranberries', 'walnuts']; 

groceries.forEach(function(groceryItem) {
  console.log(' - ' + groceryItem);
});

2..map()

.forEach() returns undefined. It also does not change the array it is called upon. 
What if we do want to change the contents of the array? We can use .map()

let numbers = [1, 2, 3, 4, 5]; 

let bigNumbers = numbers.map(function(number) {
  return number * 10;
});

3.filter() 返回一个符合过滤条件的新数组

let randomNumbers = [375, 200, 3.14, 7, 13, 852];
// Call .filter() on randomNumbers below
let smallNumbers = randomNumbers.filter(function(number){
  	return number < 250;
});

```

### JavaScript Object

* Represent real-world objects in JavaScript
* Access object properties
* Access object methods
* Create object getter and setter methods

```js
//括号:好处可以使用变量访问
let restaurant = {
  name: 'Italian Bistro',
  seatingCapacity: 120,
  hasDineInSpecial: true,
  entrees: ['Penne alla Bolognese', 'Chicken Cacciatore', 'Linguine pesto']
};

console.log(restaurant['entrees']);
//点语法
//添加属性,同样使用与添加方法
restaurant['appetizers'] = ['Fried Calamari', 'Bruschetta'];
restaurant.desserts	     = ['Homemade Tiramisu', 'Cannoli'];

//方法
const restaurant = {
  name: 'Italian Bistro',
  seatingCapacity: 120,
  hasDineInSpecial: true,
  entrees: ['Penne alla Bolognese', 'Chicken Cacciatore', 'Linguine pesto'],
  openRestaurant: () => {
    return 'Unlock the door, flip the open sign. We are open for business!';
  },
  closeRestaurant: () => {
    return 'Lock the door, flip the open sign. We are closed.'
  }
};

//ES6 method
const restaurant = {
  name: 'Italian Bistro',
  seatingCapacity: 120,
  hasDineInSpecial: true,
  entrees: ['Penne alla Bolognese', 'Chicken Cacciatore', 'Linguine pesto'],
	
  //直接使用这种方式
  openRestaurant() {
    return 'Unlock the door, flip the open sign. We are open for business!';
  },
  closeRestaurant() {
    return 'Lock the door, flip the open sign. We are closed.'
  }
  
//this关键字
const restaurant = {
  name: 'Italian Bistro',
  seatingCapacity: 120,
  hasDineInSpecial: true,
  entrees: ['Penne alla Bolognese', 'Chicken Cacciatore', 'Linguine pesto'],
  openRestaurant() { //如果使用arrow函数语法,出错...不清楚是否是codeCademy的问题
    if (this.hasDineInSpecial) {
      return 'Unlock the door, post the special on the board, then flip the open sign.';
    } else {
      return 'Unlock the door, then flip the open sign.';
    }
  }
};

console.log(restaurant.openRestaurant());  
  
//函数指针赋值
const friend = {
  name : 'Tim',
}

friend.sayHello = person.sayHello;
console.log(friend.sayHello());

//setter,getter
//js中没有私有变量的概念,即使这样写,要想直接访问_name也是可以的,但是这里我们是约定如果是这样那就不能直接赋值
//需要自定义setter,getter
let restaurant = {
  _name: 'Italian Bistro',
  _seatingCapacity: 120,
  _hasDineInSpecial: true,
  _entrees: ['Penne alla Bolognese', 'Chicken Cacciatore', 'Linguine pesto'],

  set seatingCapacity(newCapacity) {
    if (typeof newCapacity === 'number') {
      this._seatingCapacity = newCapacity;
    } else {
      console.log(`Change ${newCapacity} to a number.`)
    }
  },

  get seatingCapacity() {
    console.log(`There are ${this._seatingCapacity} seats at Italian Bistro.`);
    return this._seatingCapacity;
  }
}

```

### Class

```js
//语法
//Class method and getter syntax is the same as it is for objects 
//except you can not include commas between methods.
//方法之间不能使用冒号
class Dog {
  constructor(name) {
  	//构造体constructor() method every time it creates a new instance of a class.
    this._name = name;
    this._behavior = 0;
  }

  get name() {
    return this._name;
  }
  get behavior() {
    return this._behavior;
  }   

  incrementBehavior() {
    this._behavior ++;
  }
}

const halley = new Dog('Halley');//new新建账号

console.log(halley.name); 	     // Halley
console.log(halley.behavior);    // 0
halley.incrementBehavior();      // Add one to behavior
console.log(halley.name); 		 // Halley
console.log(halley.behavior);    // 1

//继承
class Cat extends Animal {
  constructor(name, usesLitter) {
    super(name);//super关键字
    this._usesLitter = usesLitter;
  }
}


//静态方法(类方法)
class Animal {
  constructor(name) {
    this._name = name;
    this._behavior = 0;
  }

  static generateName() {
    const names = ['Angel', 'Spike', 'Buffy', 'Willow', 'Tara'];
    const randomNumber = Math.floor(Math.random()*5);
    return names[randomNumber];
  }
}

```


### 浏览器兼容性

- security vulnerabilities
- adding features
- supporting new HTML, CSS, and JavaScript syntax

[Babel:自动转换语法](https://babeljs.io)

[caniuse:浏览器支持情况](https://caniuse.com/#search=ES6)

**<font size = 6>Install Node Packages</font size>**

Before we install Babel, we need to setup our project to use the node package manager (npm). 

Developers use npm to access and manage Node packages. Node packages are directories that contain JavaScript code written by other developers. You can use these packages to reduce duplication of work and avoid bugs.

```js

//1.The npm init command creates a package.json file in the root directory.
> npm init

Metadata — This includes a project title, description, authors, and more.

A list of node packages required for the project — If another developer wants to run your project, npm looks inside package.json and downloads the packages in this list.

Key-value pairs for command line scripts — You can use npm to run these shorthand scripts to perform some process. In a later exercise, we will add a script that runs Babel and transpiles ES6 to ES5.

//2. The install command creates a folder called node_modules and copies the package files to it.
// The install command also installs all of the dependencies for the given package
> npm install xxx

$ npm install babel-cli -D
$ npm install babel-preset-env -D
The -D flag writes babel-cli to the devDependencies property.
The -D flag instructs npm to add each package to a property called devDependencies in package.json. Once the 
project's dependencies are listed in devDependencies, other developers can run your project without installing each
package separately. Instead, they can simply run npm install — it instructs npm to look inside package.json and 
download all of the packages listed in devDependencies.

project
|_ node_modules
|___ .bin
|___ ...
|_ src
|___ main.js
|_ package.json


//3. Create a .babelrc file inside your project and add the following code inside it:
{
  "presets": ["env"]
}

//4. Add the following script to your scripts object in package.json:
"build": "babel src -d lib"

//5.Run npm run build whenever you want to transpile your code from your src to lib directories
npm run build

```

### 模块

- 定位,调试,修复bug更加容易
- 在不同的地方重用代码
- 对其他模块保持信息隐私和保护
- 命名空间冲突**(importantly, prevent pollution of the global namespace and potential naming collisions, by cautiously selecting variables and behavior we load into a program.)**

```js
//1.1 module.export
//menu.js
let Menu = {};
Menu.myAirplane = "StarJet";
Menu.name = "sdfsdfsdfsfsfsdf";
Menu.function = (age) => age+3;
Menu.specialty = "Spicy";
console.log(Menu);             //{ myAirplane: 'StarJet',name: 'sdfsdfsdfsfsfsdf',function: [Function] }
console.log(Menu.function(27));//30

module.exports = Airplane;

//1.2 require()导入module
const Menu = require('./menu.js');
function placeOrder() {
  console.log('My order is: ' + Menu.specialty);
}
placeOrder();

//2.ES6语法 export && import
//export default
//xxxxxxx.js
let Airplane = {
  availableAirplanes : [{
    name:'AeroJet',
    fuelCapacity:800
  },{
    name:'SkyJet',
    fuelCapacity:500
  }]
};


//a. export default每个文件只能到处一个module
export default Airplane;//allowing us to export one module per file.

export default async transport => {
  const eth = new Eth(transport);
  const result = await eth.getAppConfiguration();
  return result;
};
//b. export default输出一个叫做default的变量，然后系统允许你为它取任意名字。所以可以为import的模块起任何变量名，且不需要用大括号包含
import any from "./xxxxxxx.js"


3. export && import
let specialty = '';
//JavaScript, every function is in fact a function object.这就是为什么用";"来结束?
function isVegetarian() {
}; 
function isLowSodium() {
}; 

//a. export
export { specialty, isVegetarian };
//b. export as
export { specialty as chefsSpecial, isVegetarian as isVeg, isLowSodium };
//c. export name
export let specialty = '';

import { specialty, isVegetarian } from './menu';

##################################
//import隐藏后缀
import Menu from './menu';
import Airplane from './airplane';
```

### HTTP Request

[Concurrency model and Event Loop](https://developer.mozilla.org/en-US/docs/Web/JavaScript/EventLoop)

JavaScript uses an event loop to handle asynchronous function calls. When a program is run, function calls are made and added to a stack. The functions that make requests that need to wait for servers to respond then get sent to a separate queue. Once the stack has cleared, then the functions in the queue are executed.


Asynchronous JavaScript and XML (AJAX), enables requests to be made after the initial page load. Initially, AJAX was used only for XML formatted data, now it can be used to make requests that have many different formats.

```js

const xhr = new XMLHttpRequest();
const url = 'https://api-to-call.com/endpoint';
//JSON is JavaScript Object Notation, which is how the response is going to be formatted.
xhr.responseType = 'json';
xhr.onreadystatechange = () => {
  if (xhr.readyState === XMLHttpRequest.DONE){
    return xhr.response;
  }
}
//.open() creates a new request and the arguments passed in determine the type and URL of the request.
xhr.open('GET', url);
//On the following line, call the .send() method on the xhr object. Do not pass it any arguments.
xhr.send();


################################################################
// Information to reach API
const url = 'https://api.datamuse.com/words?';
const queryParams = 'rel_rhy=';

// Selecting page elements
const inputField = document.querySelector('#input');
const submit = document.querySelector('#submit');
const responseField = document.querySelector('#responseField');

// AJAX function
const getSuggestions = () => {
	const wordQuery = inputField.value;
  
  const endpoint = url + queryParams + wordQuery;
  const xhr = new XMLHttpRequest();
  xhr.responseType = 'json';
  xhr.onreadystatechange = () => {
  // Event handler code
    	if (xhr.readyState === XMLHttpRequest.DONE) {
 				 renderResponse(xhr.response) 
		}
	}
  
  xhr.open('GET',endpoint);
  xhr.send();
  
}

// Clear previous results and display results to webpage
const displaySuggestions = (event) => {
  event.preventDefault();
  while(responseField.firstChild){
    responseField.removeChild(responseField.firstChild);
  };
  getSuggestions();
}

submit.addEventListener('click', displaySuggestions);
```

![SamuelChan/20180822145744.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180822145744.png)

POST

```js
// AJAX functions
const shortenUrl = () => {
  const urlToShorten = inputField.value;
  const data = JSON.stringify({destination: urlToShorten});

  const xhr = new XMLHttpRequest();
  xhr.responseType = 'json';

  xhr.onreadystatechange = () => {
    if (xhr.readyState === XMLHttpRequest.DONE) {
      renderByteResponse(xhr.response);
    }
  };
  xhr.open('POST', rebrandlyUrl);
  xhr.setRequestHeader('Content-type', 'application/json');
	xhr.setRequestHeader('apikey', apiKey);
  xhr.send(data);
}
```


**<font size = 4>To make asynchronous event handling easier, promises were introduced in JavaScript in ES6:</font szie>**

A promise is an object that handles asynchronous data. A promise has three states:

- pending : when a promise is created or waiting for data.
- fulfilled : the asynchronous operation was handled successfully.
- rejected : the asynchronous operation was unsuccessful.

![SamuelChan/20180822153541.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180822153541.png)

```js
fetch('https://api-to-call.com/endpoint').then(response =>{
  
  if (response.ok) {
 	  return response.json();
  }
  // Conditional statement for `response.ok`
  throw new Error('Request failed!');
}, networkError => {
  console.log(networkError.message);
  //The second .then()'s success callback won’t run until the previous .then() method has finished running.
  //It will also not run if there was an error was thrown previously.
}).then(jsonResponse => {
  return jsonResponse;
});

```

![SamuelChan/20180822162654.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180822162654.png)

```js
fetch('https://api-to-call.com/endpoint',{
  
  method:'POST',
  body:JSON.stringify({id: '200'}),
}).then(response =>{
  if(response.ok) {
  	return response.json();
	}
  throw new Error('Request failed!');
},networkError => {
  console.log(networkError.message);
}).then(jsonResponse => {
  return jsonResponse;
});
```


**<font size = 5>ES8: async and await</font size>**
![SamuelChan/20180822165222.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180822165222.png)

```js
Promise.prototype.then():then() 方法返回一个  Promise 。它最多需要有两个参数：Promise 的成功和失败情况的回调函数。
//语法
p.then(onFulfilled, onRejected);

p.then(function(value) {
   // fulfillment
  }, function(reason) {
  // rejection
});
###############
let p1 = new Promise(function(resolve, reject) {
//  resolve("Success!");
  // or
  reject ("Error!");
});

p1.then(function(value) {
  console.log(value); // Success!
}, function(reason) {
  console.log(reason); // Error!
});


```




### HTML DOM

**通过 HTML DOM，可访问 JavaScript HTML 文档的所有元素。**

当网页被加载时，浏览器会创建页面的文档对象模型（Document Object Model）。
HTML DOM 模型被构造为对象的树。
![](http://www.w3school.com.cn/i/ct_htmltree.gif)

通过可编程的对象模型，JavaScript 获得了足够的能力来创建动态的 HTML。

- JavaScript 能够改变页面中的所有 HTML 元素
- JavaScript 能够改变页面中的所有 HTML 属性
- JavaScript 能够改变页面中的所有 CSS 样式
- JavaScript 能够对页面中的所有事件做出反应

```js
//通过 id 查找 HTML 元素
var x=document.getElementById("intro");

//通过标签名查找 HTML 元素
var x=document.getElementById("main");
var y=x.getElementsByTagName("p");

//1.document.write, 2.x.innerHTML
x=document.getElementById("intro");
document.write('<p>id="intro" 的段落中的文本是：' + x.innerHTML + '</p>');


//DOM HTML
//内容
document.getElementById(id).innerHTML=new HTML
//属性
document.getElementById(id).attribute=new value


//DOM CSS
<p id="p2">Hello World!</p>
<script>
document.getElementById("p2").style.color="blue";
</script>

//DOM事件
HTML 事件的例子：
- 当用户点击鼠标时
- 当网页已加载时
- 当图像已加载时
- 当鼠标移动到元素上时
- 当输入字段被改变时
- 当提交 HTML 表单时
- 当用户触发按键时


//在本例中，当用户在 <h1> 元素上点击时，会改变其内容：
<h1 onclick="this.innerHTML='谢谢!'">请点击该文本</h1>
//本例从事件处理器调用一个函数：
<!DOCTYPE html>
<html>
<head>
<script>
function changetext(id)
{
id.innerHTML="谢谢!";
}
</script>
</head>
<body>
<h1 onclick="changetext(this)">请点击该文本</h1>
</body>
</html>

//如需向 HTML 元素分配 事件，您可以使用事件属性。
<button onclick="displayDate()">点击这里</button>


//HTML DOM 允许您通过使用 JavaScript 来向 HTML 元素分配事件：
<script>
document.getElementById("myBtn").onclick=function(){displayDate()};
function displayDate()
{
document.getElementById("demo").innerHTML=Date();
}
</script>


//onload 和 onunload 事件会在用户进入或离开页面时被触发。
//onload 事件可用于检测访问者的浏览器类型和浏览器版本，并基于这些信息来加载网页的正确版本。
//onload 和 onunload 事件可用于处理 cookie。
<body onload="checkCookies()">
<script>
function checkCookies()
{
if (navigator.cookieEnabled==true)
	{
	alert("已启用 cookie")
	}
else
	{
	alert("未启用 cookie")
	}
}
</script>
<p>提示框会告诉你，浏览器是否已启用 cookie。</p>
</body>

//onchange 事件常结合对输入字段的验证来使用。
<input type="text" id="fname" onchange="upperCase()">


//onmouseover 和 onmouseout 事件
onmouseover 和 onmouseout 事件可用于在用户的鼠标移至 HTML 元素上方或移出元素时触发函数。
<div onmouseover="mOver(this)" onmouseout="mOut(this)" style="background-color:green;width:120px;height:20px;padding:40px;color:#ffffff;">把鼠标移到上面</div>
<script>
function mOver(obj)
{
obj.innerHTML="谢谢"
}

function mOut(obj)
{
obj.innerHTML="把鼠标移到上面"
}
</script>


//onmousedown, onmouseup 以及 onclick 构成了鼠标点击事件的所有部分。首先当点击鼠标按钮时，会触发 onmousedown 事件，当释放鼠标按钮时，会触发 onmouseup 事件，最后，当完成鼠标点击时，会触发 onclick 事件。




//添加和删除节点（HTML 元素）。
<div id="div1">
<p id="p1">这是一个段落。</p>
<p id="p2">这是另一个段落。</p>
</div>

<script>
var para=document.createElement("p");
var node=document.createTextNode("这是新段落。");
para.appendChild(node);

var element=document.getElementById("div1");
element.appendChild(para);
</script>

//删除已有的 HTML 元素
<script>
var parent=document.getElementById("div1");
var child=document.getElementById("p1");
parent.removeChild(child);
</script>
```


### JS window
**浏览器对象模型 (BOM) 使 JavaScript 有能力与浏览器“对话”。**

- 所有浏览器都支持 window 对象。它表示浏览器窗口。

- 所有 JavaScript 全局对象、函数以及变量均自动成为 window 对象的成员。

- 全局变量是 window 对象的属性。

- 全局函数是 window 对象的方法。

window.document.getElementById("header");
document.getElementById("header");

```js
var w=window.innerWidth
|| document.documentElement.clientWidth
|| document.body.clientWidth;

var h=window.innerHeight
|| document.documentElement.clientHeight
|| document.body.clientHeight;


window.open() - 打开新窗口
window.close() - 关闭当前窗口
window.moveTo() - 移动当前窗口
window.resizeTo() - 调整当前窗口的尺寸


//window.screen 对象包含有关用户屏幕的信息。
screen.availWidth - 可用的屏幕宽度
screen.availHeight - 可用的屏幕高度


```


## JS调试

1. Google Chrome
	- 打开Chrome开发者工具；
	- 点击进入Sources标签页，在页面的左侧就能看到JS代码的目录；
	- 找到需要设置断点的源文件，在需要中断的哪行代码左侧单击鼠标左键，就可以设置断点，如果你的代码是uglify过的，则需导入相应的source-map来映射源码。
	- 刷新页面（如果设置断点的位置是一个事件处理函数，则直接触发这个事件即可），代码运行到断点处的时候，程序就会挂起，这时候用鼠标hover就可以查看当前各个变量的数值，并以此判断程序是否正常运行了。

2. VSCode

	![SamuelChan/20181023142116.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181023142116.png)
	>其中最重要的配置项就是“Program”字段，这个字段定义了整个应用的入口，开启调试器的时候会从这个入口启动应用。
	![SamuelChan/20181023142138.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181023142138.png)
	
	
**存在依赖的时候怎么办?**
	

## 参考资料

[让node支持es模块化(export、import)的方法](https://www.cnblogs.com/cag2050/p/7567248.html)

[ruimarinho/bitcoin-core](https://github.com/ruimarinho/bitcoin-core)


[Node.js 命令行程序是如何工作的](https://egoist.moe/2017/10/18/how-does-nodejs-cli-program-work/)

[npm scripts 使用指南](http://www.ruanyifeng.com/blog/2016/10/npm_scripts.html)

[Babel command not found](https://stackoverflow.com/questions/34421513/babel-command-not-found)

[测试框架 Mocha 实例教程](http://www.ruanyifeng.com/blog/2015/12/a-mocha-tutorial-of-examples.html)
