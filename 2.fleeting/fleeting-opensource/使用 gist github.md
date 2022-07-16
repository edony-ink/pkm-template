---
title: 使用 gist github
date: 2022-02-06 16:52:28
modify: 2022-02-06 16:52:28
author: edony.zpc
tags: 001-computer-technology
aliases: gist
---

# 使用 gist github
## 地址
https://gist.github.com/

## 特点
1. 匿名张贴

	您不需要拥有Github账号就可以使用Gist。用浏览器打开http://gist.github.com，在窗口中写下你想说的就可以创建一个Gist。您可以发布一个私密的Gist，也就是说这个Gist将不能被他人搜索到而只对直接在浏览器中输入其URL的人可见。

2. 能像wiki一样记录历史

	如果您修改了已经发布了的Gist的话，之前的所有版本都将被保存。您可以点击Revisions按钮按时间浏览，而且您可以通过内置的diff引擎查看任意两个版本间的差异。 这也可以用于比较文本文件。

3. 发布富文本内容

	虽然Gist只能用纯文本来写，但是您可以用markdown来发布html格式的Gist。您可以添加列表、图片（已有图床上的）和表格。当您用markdown的时候不要忘了文件名要以.md为后缀。

4. 把Gist当作一个写作平台

	虽然现在有很多写作引擎，比如Blogger、Medium、Tumblr，但您还可以用Gist来快速发布您的作品。您可以用纯文本或者markdown等文档标记语言些一个Gist然后用http://roughdraft.io来把它作为一个独立的网页发布。

5. 托管gist上的单个页面

	Bl.ocks 是一个非常有趣的专为Gist开发的应用。

	您可以用纯文本把HTML、CSS、JavaScript代码写下来以index.html为文件名保存为Gist，然后用http://bl.ocks.org把渲染好的结果在浏览器中展示出来。比如，这个gist展示出来就是这样。

	显然宽带限制是一个问题，但是http://bl.ock.org作为一个通过Gist托管HTML的工具仍然是相当不错的。 当然您也可以用Google Drive。

6. 制作任务列表

	您可以用Gist跟踪待处理任务（举个栗子）。这是用纯文本的特殊语法写的但是你可以任意勾选。

	- [x] Pick the flowers
	- [ ] Call John 9303032332
	- [x] Cancel cable subscription
	- [ ] Book the flight tickets

	您可以勾选或者勾去任意选项，源文本将会自动变更。如果您的Gist是公有的的话，任何人都可以看到您的列表，但是只有您（拥有者）可以改变其勾选状态。

	备注：其实任务列表也可以在issue中建立，所有拥有写权限的人都可以uncheck/check。

7. 把Gist作为一个网页收藏夹

	在Chrome浏览器您可以找到一个叫GistBox的插件，通过这个插件您可以在浏览网页时选择保存网页内容为Gist。您甚至可以添加标注或者话题标签以易于以后更容易找到它们。

8. 把Gist嵌入网页中

	您用一行js代码就可以把任何一条Gist嵌入到网页中。嵌入的Gist格式不发生任何变化，而且访问者可以非常方便的把它们fork到他们的Github中。要嵌入wordpress的话有这个插件和这个短代码可以使用。

9. 测量访问量

	您可以使用Google Analytics查看您的Gist的访问量。因为Gist纯文本中不允许运行js代码，所以我们可以用GA Beacon来记录实时访问Gist的情况。
	把如下代码添加到Gist中，用markdown格式保存，这样就在这个Gist中添加了一个透明追踪图像了。
![Analytics](https://ga-beacon.appspot.com/UA-XXXXX-X/gist-id?pixel)

10. 在桌面端管理Gist

	Gisto是一个能让您在浏览器之外管理Gist的桌面应用。您可以对Gist进行搜索、编辑、查看历史和分享。 此应用可运行于苹果、微软和linux系统。 当然您也可以用GistBox这个web应用替代它。


## References
1. [GitHub Gist 指南](https://gist.github.com/zhixingchou/edfade09eb64c0d2c2ee)