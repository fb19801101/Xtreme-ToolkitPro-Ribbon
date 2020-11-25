/*
* C++ implementation of the ICE encryption algorithm.
*
* Written by Matthew Kwan - July 1996
*/

#include "stdafx.h"
#include "des.h"

//初始置换表
const static unsigned char ip_table[64] = {
	58, 50, 42, 34, 26, 18, 10, 2, 60, 52, 44, 36, 28, 20, 12, 4,
	62, 54, 46, 38, 30, 22, 14, 6, 64, 56, 48, 40, 32, 24, 16, 8,
	57, 49, 41, 33, 25, 17, 9, 1, 59, 51, 43, 35, 27, 19, 11, 3,
	61, 53, 45, 37, 29, 21, 13, 5, 63, 55, 47, 39, 31, 23, 15, 7
};

//扩展置换，将数据从32位扩展为48位
static const unsigned char expa_perm[48] = {
	32, 1, 2, 3, 4, 5, 4, 5, 6, 7, 8, 9, 8, 9, 10, 11,
	12, 13, 12, 13, 14, 15, 16, 17, 16, 17, 18, 19, 20, 21, 20, 21,
	22, 23, 24, 25, 24, 25, 26, 27, 28, 29, 28, 29, 30, 31, 32, 1
};

//S盒子代替
const static unsigned char sbox[8][64]={
	{//S1盒子
		14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7,
		0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8,
		4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0,
		15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13
	},
	{//S2盒子
		15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10,
		3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5,
		0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15,
		13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9
	},
	{//S3盒子
		10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8,
		13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1,
		13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7,
		1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12
	},
	{//S4盒子
		7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15,
		13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9,
		10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4,
		3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14
	},
	{//S5盒子
		2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9,
		14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6,
		4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14,
		11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3
	},
	{//S6盒子
		12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11,
		10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8,
		9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6,
		4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13
	},
	{//S7盒子
		4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1,
		13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6,
		1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2,
		6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12
	},
	{//S8盒子
		13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7,
		1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2,
		7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8,
		2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11
	}
};

//P盒置换
const static unsigned char p_table[32] = {
	16, 7, 20, 21, 29, 12, 28, 17, 1, 15, 23, 26, 5, 18, 31, 10,
	2, 8, 24, 14, 32, 27, 3, 9, 19, 13, 30, 6, 22, 11, 4, 25
};

//末置换
const static unsigned char ipr_table[64] = {
	40, 8, 48, 16, 56, 24, 64, 32, 39, 7, 47, 15, 55, 23, 63, 31,
	38, 6, 46, 14, 54, 22, 62, 30, 37, 5, 45, 13, 53, 21, 61, 29,
	36, 4, 44, 12, 52, 20, 60, 28, 35, 3, 43, 11, 51, 19, 59, 27,
	34, 2, 42, 10, 50, 18, 58, 26, 33, 1, 41, 9, 49, 17, 57, 25
};

//将数据块初始置换为左右两个部分
int ip(const Block & block, HBlock & left, HBlock & right)
{
	for(size_t i = 0 ; i < right.size() ; ++i)
		right[i] = block[ip_table[i] - 1] ;//获取置换后的右半部分
	for(size_t i = 0 ; i < left.size() ; ++i)
		left[i] = block[ip_table[i + left.size()] - 1] ;//获取置换后的左半部分
	return 0 ;
}

//一轮加解密运算，不带交换
int des_turn(HBlock & left, HBlock & right, const Code & subkey)
{
	Code code ;//48位数据块
	HBlock pcode ;//32位数据块
	//将右半部分扩展为48位
	for(size_t i = 0 ; i < code.size() ; ++i)
		code[i] = right[expa_perm[i] - 1] ;//扩展置换
	code ^= subkey ;//与子密钥异或
	//S盒代替
	std::bitset<4> col ;//S盒的列
	std::bitset<2> row ;//S盒的行
	for(size_t i = 0 ; i < 8 ; ++i)
	{//8个盒子
		row[0] = code[6 * i] ;//获取行标
		row[1] = code[6 * i + 5] ;
		col[0] = code[6 * i + 1] ;//获取列标
		col[1] = code[6 * i + 2] ;
		col[2] = code[6 * i + 3] ;
		col[4] = code[6 * i + 4] ;
		std::bitset<4> temp(sbox[i][row.to_ulong() * 16 + col.to_ulong()]) ;
		for(size_t j = 0 ; j < temp.size() ; ++j)
			code[4 * i + j] = temp[j] ;//将32位暂存于48位中
	}
	for(size_t i = 0 ; i < pcode.size() ; ++i)
		pcode[i] = code[p_table[i] - 1] ;//P盒置换
	left ^= pcode ;//异或
	return 0 ;
}

//交换左右两个部分
int exchange(HBlock & left, HBlock & right)
{
	HBlock temp ;
	for(size_t i = 0 ; i < temp.size() ; ++i)
		temp[i] = left[i] ;
	for(size_t i = 0 ; i < left.size() ; ++i)
		left[i] = right[i] ;
	for(size_t i = 0 ; i < right.size() ; ++i)
		right[i] = temp[i] ;
	return 0 ;
}

//将左右两部分数据进行末置换形成一个数据块
int rip(const HBlock & left, const HBlock & right, Block & block)
{
	for(size_t i = 0 ; i < block.size() ; ++i)
	{
		if(ipr_table[i] <= 32)
			block[i] = right[ipr_table[i] - 1] ;//从right部分获取数据
		else
			block[i] = left[ipr_table[i] - 32 - 1] ;//从left部分获取数据
	}
	return 0 ;
}

//密钥置换表，将64位密钥置换压缩置换为56位
const static unsigned char key_table[56] = {
	57, 49, 41, 33, 25, 17, 9, 1,
	58, 50, 42, 34, 26, 18, 10, 2,
	59, 51, 43, 35, 27, 19, 11, 3,
	60, 52, 44, 36, 63, 55, 47, 39,
	31, 23, 15, 7, 62, 54, 46, 38,
	30, 22, 14, 6, 61, 53, 45, 37,
	29, 21, 13, 5, 28, 20, 12, 4
};

//每轮移动的位数
const static unsigned char bit_shift[16] = {1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1};

//压缩置换表，56位密钥压缩位48位密钥
const static unsigned char comp_perm[48] = {
	14, 17, 11, 24, 1, 5, 3, 28,
	15, 6, 21, 10, 23, 19, 12, 4,
	26, 8, 16, 7, 27, 20, 13, 2,
	41, 52, 31, 37, 47, 55, 30, 40,
	51, 45, 33, 48, 44, 49, 39, 56,
	34, 53, 46, 42, 50, 36, 29, 32
};

//获取bkey产生的第n轮子密钥
Code getkey(const unsigned int n, const Block & bkey)
{//n在区间[0,15]之间取值，bkey为64位密钥
	Code result ;//返回值,48位子密钥
	Key key ;//56位密钥
	unsigned int klen = key.size(), rlen = result.size() ;//分别为56和48
	//获取56位密钥
	for(size_t i = 0 ; i < key.size() ; ++i)
		key[i] = bkey[key_table[i] - 1] ;//密钥置换
	for(size_t i = 0 ; i <= n ; ++i)
	{//循环移位
		for(size_t j = 0 ; j < bit_shift[i] ; ++j)
		{
			//将密钥循环位暂存在result中
			result[rlen - bit_shift[i] + j] = key[klen - bit_shift[i] + j] ;
			result[rlen / 2 - bit_shift[i] + j] = key[klen / 2 - bit_shift[i] + j] ;
		}	
		key <<= bit_shift[i] ;//移位
		for(size_t j = 0 ; j < bit_shift[i] ; ++j)
		{
			//写回key中
			key[klen / 2 + j] = result[rlen - bit_shift[i] + j] ;
			key[j] = result[rlen / 2 - bit_shift[i] + j] ;
		}
	}
	//压缩置换
	for(size_t i = 0 ; i < result.size() ; ++i)
		result[i] = key[comp_perm[i] - 1] ;
	return result ;
}

//加解密运算
int des(Block & block, Block & bkey, const Method method)
{//block为数据块，bkey为64位密钥
	HBlock left, right ;//左右部分
	ip(block, left, right) ;//初始置换
	switch(method)
	{
	case e://加密
		for(char i = 0 ; i < 16 ; ++i)	
		{	
			Code key = getkey(i, bkey) ;
			des_turn(left, right, key) ;
			if(i != 15) exchange(left, right) ;
		}
		break ;
	case d://解密
		for(char i = 15 ; i >= 0 ; --i)
		{
			Code key = getkey(i, bkey) ;
			des_turn(left, right, key) ;
			if(i != 0) exchange(left, right) ;
		}
		break ;
	default:
		break ;
	}
	rip(left, right, block) ;//末置换
	return 0 ;
}


//初始置换表
static const int ipPerm[64] =
{
	58, 50, 42, 34, 26, 18, 10, 2,
	60, 52, 44, 36, 28, 20, 12, 4,
	62, 54, 46, 38, 30, 22, 14, 6,
	64, 56, 48, 40, 32, 24, 16, 8,
	57, 49, 41, 33, 25, 17, 9, 1,
	59, 51, 43, 35, 27, 19, 11, 3,
	61, 53, 45, 37, 29, 21, 13, 5,
	63, 55, 47, 39, 31, 23, 15, 7
};

//逆初始置换
static const int fpPerm[64] =
{
	40, 8, 48, 16, 56, 24, 64, 32,
	39, 7, 47, 15, 55, 23, 63, 31,
	38, 6, 46, 14, 54, 22, 62, 30,
	37, 5, 45, 13, 53, 21, 61, 29,
	36, 4, 44, 12, 52, 20, 60, 28,
	35, 3, 43, 11, 51, 19, 59, 27,
	34, 2, 42, 10, 50, 18, 58, 26,
	33, 1, 41, 9, 49, 17, 57, 25
};

//扩展置换，将数据从32位扩展为48位
static const int ePerm[48] =
{
	32, 1, 2, 3, 4, 5,
	4, 5, 6, 7, 8, 9,
	8, 9, 10, 11, 12, 13,
	12, 13, 14, 15, 16, 17,
	16, 17, 18, 19, 20, 21,
	20, 21, 22, 23, 24, 25,
	24, 25, 26, 27, 28, 29,
	28, 29, 30, 31, 32, 1
};

//置换
static const int pPerm[32] =
{
	16, 7, 20, 21, 29, 12, 28, 17,
	1, 15, 23, 26, 5, 18, 31, 10,
	2, 8, 24, 14, 32, 27, 3, 9,
	19, 13, 30, 6, 22, 11, 4, 25
};

//S盒子代替
static const int S[8][64] =
{
	{
		14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7,
		0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8,
		4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0,
		15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13
	},//S1盒子
	{
		15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10,
		3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5,
		0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15,
		13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9
	},//S2盒子
	{
		10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8,
		13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1,
		13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7,
		1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12
	},//S3盒子
	{
		7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15,
		13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9,
		10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4,
		3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14
	},//S4盒子
	{
		2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9,
		14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6,
		4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14,
		11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3
	},//S5盒子
	{
		12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11,
		10, 15, 4, 2, 7, 12, 0, 5, 6, 1, 13, 14, 0, 11, 3, 8,
		9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6,
		4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13
	},//S6盒子
	{
		4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1,
		13, 0, 11, 7, 4, 0, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6,
		1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2,
		6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12
	},//S7盒子
	{
		13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7,
		1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2,
		7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8,
		2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11
	}//S8盒子
};

//密钥置换选择1，密钥置换表，将64位密钥置换压缩置换为56位密钥
static const int pc1Perm[56] =
{
	57, 49, 41, 33, 25, 17, 9,
	1, 58, 50, 42, 34, 26, 18,
	10, 2, 59, 51, 43, 35, 27,
	19, 11, 3, 60, 52, 44, 36,
	63, 55, 47, 39, 31, 23, 15,
	7, 62, 54, 46, 38, 30, 22,
	14, 6, 61, 53, 45, 37, 29,
	21, 13, 5, 28, 20, 12, 4
};

//置换选择2，压缩密钥置换表，将56位密钥压缩位48位密钥
static const int pc2Perm[48] =
{
	14, 17, 11, 24, 1, 5, 3, 28,
	15, 6, 21, 10, 23, 19, 12, 4,
	26, 8, 16, 7, 27, 20, 13, 2,
	41, 52, 31, 37, 47, 55, 30, 40,
	51, 45, 33, 48, 44, 49, 39, 56,
	34, 53, 46, 42, 50, 36, 29, 32
};

//每轮循环左移位数
static const int leftShiftNum[16] = {1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1};

//置换选择1后的密钥
int pc1PermKey[56];
//1到16轮的64位密钥，不使用9, 18...54
int leftShiftKey[16][56];

//轮密钥复制
void copyArr(int to[], int from[], int size)
{
	for (int i = 0; i < size; ++i)
		to[i] = from[i];
}

//左移
void leftShift(int a[56])
{
	int tempLeft = a[0];
	int tempRight = a[28];
	for (int i = 0; i < 27; ++i)
	{
		a[i] = a[i + 1];
		a[28 + i] = a[29 + i];
	}
	a[27] = tempLeft;
	a[55] = tempRight;
}

//密钥置换选择1，将64位密钥置换压缩置换为56位密钥
void selectReplcaeKey(int key[64])
{
	//置换选择56位
	for (int i = 0; i < 56; ++i)
		pc1PermKey[i] = key[pc1Perm[i] - 1];
}

//轮密钥储存
void storeKey()
{
	for (int i = 0; i < 16; ++i)
	{
		for (int j = 0; j < leftShiftNum[i]; ++j)
			leftShift (pc1PermKey);
		copyArr (leftShiftKey[i], pc1PermKey, 56);
	}
}

//加密
int* Encrypt(int input[64], int key[64])
{
	int i;
	int j;

	int initInput[64];
	//明文初始置换
	for (i = 0; i < 64; ++i)
		initInput[i] = input[ipPerm[i] - 1];

	//密钥置换选择1
	//选择56位
	selectReplcaeKey (key);

	int leftInput[32];
	int rightInput[32];
	storeKey ();
	for (i = 0; i < 32; ++i)
	{
		leftInput[i] = initInput[i];
		rightInput[i] = initInput[32 + i];
	}

	int sKey[48];
	int expInput[48];
	int XORInput[48];
	int pInput[32];
	int sInput[32];
	int leftInput2[32];
	int newInput[64];
	int invInput[64];
	//密钥循环左移
	for (i = 0; i < 16; ++i)
	{
		//密钥置换选择2
		for (j = 0; j < 48; ++j)
			sKey[j] = leftShiftKey[i][pc2Perm[j] - 1];

		for (j = 0; j < 48; ++j)
			expInput[j] = rightInput[ePerm[j] - 1];

		for (j = 0; j < 48; ++j)
			XORInput[j] = sKey[j] ^ expInput[j];

		for (j = 0; j < 48; j += 6)
		{
			int selectS = XORInput[j] * 2 + XORInput[j + 5];
			int selectNum = XORInput[j + 1] * 8 + XORInput[j + 2] * 4 + XORInput[j + 3] * 2 + XORInput[j + 4] * 1;
			int num = S[j / 6][selectS * 16 + selectNum];
			for (int k = 0; k < 4; ++k)
			{
				sInput[(j / 6) * 4 + 3 - k] = num % 2;
				num = num / 2;
			}
		}

		for (j = 0; j < 32; ++j)
			pInput[j] = sInput[pPerm[j] - 1];
		copyArr (leftInput2, rightInput, 32);

		for (j = 0; j < 32; ++j)
			rightInput[j] = leftInput[j] ^ pInput[j];
		copyArr (leftInput, leftInput2, 32);
	}

	//32位互换
	for (i = 0; i <32; ++i)
	{
		newInput[i] = rightInput[i];
		newInput[32 + i] = leftInput[i];
	}

	//逆初始置换
	for (i = 0; i < 64; ++i)
		invInput[i] = newInput[fpPerm[i] - 1];
	int *output = new int[64];
	copyArr (output, invInput, 64);
	return output;
}

//解密
int* Decrypt(int input[64], int key[64])
{
	int i;
	int j;

	int initInput[64];
	for (i = 0; i < 64; ++i)
		initInput[i] = input[ipPerm[i] - 1];

	//密钥置换选择1
	//选择56位
	selectReplcaeKey (key);

	int leftInput[32];
	int rightInput[32];
	for (i = 0; i < 32; ++i)
	{
		leftInput[i] = initInput[i];
		rightInput[i] = initInput[i + 32];
	}

	int sKey[48];
	int expInput[48];
	int XORInput[48];
	int pInput[32];
	int sInput[32];
	int leftInput2[32];
	int newInput[64];
	int invInput[64];
	for (i = 0; i < 16; ++i)
	{
		//密钥置换选择2
		for (j = 0; j < 48; ++j)
			sKey[j] = leftShiftKey[15 - i][pc2Perm[j] - 1];

		for (j = 0; j < 48; j++)
			expInput[j] = rightInput[ePerm[j] - 1];

		for (j = 0; j < 48; j++)
			XORInput[j] = sKey[j] ^ expInput[j];

		for (j = 0; j < 48; j += 6)
		{
			int selectS = XORInput[j] * 2 + XORInput[j + 5];
			int selectNum = XORInput[j + 1] * 8 + XORInput[j + 2] * 4 + XORInput[j + 3] * 2 + XORInput[j + 4] * 1;
			int num = S[j / 6][selectS * 16 + selectNum];
			for (int k = 0; k < 4; ++k)
			{
				sInput[(j / 6) * 4 + 3 - k] = num % 2;
				num = num / 2;
			}
		}

		for (j = 0; j < 32; ++j)
			pInput[j] = sInput[pPerm[j] - 1];
		copyArr (leftInput2, rightInput, 32);

		for (j = 0; j< 32; ++j)
			rightInput[j] = leftInput[j] ^ pInput[j];
		copyArr (leftInput, leftInput2, 32);
	}

	//32位互换
	for (i = 0; i < 32; ++i)
	{
		newInput[i] = rightInput[i];
		newInput[i + 32] = leftInput[i];
	}

	//逆初始置换
	for (i = 0; i < 64; ++i)
		invInput[i] = newInput[fpPerm[i] - 1];
	int *output = new int[64];
	copyArr (output, invInput, 64);
	return output;
}


//The S-boxes
static unsigned long ice_sbox[4][1024];
static int  ice_sboxes_initialised = 0;

//Modulo values for the S-boxes
static const int ice_smod[4][4] = {
	{ 333, 313, 505, 369 },
	{ 379, 375, 319, 391 },
	{ 361, 445, 451, 397 },
	{ 397, 425, 395, 505 }
};

//XOR values for the S-boxes
static const int ice_sxor[4][4] = {
	{ 0x83, 0x85, 0x9b, 0xcd },
	{ 0xcc, 0xa7, 0xad, 0x41 },
	{ 0x4b, 0x2e, 0xd4, 0x33 },
	{ 0xea, 0xcb, 0x2e, 0x04 }
};

//Permutation values for the P-box
static const unsigned long ice_pbox[32] = {
	0x00000001, 0x00000080, 0x00000400, 0x00002000,
	0x00080000, 0x00200000, 0x01000000, 0x40000000,
	0x00000008, 0x00000020, 0x00000100, 0x00004000,
	0x00010000, 0x00800000, 0x04000000, 0x20000000,
	0x00000004, 0x00000010, 0x00000200, 0x00008000,
	0x00020000, 0x00400000, 0x08000000, 0x10000000,
	0x00000002, 0x00000040, 0x00000800, 0x00001000,
	0x00040000, 0x00100000, 0x02000000, 0x80000000
};

//The key rotation schedule
static const int ice_keyrot[16] = {0, 1, 2, 3, 2, 1, 3, 0, 1, 3, 2, 0, 3, 1, 0, 2};


//8-bit Galois Field multiplication of a by b, modulo m.
//Just like arithmetic multiplication, except that additions and
//subtractions are replaced by XOR.
static unsigned int gf_mult(register unsigned int a, register unsigned int b, register unsigned int m)
{
	register unsigned int res = 0;

	while (b)
	{
		if (b & 1) res ^= a;

		a <<= 1;
		b >>= 1;

		if (a >= 256) a ^= m;
	}

	return (res);
}

//Galois Field exponentiation.
//Raise the base to the power of 7, modulo m.
static unsigned long gf_exp7(register unsigned int b, unsigned int m)
{
	register unsigned int x;

	if (b == 0) return (0);

	x = gf_mult(b, b, m);
	x = gf_mult(b, x, m);
	x = gf_mult(x, x, m);
	return (gf_mult(b, x, m));
}

//Carry out the ICE 32-bit P-box permutation.
static unsigned long ice_perm32(register unsigned long x)
{
	register unsigned long  res = 0;
	register const unsigned long *pbox = ice_pbox;

	while (x)
	{
		if (x & 1) res |= *pbox;
		pbox++;
		x >>= 1;
	}

	return (res);
}

//Initialise the ICE S-boxes.
//This only has to be done once.
static void ice_sboxes_init()
{
	register int i;

	for (i = 0; i<1024; i++)
	{
		int col = (i >> 1) & 0xff;
		int row = (i & 0x1) | ((i & 0x200) >> 8);
		unsigned long x;

		x = gf_exp7(col ^ ice_sxor[0][row], ice_smod[0][row]) << 24;
		ice_sbox[0][i] = ice_perm32(x);

		x = gf_exp7(col ^ ice_sxor[1][row], ice_smod[1][row]) << 16;
		ice_sbox[1][i] = ice_perm32(x);

		x = gf_exp7(col ^ ice_sxor[2][row], ice_smod[2][row]) << 8;
		ice_sbox[2][i] = ice_perm32(x);

		x = gf_exp7(col ^ ice_sxor[3][row], ice_smod[3][row]);
		ice_sbox[3][i] = ice_perm32(x);
	}
}


//Create a new ICE key.
IceKey::IceKey(int n)
{
	if (!ice_sboxes_initialised)
	{
		ice_sboxes_init();
		ice_sboxes_initialised = 1;
	}

	if (n < 1)
	{
		key_size = 1;
		key_rounds = 8;
	}
	else
	{
		key_size = n;
		key_rounds = n * 16;
	}

	key_sched = new IceSubkey[key_rounds];
}

//Destroy an ICE key.
IceKey::~IceKey()
{
	int i, j;

	for (i = 0; i<key_rounds; i++)
		for (j = 0; j<3; j++)
			key_sched[i].val[j] = 0;

	key_rounds = key_size = 0;

	delete[] key_sched;
}

//The single round ICE f function.
static unsigned long ice_f(register unsigned long p, const IceSubkey  *sk)
{
	unsigned long tl, tr;  /* Expanded 40-bit values */
	unsigned long al, ar;  /* Salted expanded 40-bit values */

		/* Left half expansion */
	tl = ((p >> 16) & 0x3ff) | (((p >> 14) | (p << 18)) & 0xffc00);

	/* Right half expansion */
	tr = (p & 0x3ff) | ((p << 2) & 0xffc00);

	/* Perform the salt permutation */
	// al = (tr & sk->val[2]) | (tl & ~sk->val[2]);
	// ar = (tl & sk->val[2]) | (tr & ~sk->val[2]);
	al = sk->val[2] & (tl ^ tr);
	ar = al ^ tr;
	al ^= tl;

	al ^= sk->val[0];  /* XOR with the subkey */
	ar ^= sk->val[1];

	/* S-box lookup and permutation */
	return (ice_sbox[0][al >> 10] | ice_sbox[1][al & 0x3ff]
	| ice_sbox[2][ar >> 10] | ice_sbox[3][ar & 0x3ff]);
}

//Encrypt a block of 8 bytes of data with the given ICE key.
void IceKey::encrypt(const unsigned char *ptext, unsigned char  *ctext) const
{
	register int  i;
	register unsigned long l, r;

	l = (((unsigned long)ptext[0]) << 24)
		| (((unsigned long)ptext[1]) << 16)
		| (((unsigned long)ptext[2]) << 8) | ptext[3];
	r = (((unsigned long)ptext[4]) << 24)
		| (((unsigned long)ptext[5]) << 16)
		| (((unsigned long)ptext[6]) << 8) | ptext[7];

	for (i = 0; i < key_rounds; i += 2)
	{
		l ^= ice_f(r, &key_sched[i]);
		r ^= ice_f(l, &key_sched[i + 1]);
	}

	for (i = 0; i < 4; i++)
	{
		ctext[3 - i] = r & 0xff;
		ctext[7 - i] = l & 0xff;

		r >>= 8;
		l >>= 8;
	}
}

//Decrypt a block of 8 bytes of data with the given ICE key.
void IceKey::decrypt(const unsigned char *ctext, unsigned char  *ptext) const
{
	register int  i;
	register unsigned long l, r;

	l = (((unsigned long)ctext[0]) << 24)
		| (((unsigned long)ctext[1]) << 16)
		| (((unsigned long)ctext[2]) << 8) | ctext[3];
	r = (((unsigned long)ctext[4]) << 24)
		| (((unsigned long)ctext[5]) << 16)
		| (((unsigned long)ctext[6]) << 8) | ctext[7];

	for (i = key_rounds - 1; i > 0; i -= 2)
	{
		l ^= ice_f(r, &key_sched[i]);
		r ^= ice_f(l, &key_sched[i - 1]);
	}

	for (i = 0; i < 4; i++)
	{
		ptext[3 - i] = r & 0xff;
		ptext[7 - i] = l & 0xff;

		r >>= 8;
		l >>= 8;
	}
}

//Set 8 rounds [n, n+7] of the key schedule of an ICE key.
void IceKey::scheduleBuild(unsigned short *kb, int n, const int *keyrot)
{
	int  i;

	for (i = 0; i<8; i++)
	{
		register int j;
		register int kr = keyrot[i];
		IceSubkey  *isk = &key_sched[n + i];

		for (j = 0; j<3; j++)
			isk->val[j] = 0;

		for (j = 0; j<15; j++)
		{
			register int k;
			unsigned long *curr_sk = &isk->val[j % 3];

			for (k = 0; k<4; k++)
			{
				unsigned short *curr_kb = &kb[(kr + k) & 3];
				register int bit = *curr_kb & 1;

				*curr_sk = (*curr_sk << 1) | bit;
				*curr_kb = (*curr_kb >> 1) | ((bit ^ 1) << 15);
			}
		}
	}
}

//Set the key schedule of an ICE key.
void IceKey::set(const unsigned char *key)
{
	int  i;

	if (key_rounds == 8)
	{
		unsigned short kb[4];

		for (i = 0; i<4; i++)
			kb[3 - i] = (key[i * 2] << 8) | key[i * 2 + 1];

		scheduleBuild(kb, 0, ice_keyrot);
		return;
	}

	for (i = 0; i<key_size; i++)
	{
		int j;
		unsigned short kb[4];

		for (j = 0; j<4; j++)
			kb[3 - j] = (key[i * 8 + j * 2] << 8) | key[i * 8 + j * 2 + 1];

		scheduleBuild(kb, i * 8, ice_keyrot);
		scheduleBuild(kb, key_rounds - 8 - i * 8, &ice_keyrot[8]);
	}
}

//Return the key size, in bytes.
int IceKey::keySize() const
{
 return (key_size * 8);
}

//Return the block size, in bytes.
int IceKey::blockSize() const
{
	return (8);
}


#define LB32_MASK 0x00000001
#define LB64_MASK 0x0000000000000001
#define L64_MASK  0x00000000ffffffff

// Permuted Choice 1 Table [7*8]
static const char PC1[] =
{
	57, 49, 41, 33, 25, 17, 9,
	1, 58, 50, 42, 34, 26, 18,
	10, 2, 59, 51, 43, 35, 27,
	19, 11, 3, 60, 52, 44, 36,
	63, 55, 47, 39, 31, 23, 15,
	7, 62, 54, 46, 38, 30, 22,
	14, 6, 61, 53, 45, 37, 29,
	21, 13, 5, 28, 20, 12, 4
};

// Permuted Choice 2 Table [6*8]
static const char PC2[] =
{
	14, 17, 11, 24, 1, 5,
	3, 28, 15, 6, 21, 10,
	23, 19, 12, 4, 26, 8,
	16, 7, 27, 20, 13, 2,
	41, 52, 31, 37, 47, 55,
	30, 40, 51, 45, 33, 48,
	44, 49, 39, 56, 34, 53,
	46, 42, 50, 36, 29, 32
};

// Iteration Shift Array
static const char ITERATION_SHIFT[] = {1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2,1};

// Initial Permutation Table [8*8]
static const char IP[] =
{
	58, 50, 42, 34, 26, 18, 10, 2,
	60, 52, 44, 36, 28, 20, 12, 4,
	62, 54, 46, 38, 30, 22, 14, 6,
	64, 56, 48, 40, 32, 24, 16, 8,
	57, 49, 41, 33, 25, 17, 9, 1,
	59, 51, 43, 35, 27, 19, 11, 3,
	61, 53, 45, 37, 29, 21, 13, 5,
	63, 55, 47, 39, 31, 23, 15, 7
};

// Inverse Initial Permutation Table [8*8]
static const char FP[] =
{
	40, 8, 48, 16, 56, 24, 64, 32,
	39, 7, 47, 15, 55, 23, 63, 31,
	38, 6, 46, 14, 54, 22, 62, 30,
	37, 5, 45, 13, 53, 21, 61, 29,
	36, 4, 44, 12, 52, 20, 60, 28,
	35, 3, 43, 11, 51, 19, 59, 27,
	34, 2, 42, 10, 50, 18, 58, 26,
	33, 1, 41, 9, 49, 17, 57, 25
};

// Expansion table [6*8]
static const char EXPANSION[] =
{
	32, 1, 2, 3, 4, 5,
	 4, 5, 6, 7, 8, 9,
	 8, 9, 10, 11, 12, 13,
	12, 13, 14, 15, 16, 17,
	16, 17, 18, 19, 20, 21,
	20, 21, 22, 23, 24, 25,
	24, 25, 26, 27, 28, 29,
	28, 29, 30, 31, 32, 1
};

// The S-Box tables [8*16*4]
static const char SBOX[8][64] =
{
	{
		// S1
		14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7,
		0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8,
		4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0,
		15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13
	},
	{
		// S2
		15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10,
		3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5,
		0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15,
		13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9
	},
	{
		// S3
		10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8,
		13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1,
		13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7,
		1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12
	},
	{
		// S4
		7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15,
		13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9,
		10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4,
		3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14
	},
	{
		// S5
		2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9,
		14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6,
		4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14,
		11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3
	},
	{
		// S6
		12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11,
		10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8,
		9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6,
		4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13
	},
	{
		// S7
		4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1,
		13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6,
		1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2,
		6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12
	},
	{
		// S8
		13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7,
		1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2,
		7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8,
		2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11
	}
};

// Post S-Box permutation [4*8]
static const char PBOX[] =
{
	16, 7, 20, 21,
	29, 12, 28, 17,
	1, 15, 23, 26,
	5, 18, 31, 10,
	2, 8, 24, 14,
	32, 27, 3, 9,
	19, 13, 30, 6,
	22, 11, 4, 25
};


DES::DES(ui64 key)
{
	keygen(key);
}

ui64 DES::encrypt(ui64 block)
{
	return des(block, false);
}

ui64 DES::decrypt(ui64 block)
{
	return des(block, true);
}

ui64 DES::encrypt(ui64 block, ui64 key)
{
	DES des(key);
	return des.des(block, false);
}

ui64 DES::decrypt(ui64 block, ui64 key)
{
	DES des(key);
	return des.des(block, true);
}

void DES::keygen(ui64 key)
{
	// initial key schedule calculation
	ui64 permuted_choice_1 = 0; // 56 bits
	for (ui8 i = 0; i < 56; i++)
	{
		permuted_choice_1 <<= 1;
		permuted_choice_1 |= (key >> (64-PC1[i])) & LB64_MASK;
	}

	// 28 bits
	ui32 C = (ui32) ((permuted_choice_1 >> 28) & 0x000000000fffffff);
	ui32 D = (ui32)  (permuted_choice_1 & 0x000000000fffffff);

	// Calculation of the 16 keys
	for (ui8 i = 0; i < 16; i++)
	{
		// key schedule, shifting Ci and Di
		for (ui8 j = 0; j < ITERATION_SHIFT[i]; j++)
		{
			C = (0x0fffffff & (C << 1)) | (0x00000001 & (C >> 27));
			D = (0x0fffffff & (D << 1)) | (0x00000001 & (D >> 27));
		}

		ui64 permuted_choice_2 = (((ui64) C) << 28) | (ui64) D;

		sub_key[i] = 0; // 48 bits (2*24)
		for (ui8 j = 0; j < 48; j++)
		{
			sub_key[i] <<= 1;
			sub_key[i] |= (permuted_choice_2 >> (56-PC2[j])) & LB64_MASK;
		}
	}
}

ui64 DES::des(ui64 block, bool mode)
{
	// applying initial permutation
	block = ip(block);

	// dividing T' into two 32-bit parts
	ui32 L = (ui32) (block >> 32) & L64_MASK;
	ui32 R = (ui32) (block & L64_MASK);

	// 16 rounds
	for (ui8 i = 0; i < 16; i++)
	{
		ui32 F = mode ? f(R, sub_key[15-i]) : f(R, sub_key[i]);
		feistel(L, R, F);
	}

	// swapping the two parts
	block = (((ui64) R) << 32) | (ui64) L;
	// applying final permutation
	return fp(block);
}

ui64 DES::ip(ui64 block)
{
	// initial permutation
	ui64 result = 0;
	for (ui8 i = 0; i < 64; i++)
	{
		result <<= 1;
		result |= (block >> (64-IP[i])) & LB64_MASK;
	}
	return result;
}

ui64 DES::fp(ui64 block)
{
	// inverse initial permutation
	ui64 result = 0;
	for (ui8 i = 0; i < 64; i++)
	{
		result <<= 1;
		result |= (block >> (64-FP[i])) & LB64_MASK;
	}
	return result;
}

void DES::feistel(ui32 &L, ui32 &R, ui32 F)
{
	ui32 temp = R;
	R = L ^ F;
	L = temp;
}

ui32 DES::f(ui32 R, ui64 k) // f(R,k) function
{
	// applying expansion permutation and returning 48-bit data
	ui64 s_input = 0;
	for (ui8 i = 0; i < 48; i++)
	{
		s_input <<= 1;
		s_input |= (ui64) ((R >> (32-EXPANSION[i])) & LB32_MASK);
	}

	// XORing expanded Ri with Ki, the round key
	s_input = s_input ^ k;

	// applying S-Boxes function and returning 32-bit data
	ui32 s_output = 0;
	for (ui8 i = 0; i < 8; i++)
	{
		// Outer bits
		char row = (char) ((s_input & (0x0000840000000000 >> 6*i)) >> (42-6*i));
		row = (row >> 4) | (row & 0x01);

		// Middle 4 bits of input
		char column = (char) ((s_input & (0x0000780000000000 >> 6*i)) >> (43-6*i));

		s_output <<= 4;
		s_output |= (ui32) (SBOX[i][16*row + column] & 0x0f);
	}

	// applying the round permutation
	ui32 f_result = 0;
	for (ui8 i = 0; i < 32; i++)
	{
		f_result <<= 1;
		f_result |= (s_output >> (32 - PBOX[i])) & LB32_MASK;
	}

	return f_result;
}


DES3::DES3(ui64 k1, ui64 k2, ui64 k3) :
	des1(k1),
	des2(k2),
	des3(k3)
{
}

ui64 DES3::encrypt(ui64 block)
{
	return des3.encrypt(des2.decrypt(des1.encrypt(block)));
}

ui64 DES3::decrypt(ui64 block)
{
	return des1.decrypt(des2.encrypt(des3.decrypt(block)));
}


DESCBC::DESCBC(ui64 key, ui64 iv) :
	des(key),
	iv(iv),
	last_block(iv)
{
}

ui64 DESCBC::encrypt(ui64 block)
{
	last_block = des.encrypt(block ^ last_block);
	return last_block;
}

ui64 DESCBC::decrypt(ui64 block)
{
	ui64 result = des.decrypt(block) ^ last_block;
	last_block = block;
	return result;
}

void DESCBC::reset()
{
	last_block = iv;
}


DESIO::DESIO(ui64 key) :
	des(key, (ui64) 0x0000000000000000)
{
}

int DESIO::encrypt(string input, string output)
{
	return cipher(input, output, false);
}

int DESIO::decrypt(string input, string output)
{
	return cipher(input, output, true);
}

int DESIO::cipher(string input, string output, bool mode)
{
	ifstream ifile;
	ofstream ofile;
	ui64 buffer;

	if(input.length()  < 1) input  = "/dev/stdin";
	if(output.length() < 1) output = "/dev/stdout";

	ifile.open(input, ios::binary | ios::in | ios::ate);
	ofile.open(output, ios::binary | ios::out);

	ui64 size = ifile.tellg();
	ifile.seekg(0, ios::beg);

	ui64 block = size / 8;
	if(mode) block--;

	for(ui64 i = 0; i < block; i++)
	{
		ifile.read((char*) &buffer, 8);

		if(mode)
			buffer = des.decrypt(buffer);
		else
			buffer = des.encrypt(buffer);

		ofile.write((char*) &buffer, 8);
	}

	if(mode == false)
	{
		// Amount of padding needed
		ui8 padding = 8 - (size % 8);

		// Padding cannot be 0 (pad full block)
		if (padding == 0)
			padding  = 8;

		// Read remaining part of file
		buffer = (ui64) 0;
		if(padding != 8)
			ifile.read((char*) &buffer, 8 - padding);

		// Pad block with a 1 followed by 0s
		ui8 shift = padding * 8;
		buffer <<= shift;
		buffer  |= (ui64) 0x0000000000000001 << (shift - 1);

		buffer = des.encrypt(buffer);
		ofile.write((char*) &buffer, 8);
	}
	else
	{
		// Read last line of file
		ifile.read((char*) &buffer, 8);
		buffer = des.decrypt(buffer);

		// Amount of padding on file
		ui8 padding = 0;

		// Check for and record padding on end
		while(!(buffer & 0x00000000000000ff))
		{
			buffer >>= 8;
			padding++;
		}

		buffer >>= 8;
		padding++;

		if(padding != 8)
			ofile.write((char*) &buffer, 8 - padding);
	}

	ifile.close();
	ofile.close();
	return 0;
}

