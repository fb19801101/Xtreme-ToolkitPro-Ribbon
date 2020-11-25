--SQL分析函数
/*
分析函数主要分为四类：
        1.聚合分析函数
        2.排名分析函数
        3.数学分析函数
        4.行比较分析函数

一.聚合分析函数
SUM       ：该函数计算组中表达式的累积和
COUNT   ：对一组内发生的事情进行累积计数
MIN        ：在一个组中的数据窗口中查找表达式的最小值
MAX       ：在一个组中的数据窗口中查找表达式的最大值
AVG        ：用于计算一个组和数据窗口内表达式的平均值。

二.排名分析函数
ROW_NUMBER ：-- 正常排序[1,2,3,4] -- 必须有order_by
RANK                ：-- 跳跃排序[1,2,2,4] -- 必须有order_by
DENSE_RANK   ：-- 密集排序[1,2,2,3] -- 必须有order_by
FIRST                ：从DENSE_RANK返回的集合中取出排在最前面的一个值的行
LAST                 ：从DENSE_RANK返回的集合中取出排在最后面的一个值的行
FIRST_VALUE    ：返回组中数据窗口的第一个值
LAST_VALUE     ：返回组中数据窗口的最后一个值。

三.数学分析函数
STDDEV      ：计算当前行关于组的标准偏离
STDDEV_POP：该函数计算总体标准偏离，并返回总体变量的平方根
STDDEV_SAMP：该函数计算累积样本标准偏离，并返回总体变量的平方根
VAR_POP       ：该函数返回非空集合的总体变量（忽略null）
VAR_SAMP    ：该函数返回非空集合的样本变量（忽略null）
VARIANCE     ：如果表达式中行数为1，则返回0，如果表达式中行数大于1，则返回VAR_SAMP
COVAR_POP   ：返回一对表达式的总体协方差
COVAR_SAMP ：返回一对表达式的样本协方差
CORR        ：返回一对表达式的相关系数
CUME_DIST   ：计算一行在组中的相对位置
NTILE        ：将一个组分为"表达式"的散列表示（类于Hive的分桶原理），NTILE（N）分组函数，把记录强制分成N段
PERCENT_RANK ：和CUME_DIST（累积分配）函数类似
PERCENTILE_DISC ：返回一个与输入的分布百分比值相对应的数据值
PERCENTILE_CONT ：返回一个与输入的分布百分比值相对应的数据值
RATIO_TO_REPORT ：该函数计算expression/(sum(expression))的值，它给出相对于总数的百分比
REGR_ (Linear Regression) Functions ：这些线性回归函数适合最小二乘法回归线，有9个不同的回归函数可使用

四.行比较分析函数
LAG         ：可以访问结果集中的其它行而不用进行自连接      -- 落后 -- lag(xx,1,0)
LEAD      ：LEAD与LAG相反，LEAD3可以访问组中当前行之后的行    -- 领先 -- lead(xx,1,0)
*/
