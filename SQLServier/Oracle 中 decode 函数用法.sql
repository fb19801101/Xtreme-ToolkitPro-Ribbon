Oracle 中 decode 函数用法
含义解释：decode(条件,值1,返回值1,值2,返回值2,...值n,返回值n,缺省值)
该函数的含义如下：IF 条件=值1 THEN　　　　RETURN(翻译值1)ELSIF 条件=值2 THEN　　　　RETURN(翻译值2)　　　　......ELSIF 条件=值n THEN　　　　RETURN(翻译值n) ELSE RETURN(缺省值) END IFdecode(字段或字段的运算，值1，值2，值3）
这个函数运行的结果是，当字段或字段的运算的值等于值1时，该函数返回值2，否则返回值3当然值1，值2，值3也可以是表达式，这个函数使得某些sql语句简单了许多

--1、比较大小
/*取较小值sign()函数根据某个值是0、正数还是负数，分别返回0、1、-1
例如：变量1=10，变量2=20则sign(变量1-变量2)返回-1，
decode解码结果为“变量1”，达到了取较小值的目的.
*/
select decode(sign(变量1-变量2),-1,变量1,变量2) from dual

--2、此函数用在SQL语句中，功能介绍如下：
/* Decode函数与一系列嵌套的 IF-THEN-ELSE语句相似。
base_exp与compare1,compare2等等依次进行比较。
如果base_exp和 第i个compare项匹配，就返回第i个对应的value。
如果base_exp与任何的compare值都不匹配，则返回default。
每个compare值顺次求值，如果发现一个匹配，则剩下的compare值（如果还有的话）就都不再求值。
一个为NULL的base_exp被认为和NULL compare值等价。
如果需要的话，每一个compare值都被转换成和第一个compare 值相同的数据类型，
这个数据类型也是返回值的类型。
Decode函数在实际开发中非常的有用结合Lpad函数，如何使主键的值自动加1并在前面补0select 
*/
LPAD(decode(count(记录编号),0,1,max(to_number(记录编号)+1)),14,'0') 记录编号 from tetdmis
END


1.比较大小函数SIGN
sign(x)或者Sign(x)叫做符号函数，其功能是取某个数的符号（正或负）：
当x>0，sign(x)=1;
当x=0，sign(x)=0;
当x<0， sign(x)=-1；
x可以是函数或计算表达式
 
2.流程控制函数DECODE
在逻辑编程中，经常用到If – Then –Else 进行逻辑判断。在DECODE的语法中，实际上就是这样的逻辑处理过程。它的语法如下：
DECODE(value, if1, then1, if2,then2, if3,then3, . . . else )
Value 代表某个表的任何类型的任意列或一个通过计算所得的任何结果。当每个value值被测试，如果value的值为if1，Decode 函数的结果是then1；如果value等于if2，Decode函数结果是then2；等等。事实上，可以给出多个if/then 配对。如果value结果不等于给出的任何配对时，Decode 结果就返回else 。 这里的if、then及else 都可以是函数或计算表达式。
