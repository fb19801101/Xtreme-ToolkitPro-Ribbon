// MD5.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include <iostream>
#include "md5.h"
#include "des.h"
#include<sstream>
#include <iterator>
#include<ctype.h>
#include<string.h>
string hexto2(string b)
{
	string finala ;
	for (int i = 0; i < 16; i++)
	{
		if (b[i] == '0')
			finala += "0000";

		if (b[i] == '1')
			finala += "0001";

		if (b[i] == '2')
			finala += "0010";

		if (b[i] == '3')
			finala += "0011";

		if (b[i] == '4')
			finala+= "0100";

		if (b[i] == '5')
			finala+= "0101";

		if (b[i] == '6')
			finala+= "0110";

		if (b[i] == '7')
			finala += "0111";

		if (b[i] == '8')
			finala+= "1000";

		if (b[i] == '9')
			finala+= "1001";

		if (b[i] == 'a')
			finala+= "1010";

		if (b[i] == 'b')
			finala+= "1011";

		if (b[i] == 'c')
			finala+= "1100";

		if (b[i] == 'd')
			finala += "1101";

		if (b[i] == 'e')
			finala += "1110";

		if (b[i] == 'f')
			finala +=  "1111";
	}

	return finala;
}

void printArr(int a[64])
{
	for (int i = 0; i < 8; ++i)
	{
		for (int j = 0; j < 8; ++j)
			cout << a[i * 8 + j];
		cout << endl;
	}
	cout << endl;
}

void help(const string & str, size_t num = 88)
{
	string header("DES Manual      MaWenyi") ;
	string command("Command : des option srcfile tarfile keyword") ;
	string options("Options :") ;
	string e("-e : encryption the srcfile with keyword , the result is stored in tarfile") ;
	string d("-d : decryption the srcfile with keyword , the result is stored in tarfile") ;
	string help("-h : show this manual") ;

	for(size_t i = 0 ; i < num - 1 ; ++i)
		cout << '*' ;
	cout << endl ;

	for(size_t i = 0 ; i < num ; ++i)
	{
		if(i == 0 || i == num - 1)
			cout << '*' ;
		else if(i == num / 2 - 3)
		{
			cout << header ;
			i += header.size() ;
		}
		else cout << ' ' ;
	}
	cout << endl ;
	for(size_t i = 0 ; i < num ; ++i)
	{
		if(i == 0 || i == num - 1)
			cout << '*' ;
		else if(i == 3)
		{
			cout << command ;
			i += command.size() ;
		}
		else cout << ' ' ;
	}
	cout << endl ;
	for(size_t i = 0 ; i < num ; ++i)
	{
		if(i == 0 || i == num - 1)
			cout << '*' ;
		else if(i == 3)
		{
			cout << options ;
			i += options.size() ;
		}
		else cout << ' ' ;
	}
	cout << endl ;

	for(size_t i = 0 ; i < num ; ++i)
	{
		if(i == 0 || i == num - 1)
			cout << '*' ;
		else if(i == 3)
		{
			cout << e ;
			i += e.size() ;
		}
		else cout << ' ' ;
	}
	cout << endl ;

	for(size_t i = 0 ; i < num ; ++i)
	{
		if(i == 0 || i == num - 1)
			cout << '*' ;
		else if(i == 3)
		{
			cout << d ;
			i += d.size() ;
		}
		else cout << ' ' ;
	}
	cout << endl ;

	for(size_t i = 0 ; i < num ; ++i)
	{
		if(i == 0 || i == num - 1)
			cout << '*' ;
		else if(i == 3)
		{
			cout << help ;
			i += help.size() ;
		}
		else cout << ' ' ;
	}
	cout << endl ;

	for(size_t i = 0 ; i < num - 1 ; ++i)
		cout << '*' ;
	cout << endl ;

	cout << str << endl ;

	exit(-1) ;//退出
}

int _tmain(int argc, _TCHAR* argv[])
{
	cout << "======================== MD5 ========================" << endl;
	static  struct {
		char *msg;
		unsigned char hash[16];
	}tests[] = {
		{ "",
		{ 0xd4, 0x1d, 0x8c, 0xd9, 0x8f, 0x00, 0xb2, 0x04,
		0xe9, 0x80, 0x09, 0x98, 0xec, 0xf8, 0x42, 0x7e } },
		{ "a",
		{ 0x0c, 0xc1, 0x75, 0xb9, 0xc0, 0xf1, 0xb6, 0xa8,
		0x31, 0xc3, 0x99, 0xe2, 0x69, 0x77, 0x26, 0x61 } },
		{ "abc",
		{ 0x90, 0x01, 0x50, 0x98, 0x3c, 0xd2, 0x4f, 0xb0,
		0xd6, 0x96, 0x3f, 0x7d, 0x28, 0xe1, 0x7f, 0x72 } },
		{ "message digest",
		{ 0xf9, 0x6b, 0x69, 0x7d, 0x7c, 0xb7, 0x93, 0x8d,
		0x52, 0x5a, 0x2f, 0x31, 0xaa, 0xf1, 0x61, 0xd0 } },
		{ "abcdefghijklmnopqrstuvwxyz",
		{ 0xc3, 0xfc, 0xd3, 0xd7, 0x61, 0x92, 0xe4, 0x00,
		0x7d, 0xfb, 0x49, 0x6c, 0xca, 0x67, 0xe1, 0x3b } },
		{ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
		{ 0xd1, 0x74, 0xab, 0x98, 0xd2, 0x77, 0xd9, 0xf5,
		0xa5, 0x61, 0x1c, 0x2c, 0x9f, 0x41, 0x9d, 0x9f } },
		{ "12345678901234567890123456789012345678901234567890123456789012345678901234567890",
		{ 0x57, 0xed, 0xf4, 0xa2, 0x2b, 0xe3, 0xc9, 0x55,
		0xac, 0x49, 0xda, 0x2e, 0x21, 0x07, 0xb6, 0x7a } },

		{ "ibc",
		{ 0x90, 0x01, 0x50, 0x98, 0x3c, 0xd2, 0x4f, 0xb0,
		0xd6, 0x96, 0x3f, 0x7d, 0x28, 0xe1, 0x7f, 0x72 } },
		{ "aba",
		{ 0x90, 0x01, 0x50, 0x98, 0x3c, 0xd2, 0x4f, 0xb0,
		0xd6, 0x96, 0x3f, 0x7d, 0x28, 0xe1, 0x7f, 0x72 } },
		{ "abg",
		{ 0x90, 0x01, 0x50, 0x98, 0x3c, 0xd2, 0x4f, 0xb0,
		0xd6, 0x96, 0x3f, 0x7d, 0x28, 0xe1, 0x7f, 0x72 } },
		{ "abk",
		{ 0x90, 0x01, 0x50, 0x98, 0x3c, 0xd2, 0x4f, 0xb0,
		0xd6, 0x96, 0x3f, 0x7d, 0x28, 0xe1, 0x7f, 0x72 } },
		{ "ebc",
		{ 0x90, 0x01, 0x50, 0x98, 0x3c, 0xd2, 0x4f, 0xb0,
		0xd6, 0x96, 0x3f, 0x7d, 0x28, 0xe1, 0x7f, 0x72 } },
		{ "abC",
		{ 0x90, 0x01, 0x50, 0x98, 0x3c, 0xd2, 0x4f, 0xb0,
		0xd6, 0x96, 0x3f, 0x7d, 0x28, 0xe1, 0x7f, 0x72 } },
		{ "aBc",
		{ 0x90, 0x01, 0x50, 0x98, 0x3c, 0xd2, 0x4f, 0xb0,
		0xd6, 0x96, 0x3f, 0x7d, 0x28, 0xe1, 0x7f, 0x72 } },
		{ "Abc",
		{ 0x90, 0x01, 0x50, 0x98, 0x3c, 0xd2, 0x4f, 0xb0,
		0xd6, 0x96, 0x3f, 0x7d, 0x28, 0xe1, 0x7f, 0x72 } },
	};


	for (int i = 0; i < 15; i++)
	{
		if (i == 7)
		{
			cout << "-----------------雪崩效应---------------------" << endl;
		}
		cout << "第" << i + 1 << "组测试数据" << endl;
		char * message = tests[i].msg;
		cout << "明文消息为：         " << message << endl;
		char buffer[100];
		memset(buffer, 0, sizeof(buffer));
		sprintf_s(buffer, "%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			tests[i].hash[0], tests[i].hash[1], tests[i].hash[2], tests[i].hash[3],
			tests[i].hash[4], tests[i].hash[5], tests[i].hash[6], tests[i].hash[7],
			tests[i].hash[8], tests[i].hash[9], tests[i].hash[10], tests[i].hash[11],
			tests[i].hash[12], tests[i].hash[13], tests[i].hash[14], tests[i].hash[15]);
		for (size_t i = 0; i < strlen(buffer); i++)
		{
			buffer[i] = tolower(buffer[i]);
		}
		cout << "期待的hash值为：     " << buffer << endl;
		MD5 md(message);
		string result;
		result = md.toStr();
		cout << "MD5计算出的哈希值为：" << result << endl;
		string b;
		b = buffer;

		if (b == result)
		{
			cout << "true";
		}
		else

		{
			cout << "flase" << endl;
			string finala= hexto2(b);
			string finalb = hexto2(result);
			cout << "期待哈希值的二进制:"<<finala << endl;
			cout << "计算哈希值的二进制:" << finalb << endl;
			int count=0;
			for (int i = 0; i < 128; i++)
			{
				if (finala[i] != finalb[i])
					count++;
			}
			cout << "改变的位数为："<<count << endl;
		}

		cout << endl;
	}

	system("pause");
	cout << "======================== DES ========================" << endl;

	int input1[64] =
	{
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0
	};
	int input2[64] =
	{
		1, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0
	};
	int key[64] =
	{
		0, 0, 0, 0, 0, 0, 1, 0,
		1, 0, 0, 1, 0, 1, 1, 0,
		0, 1, 0, 0, 1, 0, 0, 0,
		1, 1, 0, 0, 0, 1, 0, 0,
		0, 0, 1, 1, 1, 0, 0, 0,
		0, 0, 1, 1, 0, 0, 0, 0,
		0, 0, 1, 1, 1, 0, 0, 0,
		0, 1, 1, 0, 0, 1, 0, 0
	};
	int key1[64] =
	{
		1, 1, 1, 0, 0, 0, 1, 0,
		1, 1, 1, 1, 0, 1, 1, 0,
		1, 1, 0, 1, 1, 1, 1, 0,
		0, 0, 1, 1, 0, 0, 0, 0,
		0, 0, 1, 1, 1, 0, 1, 0,
		0, 0, 0, 0, 1, 0, 0, 0,
		0, 1, 1, 0, 0, 0, 1, 0,
		1, 1, 0, 1, 1, 1, 0, 0
	};
	int key2[64] =
	{
		0, 1, 1, 0, 0, 0, 1, 0,
		1, 1, 1, 1, 0, 1, 1, 0,
		1, 1, 0, 1, 1, 1, 1, 0,
		0, 0, 1, 1, 0, 0, 0, 0,
		0, 0, 1, 1, 1, 0, 1, 0,
		0, 0, 0, 0, 1, 0, 0, 0,
		0, 1, 1, 0, 0, 0, 1, 0,
		1, 1, 0, 1, 1, 1, 0, 0
	};
	int input[64] =
	{
		0, 1, 1, 0, 1, 0, 0, 0,
		1, 0, 0, 0, 0, 1, 0, 1,
		0, 0, 1, 0, 1, 1, 1, 1,
		0, 1, 1, 1, 1, 0, 1, 0,
		0, 0, 0, 1, 0, 0, 1, 1,
		0, 1, 1, 1, 0, 1, 1, 0,
		1, 1, 1, 0, 1, 0, 1, 1,
		1, 0, 1, 0, 0, 1, 0, 0
	};

	int * inv_m;
	cout << "原文1：" << endl;
	printArr (input1);
	cout << "密钥：" << endl;
	printArr (key);
	cout << "加密生成的密文1：" << endl;
	inv_m = Encrypt (input1, key);
	printArr (inv_m);
	cout << "解密生成的原文1：" << endl;
	printArr (Decrypt (inv_m, key));

	int * inv_m2;
	cout << "原文2：" << endl;
	printArr (input2);
	cout << "密钥：" << endl;
	printArr (key);
	cout << "加密生成的密文2：" << endl;
	inv_m2 = Encrypt (input2, key);
	printArr (inv_m2);
	cout << "解密生成的原文2：" << endl;
	printArr (Decrypt (inv_m2, key));

	int count = 0;
	for (int i = 0; i < 64; ++i)
		if (inv_m[i] != inv_m2[i])
			++count;
	cout << "密文1与密文2不同数据位的数量：" << count << endl << endl;

	cout << "原文：" << endl;
	printArr (input);
	cout << "密钥1：" << endl;
	printArr (key1);
	cout << "加密生成的密文1：" << endl;
	inv_m = Encrypt (input, key1);
	printArr (inv_m);

	cout << "原文：" << endl;
	printArr (input);
	cout << "密钥2：" << endl;
	printArr (key2);
	cout << "加密生成的密文2：" << endl;
	inv_m2 = Encrypt (input, key2);
	printArr (inv_m2);

	count = 0;
	for (int i = 0; i < 64; ++i)
		if (inv_m[i] != inv_m2[i])
			++count;
	cout << "密文1与密文2不同数据位的数量：" << count << endl << endl;

	return 0;
}


void StrFromBlock(char * str , const Block & block)
{
	memset(str , 0 , 8) ;//将8个字节全部置0
	for(size_t i = 0 ; i < block.size() ; ++i)
	{
		if(true == block[i])//第i位为1
			*((unsigned char *)(str) + i / 8) |= (1 << (7 - i % 8)) ;
	}
}

void BlockFromStr(Block & block , const char * str)
{
	for(size_t i = 0 ; i < block.size() ; ++i)
	{
		if(0 != (*((unsigned char *)(str) + i / 8) & (1 << (7 - i % 8))))
			block[i] = true ;
		else 	block[i] = false ;
	}	
}

int _tmain1(int argc , char* argv[])
{
	if(argc < 2 || argv[1][0] != '-')
		help("Command Args Error") ;//输入参数错误，打印帮助文件然后退出

	Method method ;//记录运算方式（加密/解密）
	switch(argv[1][1])
	{
	case 'e'://加密
		method = e ;
		break ;
	case 'd'://加密
		method = d ;
		break ;
	case 'h'://打印帮助文件
		help("") ;
		break ;
	default:
		help("Command Args Error") ;
		break ;
	}
	if(argc < 5 || strlen(argv[4]) < 8)
		help("Command Args Error") ;//输入参数错误，打印帮助文件然后退出

	ifstream srcFile(argv[2]) ;//输入文件
	ofstream tarFile(argv[3]) ;//输出文件
	if(!srcFile || !tarFile) help("File Open Error") ;//文件打开失败

	Block block , bkey ;//数据块和密钥
	BlockFromStr(bkey , argv[4]) ;//获取密钥
	char buffer[8] ;
	while(1)
	{
		memset(buffer , 0 , 8) ;//将8个字节置0
		srcFile.read(buffer , 8) ;//从源中读取数据
		if(srcFile.eof()) break ;
		BlockFromStr(block , buffer) ;//构建数据块
		des(block , bkey , method) ;
		StrFromBlock(buffer , block) ;//获取运算后的数据
		tarFile.write(buffer , 8) ;//写入目标文件
	}
	srcFile.close() ;
	tarFile.close() ;

	return 0 ;
}



void test(ui64 input, ui64 key)
{
	DES des(key);

	ui64 result = des.encrypt(input);
	printf("E: %016lX\n", result);

	result = des.decrypt(result);
	printf("D: %016lX\n", result);
	printf("P: %016lX\n", input);
}

void test1()
{
	ui64 input  = 0x9474B8E8C73BCA7D;

	for (int i = 0; i < 16; i++)
	{
		if (i % 2 == 0)
		{
			input = DES::encrypt(input, input);
			printf("E: %016lX\n", input);
		}
		else
		{
			input = DES::decrypt(input, input);
			printf("D: %016lX\n", input);
		}
	}
}

void test2()
{
	ui64 input = 0x9474B8E8C73BCA7D;
	ui64 key   = 0x0000000000000000;
	printf("\n");
	test(input, key);
	printf("\n");
}

void test3()
{
	test(0x0000000000000000, 0x0000000000000000);
	test(0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF);
}

void test4()
{
	DES3 des(0x2BD6459F82C5B300, 0x952C49104881FF48, 0x2BD6459F82C5B300);
	ui64 input = 0x8598538A8ECF117D;

	ui64 result = des.encrypt(input);
	printf("E: %016lX\n", result);

	result = des.decrypt(result);
	printf("D: %016lX\n", result);
	printf("P: %016lX\n", input);
}

void test5()
{
	DESCBC des(0xFFFFFFFFFFFFFFFF, 0x0000000000000000);

	ui64 input1 = 0x0000000000000000;
	ui64 input2 = 0x0000000000000000;
	ui64 input3 = 0x0000000000000000;

	printf("P1: %016lX\n", input1);
	printf("E1: %016lX\n\n", des.encrypt(input1));

	printf("P2: %016lX\n", input2);
	printf("E2: %016lX\n\n", des.encrypt(input2));

	printf("P3: %016lX\n", input3);
	printf("E3: %016lX  \n", des.encrypt(input3));
}

void alltests()
{
	test1();
	test2();
	test3();
	test4();
	test5();
}

void usage()
{
	cout << "Usage: cppDES -e/-d key [input-file] [output-file]" << endl;
}

int __main(int argc, char* argv[])
{
	test1();
	cout << "======================== test1 ========================" << endl;
	test2();
	cout << "======================== test2 ========================" << endl;
	test3();
	cout << "======================== test3 ========================" << endl;
	test4();
	cout << "======================== test4 ========================" << endl;
	test5();

	if(argc < 3)
	{
		usage();
		return 1;
	}

	string enc_dec = argv[1];
	if(enc_dec != "-e" && enc_dec != "-d")
	{
		usage();
		return 2;
	}

	string input,output;
	if(argc > 3)
		input  = argv[3];
	if(argc > 4)
		output = argv[4];

	ui64 key = strtoul(argv[2], nullptr, 16);
	DESIO fe(key);

	if(enc_dec == "-e")
		return fe.encrypt(input, output);
	if(enc_dec == "-d")
		return fe.decrypt(input, output);

	return 0;
}

