/*
* Header file for the C++ ICE encryption class.
*
* Written by Matthew Kwan - July 1996
*/

#ifndef _ICE_DES_H
#define _ICE_DES_H

#include <iostream>
#include <fstream>
#include <string>
#include <cstdint>
#include <bitset>

using namespace std;
typedef  uint64_t ui64;
typedef uint32_t ui32;
typedef uint8_t ui8;
typedef bitset<64> Block;
typedef bitset<56> Key;
typedef bitset<48> Code;
typedef bitset<32> HBlock;
typedef bitset<28> HKey;
typedef bitset<24> HCode;
typedef enum { e , d } Method;

int ip(const Block & block , HBlock & left , HBlock & right);
int des_turn(HBlock & left , HBlock & right , const Code & subkey);
int exchange(HBlock & left , HBlock & right);
int rip(const HBlock & left , const HBlock & right , Block & block);
Code getkey(const unsigned int n , const Block & bkey);
int des(Block & block , Block & bkey , const Method method);

//º”√‹
int* Encrypt(int input[64], int key[64]);

//Ω‚√‹
int* Decrypt(int input[64], int key[64]);

//Structure of a single round subkey
class IceSubkey
{
public:
	unsigned long val[3];
};

class IceKey {
public:
	IceKey(int n);
	~IceKey();

	void set(const unsigned char *key);

	void encrypt(const unsigned char *plaintext, unsigned char *ciphertext) const;

	void decrypt(const unsigned char *ciphertext, unsigned char *plaintext) const;

	int keySize() const;

	int blockSize() const;

private:
	void scheduleBuild(unsigned short *k, int n, const int *keyrot);

	int key_size;
	int key_rounds;
	IceSubkey *key_sched;
};

class DES
{
public:
	DES(ui64 key);
	ui64 des(ui64 block, bool mode);

	ui64 encrypt(ui64 block);
	ui64 decrypt(ui64 block);

	static ui64 encrypt(ui64 block, ui64 key);
	static ui64 decrypt(ui64 block, ui64 key);

protected:
	void keygen(ui64 key);

	ui64 ip(ui64 block);
	ui64 fp(ui64 block);

	void feistel(ui32 &L, ui32 &R, ui32 F);
	ui32 f(ui32 R, ui64 k);

private:
	ui64 sub_key[16]; // 48 bits each
};

class DES3
{
public:
	DES3(ui64 k1, ui64 k2, ui64 k3);
	ui64 encrypt(ui64 block);
	ui64 decrypt(ui64 block);

private:
	DES des1;
	DES des2;
	DES des3;
};

class DESCBC
{
public:
	DESCBC(ui64 key, ui64 iv);
	ui64 encrypt(ui64 block);
	ui64 decrypt(ui64 block);
	void reset();

private:
	DES des;
	ui64 iv;
	ui64 last_block;
};

class DESIO
{
public:
	DESIO(ui64 key);
	int encrypt(string input, string output);
	int decrypt(string input, string output);
	int cipher (string input, string output, bool mode);

private:
	DESCBC des;
};

#endif //_ICE_DES_H