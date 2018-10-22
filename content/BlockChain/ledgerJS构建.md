# LedgerJS构建

> 
##Install dependencies

	yarn


##Build

Build all packages

	yarn build

##Watch

Watch all packages change. Very useful during development to build only file that changes.

	yarn watch

##Lint

Lint all packages

	yarn lint

##Run Tests

First of all, this ensure the libraries are correctly building, and passing lint and flow:

	yarn test

then to test on a real device...

Plug a device like the Nano S and open Bitcoin app.

Then run the test and accept the commands on the devices for the tests to continue.

	yarn test-node

You can also test on the web:

	yarn test-browser
>make sure to configure your device app with "Browser support" set to "YES".


# 问题:
- upath错误 : 升级upath, 修改upath为1.0.5
- fsevents failed : yarn upgrade
- 'key' undefine : 删掉expample-browser
- regeneratorRuntime is not defined
	
	```shell
	npm i --save-dev babel-plugin-transform-runtime
	//.babelc : 
	{
	  .....
	  "plugins": ["transform-runtime"] //添加这行
	}
	```

