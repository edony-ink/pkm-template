---
cssclasses:
  - academia
  - academia-rounded
---


## 变更记录
> 记录每次修订的内容，方便追溯。
>

[此处为语雀卡片，点击链接查看](https://yuque.antfin.com/docs/398178936#oGdRB)


| 说明    | 版本     | 作者  | 日期                  |
| ----- | ------ | --- | ------------------- |
| 文档初始化 | v1.0.0 | xxx | 2024-11-12 17:24:31 |
|       |        |     |                     |


## 项目背景
> 对本次项目的背景以及目标进行描述，方便开发者理解需求，对齐上下文。
>

知识库基础能力的升级，解决以下问题：

+ 目录与文档管理分布在不同的页面，用户无法区分两者区别。
+ 目录拖拽体验不够流畅，交互细节体验不佳。

### 相关资料
> PRD、设计稿等相关资料，可以通过插入卡片快速引入关联文档
>
> 也可以通过“本地文件”、“附件”上传其他资料。
>

[📑 产品需求文档](https://example.com/product_demand_analysis_document.txt)

### 参与人
| **项目负责人** | ... |
| --------- | --- |
| **产品经理**  | ... |
| **设计师**   | ... |
| **工程师**   | ... |


## 功能模块
> 通过插入“思维图”卡片、“表格”卡片，描述本项目涉及到的功能与场景。
>

![[Pasted image 20241112173001.png]]

## 流程图
> 通过“流程图”卡片对系统流程进行梳理。
>

![[Pasted image 20241112172948.png]]

## UML 图
> 通过“UML 图”卡片可以绘制类图、组件图等系统架构图，梳理系统架构。
>

![[Pasted image 20241112172858.png]]

## 时序图
> 通过“UML 图”卡片可以绘制时序图来梳理系统调用时序。
>

![[Pasted image 20241112172912.png]]

## 数据库设计
```sql
CREATE TABLE IF NOT EXISTS `tables`
(
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `name`        VARCHAR(16)     NOT NULL COMMENT '名称',
    `type`        VARCHAR(32)     NOT NULL COMMENT '类型',
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET = utf8mb4 COMMENT = '数据表';
```

## API 设计
### 获取单篇文档
```plain
GET /docs/:id?raw=0
```

### 请求参数
| **参数** | **类型** | **描述** |
| --- | --- | --- |
| id | Integer | 文档 id |
| raw | Boolean | raw=1 返回文档最原始的格式 |


### 响应格式
```json
{
  "data": {
    "id": 100,
    "title": "标题",
    "description": "描述",
    "body": "文档正文内容",
    "body_draft": "文档草稿内容",
    "status": 0
  }
}
```

## 排期
> 通过“日历卡片”或者“思维图”卡片的时间轴视图，对研发时间计划进行排期。
>

![[Pasted image 20241112172933.png]]



