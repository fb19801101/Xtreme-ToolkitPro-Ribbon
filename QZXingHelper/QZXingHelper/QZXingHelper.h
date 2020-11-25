// ZXingHelper.h

#pragma once

using namespace System;
using namespace ZXing;

ref class QZXingHelper
{
private:
	QZXingHelper(){}

public:
	//生成条形码
	static void EnCode_EAN_8A(char *lpszean8, char *lpszpath, int width, int height, int margin)
	{
		String^ ean8 = gcnew String(lpszean8);
		String^ path = gcnew String(lpszpath);
		ZXingHelper::EnCode_EAN_8(ean8,path,width,height,margin);
	}
	static void EnCode_EAN_13A(char *lpszean13, char *lpszpath, int width, int height, int margin)
	{
		String^ ean13 = gcnew String(lpszean13);
		String^ path = gcnew String(lpszpath);
		ZXingHelper::EnCode_EAN_13(ean13,path,width,height,margin);
	}
	static void EnCode_EAN_8W(wchar_t *lpswean8, wchar_t *lpswpath, int width, int height, int margin)
	{
		String^ ean8 = gcnew String(lpswean8);
		String^ path = gcnew String(lpswpath);
		ZXingHelper::EnCode_EAN_8(ean8,path,width,height,margin);
	}
	static void EnCode_EAN_13W(wchar_t *lpswean13, wchar_t *lpswpath, int width, int height, int margin)
	{
		String^ ean13 = gcnew String(lpswean13);
		String^ path = gcnew String(lpswpath);
		ZXingHelper::EnCode_EAN_13(ean13,path,width,height,margin);
	}

	//生成二维条形码
	static void EnCode_PDF_417A(char *lpszpdf417, char *lpszpath, int width, int height, int margin, char *lpszcharacter)
	{
		String^ pdf417 = gcnew String(lpszpdf417);
		String^ path = gcnew String(lpszpath);
		String^ character = gcnew String(lpszcharacter);
		ZXingHelper::EnCode_PDF_417(pdf417,path,width,height,margin,character);
	}
	static void EnCode_PDF_417W(wchar_t *lpswpdf417, wchar_t *lpswpath, int width, int height, int margin, wchar_t *lpswcharacter)
	{
		String^ pdf417 = gcnew String(lpswpdf417);
		String^ path = gcnew String(lpswpath);
		String^ character = gcnew String(lpswcharacter);
		ZXingHelper::EnCode_PDF_417(pdf417,path,width,height,margin, character);
	}

	//生成二维码
	static void EnCode_QR_CODEA(char *lpszqrcode, char *lpszpath, int width, int height, int margin)
	{
		String^ qrcode = gcnew String(lpszqrcode);
		String^ path = gcnew String(lpszpath);
		ZXingHelper::EnCode_QR_CODE(qrcode,path,width,height,margin);
	}
	static void EnCode_QR_CODEW(wchar_t *lpswqrcode, wchar_t *lpswpath, int width, int height, int margin)
	{
		String^ qrcode = gcnew String(lpswqrcode);
		String^ path = gcnew String(lpswpath);
		ZXingHelper::EnCode_QR_CODE(qrcode,path,width,height,margin);
	}

	//生成二维码中间带图标
	static void EnCode_QR_CODE_MIDA(char *lpszqrcode, char *lpszpath, char *lpszpngpath, int width, int height, int margin)
	{
		String^ qrcode = gcnew String(lpszqrcode);
		String^ path = gcnew String(lpszpath);
		String^ pngpath = gcnew String(lpszpngpath);
		ZXingHelper::EnCode_QR_CODE_MID(qrcode,path,pngpath,width,height,margin);
	}
	static void EnCode_QR_CODE_MIDW(wchar_t *lpswqrcode, wchar_t *lpswpath, wchar_t *lpswpngpath, int width, int height, int margin)
	{
		String^ qrcode = gcnew String(lpswqrcode);
		String^ path = gcnew String(lpswpath);
		String^ pngpath = gcnew String(lpswpngpath);
		ZXingHelper::EnCode_QR_CODE_MID(qrcode,path,pngpath,width,height,margin);
	}

	//解码操作
	static char* DeCodeA(char *lpszpath, char *lpszcharacter)
	{
		char *lpszqrcode = "";
		String^ qrcode = gcnew String(lpszqrcode);
		String^ path = gcnew String(lpszpath);
		String^ character = gcnew String(lpszcharacter);
		ZXingHelper::DeCode(qrcode, path, character);
		return lpszqrcode;
	}
	static wchar_t* DeCodeW(wchar_t *lpswpath, wchar_t *lpswcharacter)
	{
		wchar_t *lpswqrcode = L"";
		String^ qrcode = gcnew String(lpswqrcode);
		String^ path = gcnew String(lpswpath);
		String^ character = gcnew String(lpswcharacter);
		ZXingHelper::DeCode(qrcode, path, character);
		return lpswqrcode;
	}
};

#ifndef _LOG_EXT_FUNC
#define _LOG_EXT_FUNC  __declspec(dllexport)
#else
#define _LOG_EXT_FUNC  __declspec(dllimport)
#endif

extern "C"
{
	//生成条形码
	_LOG_EXT_FUNC  void EnCode_EAN_8A(char *lpszean8, char *lpszpath, int width, int height, int margin)
	{
		QZXingHelper::EnCode_EAN_8A(lpszean8,lpszpath,width,height,margin);
	}
	_LOG_EXT_FUNC  void EnCode_EAN_13A(char *lpszean13, char *lpszpath, int width, int height, int margin)
	{
		QZXingHelper::EnCode_EAN_13A(lpszean13,lpszpath,width,height,margin);
	}
	_LOG_EXT_FUNC void EnCode_EAN_8W(wchar_t *lpswean8, wchar_t *lpswpath, int width, int height, int margin)
	{
		QZXingHelper::EnCode_EAN_8W(lpswean8,lpswpath,width,height,margin);
	}
	_LOG_EXT_FUNC void EnCode_EAN_13W(wchar_t *lpswean13, wchar_t *lpswpath, int width, int height, int margin)
	{
		QZXingHelper::EnCode_EAN_13W(lpswean13,lpswpath,width,height,margin);
	}

	//生成二维条形码
	_LOG_EXT_FUNC  void EnCode_PDF_417A(char *lpszpdf17, char *lpszpath, int width, int height, int margin)
	{
		QZXingHelper::EnCode_PDF_417A(lpszpdf17,lpszpath,width,height,margin,"UTF-8");
	}
	_LOG_EXT_FUNC void EnCode_PDF_417W(wchar_t *lpswpdf417, wchar_t *lpswpath, int width, int height, int margin)
	{
		QZXingHelper::EnCode_PDF_417W(lpswpdf417,lpswpath,width,height,margin,L"UTF-8");
	}
	_LOG_EXT_FUNC  void EnCode_PDF_417WithCharacterA(char *lpszpdf17, char *lpszpath, int width, int height, int margin, char *lpszcharacter)
	{
		QZXingHelper::EnCode_PDF_417A(lpszpdf17,lpszpath,width,height,margin,lpszcharacter);
	}
	_LOG_EXT_FUNC void EnCode_PDF_417WithCharacterW(wchar_t *lpswpdf417, wchar_t *lpswpath, int width, int height, int margin, wchar_t *lpswcharacter)
	{
		QZXingHelper::EnCode_PDF_417W(lpswpdf417,lpswpath,width,height,margin,lpswcharacter);
	}

	//生成二维码
	_LOG_EXT_FUNC  void EnCode_QR_CODEA(char *lpszqrcode, char *lpszpath, int width, int height, int margin)
	{
		QZXingHelper::EnCode_QR_CODEA(lpszqrcode,lpszpath,width,height,margin);
	}
	_LOG_EXT_FUNC void EnCode_QR_CODEW(wchar_t *lpswqrcode, wchar_t *lpswpath, int width, int height, int margin)
	{
		QZXingHelper::EnCode_QR_CODEW(lpswqrcode,lpswpath,width,height,margin);
	}

	//生成二维码中间带图标
	_LOG_EXT_FUNC  void EnCode_QR_CODE_MIDA(char *lpszqrcode, char *lpszpath, char *lpszpngpath, int width, int height, int margin)
	{
		QZXingHelper::EnCode_QR_CODE_MIDA(lpszqrcode,lpszpath,lpszpngpath,width,height,margin);
	}
	_LOG_EXT_FUNC void EnCode_QR_CODE_MIDW(wchar_t *lpswqrcode, wchar_t *lpswpath, wchar_t *lpswpngpath, int width, int height, int margin)
	{
		QZXingHelper::EnCode_QR_CODE_MIDW(lpswqrcode,lpswpath,lpswpngpath,width,height,margin);
	}

	//解码操作
	_LOG_EXT_FUNC char* DeCodeA(char *lpszpath)
	{
		return QZXingHelper::DeCodeA(lpszpath,"UTF-8");
	}
	_LOG_EXT_FUNC wchar_t* DeCodeW(wchar_t *lpswpath)
	{
		return QZXingHelper::DeCodeW(lpswpath,L"UTF-8");
	}
	_LOG_EXT_FUNC char* DeCodeWithCharacterA(char *lpszpath, char *lpszcharacter)
	{
		return QZXingHelper::DeCodeA(lpszpath,lpszcharacter);
	}
	_LOG_EXT_FUNC wchar_t* DeCodeWithCharacterW(wchar_t *lpswpath, wchar_t *lpswcharacter)
	{
		return QZXingHelper::DeCodeW(lpswpath,lpswcharacter);
	}
}
