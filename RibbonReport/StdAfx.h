// stdafx.h : include file for standard system include files,
//  or project specific include files that are used frequently, but
//      are changed infrequently
//
// This file is a part of the XTREME TOOLKIT PRO MFC class library.
// (c)1998-2011 Codejock Software, All Rights Reserved.
//
// THIS SOURCE FILE IS THE PROPERTY OF CODEJOCK SOFTWARE AND IS NOT TO BE
// RE-DISTRIBUTED BY ANY MEANS WHATSOEVER WITHOUT THE EXPRESSED WRITTEN
// CONSENT OF CODEJOCK SOFTWARE.
//
// THIS SOURCE CODE CAN ONLY BE USED UNDER THE TERMS AND CONDITIONS OUTLINED
// IN THE XTREME TOOLKIT PRO LICENSE AGREEMENT. CODEJOCK SOFTWARE GRANTS TO
// YOU (ONE SOFTWARE DEVELOPER) THE LIMITED RIGHT TO USE THIS SOFTWARE ON A
// SINGLE COMPUTER.
//
// CONTACT INFORMATION:
// support@codejock.com
// http://www.codejock.com
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_STDAFX_H__EF72F9F6_5792_4FCF_B0BF_1E3261D15016__INCLUDED_)
#define AFX_STDAFX_H__EF72F9F6_5792_4FCF_B0BF_1E3261D15016__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define VC_EXTRALEAN        // Exclude rarely-used stuff from Windows headers

#if _MSC_VER > 1200

// Modify the following defines if you have to target a platform prior to the ones specified below.
// Refer to MSDN for the latest info on corresponding values for different platforms.
#ifndef WINVER              // Allow use of features specific to Windows 95 and Windows NT 4 or later.
#if _MSC_VER > 1500
#define WINVER 0x0500
#else
#define WINVER 0x0400       // Change this to the appropriate value to target Windows 98 and Windows 2000 or later.
#endif
#endif

#ifndef _WIN32_WINNT        // Allow use of features specific to Windows NT 4 or later.
#if _MSC_VER > 1500
#define _WIN32_WINNT 0x0500
#else
#define _WIN32_WINNT 0x0400     // Change this to the appropriate value to target Windows 98 and Windows 2000 or later.
#endif
#endif

#ifndef _WIN32_WINDOWS      // Allow use of features specific to Windows 98 or later.
#define _WIN32_WINDOWS 0x0410 // Change this to the appropriate value to target Windows Me or later.
#endif

#ifndef _WIN32_IE           // Allow use of features specific to IE 4.0 or later.
#define _WIN32_IE 0x0500    // Change this to the appropriate value to target IE 5.0 or later.
#endif

#endif

#include <afxwin.h>         // MFC core and standard components
#include <afxext.h>         // MFC extensions
#include <afxdisp.h>        // MFC Automation classes
#include <afxinet.h>
#ifndef _AFX_NO_AFXCMN_SUPPORT
#include <afxcmn.h>         // MFC support for Windows Common Controls
#endif // _AFX_NO_AFXCMN_SUPPORT
#include <afxdtctl.h>		// MFC support for Internet Explorer 4 Common Controls
#include <afxadv.h>		    // recent file list
#include <afxcview.h>	    // MFC support for Windows 95 Common Controls
#include <afxhtml.h>	    // MFC support for Windows 95 Common Controls
#include <afxrich.h>		// MFC rich edit classes


#include <XTToolkitPro.h>   // Codejock Software Components
#include <afxcontrolbars.h>

#ifdef _UNICODE
#define str(x)   L##x //连接
#else
#define str(x)   x
#endif // !_UNICODE
#define strS(x)  #@x  //单引号
#define strD(x)  #x   //双引号

#ifndef _LOG_EXT_FUNC
#define _LOG_EXT_FUNC  __declspec(dllimport)
#else
#define _LOG_EXT_FUNC  __declspec(dllexport)
#endif

extern "C"
{
	_LOG_EXT_FUNC void SetConfig();
	_LOG_EXT_FUNC void SetConfigA(char *lpszconfig);
	_LOG_EXT_FUNC void LogDebugA(char *lpszdebug);
	_LOG_EXT_FUNC void LogDebugExpA(char *lpszdebug, char *lpszex);
	_LOG_EXT_FUNC void LogInfoA(char *lpszinfo);
	_LOG_EXT_FUNC void LogInfoExpA(char *lpszinfo, char *lpszex);
	_LOG_EXT_FUNC void LogWarnA(char *lpszwarn);
	_LOG_EXT_FUNC void LogWarnExpA(char *lpszwarn, char *lpszex);
	_LOG_EXT_FUNC void LogErrorA(char *lpszerror);
	_LOG_EXT_FUNC void LogErrorExpA(char *lpszerror, char *lpszex);
	_LOG_EXT_FUNC void LogFatalA(char *lpszfatal);
	_LOG_EXT_FUNC void LogFatalExpA(char *lpszfatal, char *lpszex);
	_LOG_EXT_FUNC void EnCode_EAN_8A(char *lpszean8, char *lpszpath, int width, int height, int margin);
	_LOG_EXT_FUNC void EnCode_EAN_13A(char *lpszean13, char *lpszpath, int width, int height, int margin);
	_LOG_EXT_FUNC void EnCode_PDF_417A(char *lpszpdf417, char *lpszpath, int width, int height, int margin);
	_LOG_EXT_FUNC void EnCode_PDF_417WithCharacterA(char *lpszpdf17, char *lpszpath, int width, int height, int margin, char *lpszcharacter);
	_LOG_EXT_FUNC void EnCode_QR_CODEA(char *lpszqrcode, char *lpszpath, int width, int height, int margin);
	_LOG_EXT_FUNC void EnCode_QR_CODE_MIDA(char *lpszqrcode, char *lpszpath, char *lpszpngpath, int width, int height, int margin);
	_LOG_EXT_FUNC char* DeCodeA(char *lpszpath);
	_LOG_EXT_FUNC char* DeCodeWithCharacterA(char *lpszpath, char *lpszcharacter);
	_LOG_EXT_FUNC void SetConfigW(wchar_t *lpswconfig);
	_LOG_EXT_FUNC void LogDebugW(wchar_t *lpswdebug);
	_LOG_EXT_FUNC void LogDebugExpW(wchar_t *lpswdebug, wchar_t *lpswex);
	_LOG_EXT_FUNC void LogInfoW(wchar_t *lpswinfo);
	_LOG_EXT_FUNC void LogInfoExpW(wchar_t *lpswinfo, wchar_t *lpswex);
	_LOG_EXT_FUNC void LogWarnW(wchar_t *lpswwarn);
	_LOG_EXT_FUNC void LogWarnExpW(wchar_t *lpswwarn, wchar_t *lpswex);
	_LOG_EXT_FUNC void LogErrorW(wchar_t *lpswerror);
	_LOG_EXT_FUNC void LogErrorExpW(wchar_t *lpswerror, wchar_t *lpswex);
	_LOG_EXT_FUNC void LogFatalW(wchar_t *lpswfatal);
	_LOG_EXT_FUNC void LogFatalExpW(wchar_t *lpswfatal, wchar_t *lpswex);
	_LOG_EXT_FUNC void EnCode_EAN_8W(wchar_t *lpswean8, wchar_t *lpswpath, int width, int height, int margin);
	_LOG_EXT_FUNC void EnCode_EAN_13W(wchar_t *lpswean13, wchar_t *lpswpath, int width, int height, int margin);
	_LOG_EXT_FUNC void EnCode_PDF_417W(wchar_t *lpswpdf417, wchar_t *lpswpath, int width, int height, int margin);
	_LOG_EXT_FUNC void EnCode_PDF_417WithCharacterW(wchar_t *lpswpdf417, wchar_t *lpswpath, int width, int height, int margin, wchar_t *lpswcharacter);
	_LOG_EXT_FUNC void EnCode_QR_CODEW(wchar_t *lpswqrcode, wchar_t *lpswpath, int width, int height, int margin);
	_LOG_EXT_FUNC void EnCode_QR_CODE_MIDW(wchar_t *lpswqrcode, wchar_t *lpswpath, wchar_t *lpswpngpath, int width, int height, int margin);
	_LOG_EXT_FUNC wchar_t* DeCodeW(wchar_t *lpswpath);
	_LOG_EXT_FUNC wchar_t* DeCodeWithCharacterW(wchar_t *lpswpath, wchar_t *lpswcharacter);
}

#ifdef _UNICODE
#define _SetConfig SetConfigW
#define _LogDebug LogDebugW
#define _LogDebugExp LogDebugExpW
#define _LogInfo LogInfoW
#define _LogInfoExp LogInfoExpW
#define _LogWarn LogWarnW
#define _LogWarnExp LogWarnExpW
#define _LogError LogErrorW
#define _LogErrorExp LogErrorExpW
#define _LogFatal LogFatalW
#define _LogFatalExp LogFatalExpW
#define _EnCode_EAN_8 EnCode_EAN_8W
#define _EnCode_EAN_13 EnCode_EAN_13W
#define _EnCode_PDF_417 EnCode_PDF_417W
#define _EnCode_PDF_417WithCharacter EnCode_PDF_417WithCharacterW
#define _EnCode_QR_CODE EnCode_QR_CODEW
#define _EnCode_QR_CODE_MID EnCode_QR_CODE_MIDW
#define _DeCode DeCodeW
#define _DeCodeWithCharacter DeCodeWithCharacterW
#else
#define _SetConfig SetConfigA
#define _LogDebug LogDebugA
#define _LogDebugExp LogDebugExpA
#define _LogInfo LogInfoA
#define _LogInfoExp LogInfoExpA
#define _LogWarn LogWarnA
#define _LogWarnExp LogWarnExpA
#define _LogError LogErrorA
#define _LogErrorExp LogErrorExpA
#define _LogFatal LogFatalA
#define _LogFatalExp LogFatalExpA
#define _EnCode_EAN_8 EnCode_EAN_8A
#define _EnCode_EAN_13 EnCode_EAN_13A
#define _EnCode_PDF_417 EnCode_PDF_417A
#define _EnCode_PDF_417WithCharacter EnCode_PDF_417WithCharacterA
#define _EnCode_QR_CODE EnCode_QR_CODEA
#define _EnCode_QR_CODE_MID EnCode_QR_CODE_MIDA
#define _DeCode DeCodeA
#define _DeCodeWithCharacter DeCodeWithCharacterA
#endif

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__EF72F9F6_5792_4FCF_B0BF_1E3261D15016__INCLUDED_)
