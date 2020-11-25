// LogHelper.h

#pragma once

using namespace System;
using namespace IO;
using namespace Log4Net;

ref class LogHelper
{
private:
	LogHelper(){}

public:
	static Log4Net::ILog^ logdebug = Log4Net::LogManager::GetLogger("logdebug");
	static Log4Net::ILog^ loginfo = Log4Net::LogManager::GetLogger("loginfo");
	static Log4Net::ILog^ logwarn = Log4Net::LogManager::GetLogger("logwarn");
	static Log4Net::ILog^ logerror = Log4Net::LogManager::GetLogger("logerror");
	static Log4Net::ILog^ logfatal = Log4Net::LogManager::GetLogger("logfatal");

	static void SetConfig()
	{
		Log4Net::Config::XmlConfigurator::Configure();
	}

	static void SetConfig(char *lpszconfig)
	{
		String^ info = gcnew String(lpszconfig);
		FileInfo^ config = gcnew FileInfo(info);
		Log4Net::Config::XmlConfigurator::Configure(config);
	}

	static void SetConfig(wchar_t *lpswinfo)
	{
		String^ info = gcnew String(lpswinfo);
		FileInfo^ config = gcnew FileInfo(info);
		Log4Net::Config::XmlConfigurator::Configure(config);
	}

	static void LogDebug(char *lpszDebug)
	{
		String^ debug = gcnew String(lpszDebug);

		if (logdebug->IsDebugEnabled)
			logdebug->Debug(debug);
	}

	static void LogDebug(wchar_t *lpswdebug)
	{
		String^ debug = gcnew String(lpswdebug);

		if (logdebug->IsDebugEnabled)
			logdebug->Debug(debug);
	}

	static void LogDebug(char *lpszDebug, char *lpszex)
	{
		String^ debug = gcnew String(lpszDebug);
		String^ ex = gcnew String(lpszex);
		Exception^ e = gcnew Exception(ex);

		if (logdebug->IsDebugEnabled)
			logdebug->Debug(debug, e);
	}

	static void LogDebug(wchar_t *lpswdebug, wchar_t *lpswex)
	{
		String^ debug = gcnew String(lpswdebug);
		String^ ex = gcnew String(lpswex);
		Exception^ e = gcnew Exception(ex);

		if (logdebug->IsDebugEnabled)
			logdebug->Debug(debug, e);
	}

	static void LogInfo(char *lpszinfo)
	{
		String^ info = gcnew String(lpszinfo);

		if (loginfo->IsInfoEnabled)
			loginfo->Info(info);
	}

	static void LogInfo(wchar_t *lpswinfo)
	{
		String^ info = gcnew String(lpswinfo);

		if (loginfo->IsInfoEnabled)
			loginfo->Info(info);
	}

	static void LogInfo(char *lpszinfo, char *lpszex)
	{
		String^ info = gcnew String(lpszinfo);
		String^ ex = gcnew String(lpszex);
		Exception^ e = gcnew Exception(ex);

		if (loginfo->IsInfoEnabled)
			loginfo->Info(info, e);
	}

	static void LogInfo(wchar_t *lpswinfo, wchar_t *lpswex)
	{
		String^ info = gcnew String(lpswinfo);
		String^ ex = gcnew String(lpswex);
		Exception^ e = gcnew Exception(ex);

		if (loginfo->IsInfoEnabled)
			loginfo->Info(info, e);
	}

	static void LogWarn(char *lpszwarn)
	{
		String^ warn = gcnew String(lpszwarn);

		if (logwarn->IsWarnEnabled)
			logwarn->Info(warn);
	}

	static void LogWarn(wchar_t *lpswwarn)
	{
		String^ warn = gcnew String(lpswwarn);

		if (logwarn->IsWarnEnabled)
			logwarn->Warn(warn);
	}

	static void LogWarn(char *lpszwarn, char *lpszex)
	{
		String^ warn = gcnew String(lpszwarn);
		String^ ex = gcnew String(lpszex);
		Exception^ e = gcnew Exception(ex);

		if (logwarn->IsWarnEnabled)
			logwarn->Info(warn, e);
	}

	static void LogWarn(wchar_t *lpswwarn, wchar_t *lpswex)
	{
		String^ warn = gcnew String(lpswwarn);
		String^ ex = gcnew String(lpswex);
		Exception^ e = gcnew Exception(ex);

		if (logwarn->IsWarnEnabled)
			logwarn->Warn(warn, e);
	}

	static void LogError(char *lpszerror)
	{
		String^ error = gcnew String(lpszerror);

		if (logerror->IsErrorEnabled)
			logerror->Error(error);
	}

	static void LogError(wchar_t *lpswerror)
	{
		String^ error = gcnew String(lpswerror);

		if (logerror->IsErrorEnabled)
			logerror->Error(error);
	}

	static void LogError(char *lpszerror, char *lpszex)
	{
		String^ error = gcnew String(lpszerror);
		String^ ex = gcnew String(lpszex);
		Exception^ e = gcnew Exception(ex);
		
		if (logerror->IsErrorEnabled)
			logerror->Error(error, e);
	}

	static void LogError(wchar_t *lpswerror, wchar_t *lpswex)
	{
		String^ error = gcnew String(lpswerror);
		String^ ex = gcnew String(lpswex); 
		Exception^ e = gcnew Exception(ex);

		if (logerror->IsErrorEnabled)
			logerror->Error(error, e);
	}

	static void LogFatal(char *lpszfatal)
	{
		String^ fatal = gcnew String(lpszfatal);

		if (logfatal->IsFatalEnabled)
			logfatal->Fatal(fatal);
	}

	static void LogFatal(wchar_t *lpswfatal)
	{
		String^ fatal = gcnew String(lpswfatal);

		if (logfatal->IsFatalEnabled)
			logfatal->Fatal(fatal);
	}

	static void LogFatal(char *lpszfatal, char *lpszex)
	{
		String^ fatal = gcnew String(lpszfatal);
		String^ ex = gcnew String(lpszex);
		Exception^ e = gcnew Exception(ex);

		if (logfatal->IsFatalEnabled)
			logfatal->Fatal(fatal, e);
	}

	static void LogFatal(wchar_t *lpswfatal, wchar_t *lpswex)
	{
		String^ fatal = gcnew String(lpswfatal);
		String^ ex = gcnew String(lpswex);
		Exception^ e = gcnew Exception(ex);

		if (logfatal->IsFatalEnabled)
			logfatal->Fatal(fatal, e);
	}
};

#ifndef _LOG_EXT_FUNC
#define _LOG_EXT_FUNC  __declspec(dllexport)
#else
#define _LOG_EXT_FUNC  __declspec(dllimport)
#endif

extern "C"
{
	_LOG_EXT_FUNC void SetConfig() 
	{
		LogHelper::SetConfig();
	}

	_LOG_EXT_FUNC void SetConfigA(char *lpszconfig) 
	{
		LogHelper::SetConfig(lpszconfig);
	}

	_LOG_EXT_FUNC void SetConfigW(wchar_t *lpswconfig) 
	{
		LogHelper::SetConfig(lpswconfig);
	}

	_LOG_EXT_FUNC void LogDebugA(char *lpszdebug) 
	{
		LogHelper::LogDebug(lpszdebug);
	}

	_LOG_EXT_FUNC void LogDebugW(wchar_t *lpswdebug) 
	{
		LogHelper::LogDebug(lpswdebug);
	}

	_LOG_EXT_FUNC void LogDebugExpA(char *lpszdebug, char *lpszex) 
	{
		LogHelper::LogDebug(lpszdebug, lpszex);
	}

	_LOG_EXT_FUNC void LogDebugExpW(wchar_t *lpswdebug, wchar_t *lpswex) 
	{
		LogHelper::LogDebug(lpswdebug, lpswex);
	}

	_LOG_EXT_FUNC void LogInfoA(char *lpszinfo) 
	{
		LogHelper::LogInfo(lpszinfo);
	}

	_LOG_EXT_FUNC void LogInfoW(wchar_t *lpswinfo) 
	{
		LogHelper::LogInfo(lpswinfo);
	}

	_LOG_EXT_FUNC void LogInfoExpA(char *lpszinfo, char *lpszex) 
	{
		LogHelper::LogInfo(lpszinfo, lpszex);
	}

	_LOG_EXT_FUNC void LogInfoExpW(wchar_t *lpswinfo, wchar_t *lpswex) 
	{
		LogHelper::LogInfo(lpswinfo, lpswex);
	}

	_LOG_EXT_FUNC void LogWarnA(char *lpszwarn) 
	{
		LogHelper::LogWarn(lpszwarn);
	}

	_LOG_EXT_FUNC void LogWarnW(wchar_t *lpswwarn) 
	{
		LogHelper::LogWarn(lpswwarn);
	}

	_LOG_EXT_FUNC void LogWarnExpA(char *lpszwarn, char *lpszex) 
	{
		LogHelper::LogWarn(lpszwarn, lpszex);
	}

	_LOG_EXT_FUNC void LogWarnExpW(wchar_t *lpswwarn, wchar_t *lpswex) 
	{
		LogHelper::LogWarn(lpswwarn, lpswex);
	}

	_LOG_EXT_FUNC void LogErrorA(char *lpszerror) 
	{
		LogHelper::LogError(lpszerror);
	} 

	_LOG_EXT_FUNC void LogErrorW(wchar_t *lpswerror) 
	{
		LogHelper::LogError(lpswerror);
	}

	_LOG_EXT_FUNC void LogErrorExpA(char *lpszerror, char *lpszex) 
	{
		LogHelper::LogError(lpszerror, lpszex);
	} 

	_LOG_EXT_FUNC void LogErrorExpW(wchar_t *lpswerror, wchar_t *lpswex) 
	{
		LogHelper::LogError(lpswerror, lpswex);
	}

	_LOG_EXT_FUNC void LogFatalA(char *lpszfatal) 
	{
		LogHelper::LogFatal(lpszfatal);
	}

	_LOG_EXT_FUNC void LogFatalW(wchar_t *lpswfatal) 
	{
		LogHelper::LogFatal(lpswfatal);
	}

	_LOG_EXT_FUNC void LogFatalExpA(char *lpszfatal, char *lpszex) 
	{
		LogHelper::LogFatal(lpszfatal, lpszex);
	}

	_LOG_EXT_FUNC void LogFatalExpW(wchar_t *lpswfatal, wchar_t *lpswex) 
	{
		LogHelper::LogFatal(lpswfatal, lpswex);
	}
}
