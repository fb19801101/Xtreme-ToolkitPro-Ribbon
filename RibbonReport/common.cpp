// common.cpp : implementation file
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

#include "stdafx.h"
#include <bitset>
#include <direct.h>
#include "common.h"
#include "md5.h"
#include "RibbonReport.h"

using namespace std;

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////////////////////////
// Define Extern Value And Function
//
CString g_ServerIp;
CString g_SysUid;
CString g_SysUser;
CString g_SysPwd;
bool g_SysRemberPwd;
bool g_SysAutoLogin;
bool g_SysAutoFrame;
CString g_DataBase;
CString g_TablePrix;
CString g_SqlPrix;

void InitCommon()
{
	g_SysUid = _T("SYS00");
	g_SysUser = _T("admin");
	g_SysPwd = _T("admin");
	g_SysRemberPwd = false;
	g_SysAutoLogin = false;
	g_SysAutoFrame = false;
	g_ServerIp = _T(".");
	g_DataBase = _T("ProjectManage.mdf");
	g_TablePrix = _T("[ProjectManage].[dbo].");
	g_SqlPrix = _T("use ProjectManage\ngo\n ");
}

const char* ToColumnLabel(int col)
{
	char lpzCols[] = {'A','B','C','D','E','F','G','H','I','J','K','L','M',
		'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};

	if (col > 25)
	{
		char* lpszCol = new char[2];
		sprintf(lpszCol,"%c%c",lpzCols[col/26-1],lpzCols[col % 26]);
		return lpszCol;
	}
	else
	{
		char* lpszCol = new char[1];
		sprintf(lpszCol,"%c",lpzCols[col]);
		return lpszCol;
	}
}

const char*  ToRangeLabel(long row_begin, int col_begin, long row_end, int col_end)
{
	char* lpszRange = new char[MAX_PACKAGE_NAME];
	sprintf(lpszRange, "%s%u:%s%u",ToColumnLabel(col_begin),row_begin,ToColumnLabel(col_end),row_end);
	return lpszRange;
}

double Round(double fA, int nB)
{
	double _fA = abs(fA);
	double exp = 1.0;
	for(int i=0; i<nB; i++)
		exp *= 10.0;
	int nC = INT(_fA*exp+0.5);
	return (fA>0?1:-1)*nC/exp;
}

BOOL Bound(double fA, double fB, double fC, int nType)
{
	BOOL bRet = FALSE;
	switch (nType)
	{
	case 0:
		if(fA>fB && fA<fC) bRet=TRUE;
		break;
	case 1:
		if((fA>fB || abs(fA-fB)<0.000001) && (fA<fC || abs(fA-fC)<0.000001)) bRet=TRUE;
		break;
	case 2:
		if((fA>fB || abs(fA-fB)<0.000001) && fA<fC) bRet=TRUE;
		break;
	case 3:
		if(fA>fB && (fA<fC || abs(fA-fC)<0.000001)) bRet=TRUE;
		break;
	case 4:
		if(fA<fB && fA>fC) bRet=TRUE;
		break;
	}

	return bRet;
}
//Shell排序
void ArraySort(xtp_vector<xls_variant>& arr, int nSortType)
{
	int nSize = arr.size();
	int nGap = nSize / 2;
	for (int i=0;i<nSize;i++)
	{
		for (int j=nGap;j<nSize;j++)
		{
			int nExchanged = 0;  //记录是否发生了交换，用于Shell排序
			if(nSortType == 1)   //升序排列
			{
				for (int k=0;k<nSize-nGap;k++)
				{
					if(arr[k] > arr[k+nGap])
					{
						xls_variant val = arr[k];
						arr[k] = arr[k+nGap];
						arr[k+nGap] = val;
						nExchanged = 1;
					}
				}
			}

			if(nSortType == -1)  //降序排列
			{
				for (int k=0;k<nSize-nGap;k++)
				{
					if(arr[k] < arr[k+nGap])
					{
						xls_variant val = arr[k];
						arr[k] = arr[k+nGap];
						arr[k+nGap] = val;
						nExchanged = 1;
					}
				}
			}

			if(nExchanged == 1) continue;  //如果发生了交换，则继续循环判断是否还有交换
		}
		nGap = nGap / 2;
		if(nGap == 0) break;
	}
}
//二分法查找
int ArraySearch(xtp_vector<xls_variant>& arr,xls_variant val)
{
	int low=0;
	int high=arr.size();
	int mid = low;

	while (low<high)//稳定版，考虑数组中不存在k的情况
	{
		mid = (low + high) / 2;

		if (arr[mid] == val)
		{
			return mid;
		}
		else 
		{
			if (arr[mid] < val)//右边查找
				low = mid + 1;
			else
				high = mid - 1;
		}
	}

	return -1;//没找到
}
//数组插值
int ArrayInsert(xtp_vector<xls_variant>& arr,xls_variant val)
{
	int nSize = arr.size();
	if(nSize==0)
	{
		arr.push_back(val);
		return 0;
	}

	if(val < arr[0])
	{
		int idx = nSize;
		arr.push_back(val);
		for(int i=0;i<nSize;i++)
		{
			arr[idx] = arr[idx-1];
			idx = idx-1;
		}

		arr[0] = val;
		return 0;
	}

	if(val >= arr[nSize-1])
	{
		arr.push_back(val);
		return nSize;
	}

	for(int i=0;i<nSize;i++)
	{
		if(val >= arr[i] && val < arr[i+1])
		{
			int idx = nSize;
			for(int j=i+1;j<nSize;j++)
			{
				arr[idx] = arr[idx-1];
				idx = idx-1;
			}

			arr[i+1] = val;
			return i+1;
		}
	}

	return -1; //如果在数组中没有查找到对应的数据，则返回查找索引为0
}
//1、K#+###.###  2、+###.###  3、K#  4、+#  5、K#+### 6、K#+###.##  7、K#+###.#  8、+###.##  9、+###.#
CString FormatStat(double fStat, int mode, CString prefix)
{
	CString strStat,strKm,strHm;
	double stat = Round(fStat,3);

	int km = INT(stat/1000);
	int hm = INT((stat-km*1000)/100);
	int sm = INT(stat-km*1000-hm*100);
	double gm = stat-INT(stat);

	switch (mode)
	{
	case 1:
		strStat.Format(_T("%sK%d+%.3d.%.3d"),prefix,km,hm*100+sm,INT(gm*1000));
		break;
	case 2:
		strStat.Format(_T("+%.3d.%.3d"),hm*100+sm,INT(gm*1000));
		break;
	case 3:
		strStat.Format(_T("%sK%d"),prefix,km);
		break;
	case 4:
		strStat.Format(_T("+%d"),hm);
		break;
	case 5:
		strStat.Format(_T("%sK%d+%.3d"),prefix,km,hm*100+sm);
		break;
	case 6:
		strStat.Format(_T("%sK%d+%.3d.%.2d"),prefix,km,hm*100+sm,INT((gm*1000+5)/10));
		break;
	case 7:
		strStat.Format(_T("%sK%d+%.3d.%.1d"),prefix,km,hm*100+sm,INT((gm*1000+5)/100));
		break;
	case 8:
		strStat.Format(_T("+%.3d.%.2d"),hm*100+sm,INT((gm*1000+5)/10));
		break;
	case 9:
		strStat.Format(_T("+%.3d.%.1d"),hm*100+sm,INT((gm*1000+5)/100));
		break;
	}

	return strStat;
}

//1、%Y/%m/%d %H:%M:%S  2、%Y/%m/%d  3、%H:%M:%S
CString FormatDateTime(COleDateTime dt, int mode)
{
	switch (mode)
	{
	case 1:
		return dt.Format(_T("%Y/%m/%d %H:%M:%S"));
	case 2:
		return dt.Format(_T("%Y/%m/%d"));
	case 3:
		return dt.Format(_T("%H:%M:%S"));
	}

	return dt.Format(_T("%Y/%m/%d %H:%M:%S"));
}

COleDateTime ParseDateTime(CString dt, int mode)
{
	int Y,m,d,H,M,S;
	Y=m=d=H=M=S=0;
	dt.Trim();
	switch (mode)
	{
	case 1:
		{
			int i = 0;
			CString dt1 = dt.Tokenize(_T(" "), i);
			CString dt2 = dt.Right(dt.GetLength()-i);
			i = 0;
			dt1.Trim();
			Y = _tstof(dt1.Tokenize(_T("/"), i));
			m = _tstof(dt1.Tokenize(_T("/"), i));
			d = _tstof(dt1.Tokenize(_T("/"), i));
			i = 0;
			dt2.Trim();
			H = _tstof(dt2.Tokenize(_T(":"), i));
			M = _tstof(dt2.Tokenize(_T(":"), i));
			S = _tstof(dt2.Tokenize(_T(":"), i));

		}
		break;
	case 2:
		{
			int i = 0;
			Y = _tstof(dt.Tokenize(_T("/"), i));
			m = _tstof(dt.Tokenize(_T("/"), i));
			d = _tstof(dt.Tokenize(_T("/"), i));
		}
		break;
	case 3:
		{
			int i = 0;
			H = _tstof(dt.Tokenize(_T(":"), i));
			M = _tstof(dt.Tokenize(_T(":"), i));
			S = _tstof(dt.Tokenize(_T(":"), i));

		}
		break;
	}

	return COleDateTime(Y,m,d,H,M,S);

	//COleVariant varTime(dt);
	//varTime.ChangeType(VT_DATE);
	//return COleDateTime(varTime);
	//return COleDateTime().ParseDateTime(dt);
}

CString ToString(double fValue, int nPrec)
{
	return DblToStr(fValue,nPrec);
}

CString NumToBinary(int nNum)
{
	bitset<sizeof(nNum)> bitNum(nNum);
	return bitNum.to_string().c_str();
}

CString GetCurPath()
{
	XTPCHAR path[MAX_PATH];
	GetModuleFileName(AfxGetApp()->m_hInstance,path,MAX_PATH);
	CXTPString cur_path(path);
	int index = cur_path.ReverseFind('\\');
	cur_path = cur_path.Mid(0,index);
	return cur_path;
}

BOOL FileExist(CString strFilePath)
{
	CFileFind finder;
	if (finder.FindFile(strFilePath) != TRUE)
		return FALSE;
	return TRUE;
}

BOOL ReNameFile(CString strFilePath, CString strNewFilePath)
{
	CXTPString oldname(strFilePath);
	CXTPString newname(strNewFilePath);
	return rename(oldname.c_ptr(), newname.c_ptr()) == -1 ? FALSE:TRUE;
}

BOOL DirExist(CString strDirPath)
{
	//return PathIsDirectory(strDirPath);
	WIN32_FIND_DATA wfd;
	HANDLE hFind = FindFirstFile(strDirPath, &wfd);

	if((hFind != INVALID_HANDLE_VALUE) &&
		(wfd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
		return TRUE;

	FindClose(hFind);
	return FALSE;
}

BOOL ModifyDir(CString strDirPath, BOOL bCreate)
{
	CXTPString path(strDirPath);
	if(bCreate)
	{
		_mkdir(path.c_ptr());
		return TRUE;
	}
	else
	{
		while(TRUE)
		{
			int pos = path.FindLastOf("\\");
			CXTPString path1 = path;
			path = path.GetSubStr(0,pos);
			if( pos != -1)
			{
				_rmdir(path1.c_ptr());
			}
			else
				break;

			return TRUE;
		}
	}

	return FALSE;
}

void CreateArray(CStringArray& array, LPCTSTR lpszList, char ch)
{
	CString str = lpszList;

	while (str.GetLength())
	{
		int nIndex = str.Find(ch);

		CString strNext;
		if (nIndex == -1)
		{
			strNext = str;
			str.Empty();
		}
		else
		{
			strNext = str.Left(nIndex);
			str.Delete(0, nIndex + 1);
		}

		array.Add(strNext);
	}
}

CString LoadResourceString(UINT nID)
{
	CString str;
	if(!str.LoadString(nID)) return _T("");
	return str;
}

CString GetDefineID(UINT nID)
{
	if(PathFileExists(_T("Resource.h")))
	{
		setlocale(LC_ALL,"");

		CStdioFile file;
		if(file.Open(_T("Resource.h"), CFile::modeRead))
		{
			int nPos = 0;
			CString strLine;
			while(file.ReadString(strLine))
			{
				strLine.Trim();

				if(strLine.GetLength() == 0)
					continue;

				CString strDefine = strLine.Mid(0,7);
				if(strDefine.Compare(_T("#define")) != 0)
					continue;

				CString strID = strLine.Mid(strLine.ReverseFind(' '),strLine.GetLength()-strLine.ReverseFind(' '));
				strID.Trim();

				if(_tstol(strID) != nID)
					continue;

				strDefine = strLine.Mid(8,strLine.ReverseFind(' '));
				strDefine.Trim();
				strDefine = strDefine.Mid(0,strDefine.Find(' '));
				return strDefine;
			}

			file.Close();
		}
	}

	return ToString(nID,0);
}

HINSTANCE ShellExecuteOpen(CXTPString fileName, CXTPString exeName)
{
	HINSTANCE hinstance;
	if(exeName.GetLength() > 0)
		hinstance = ::ShellExecute(NULL, _T("open"), exeName, fileName, NULL, SW_SHOWNORMAL);
	else
		hinstance = ::ShellExecute(NULL, _T("open"), fileName, NULL, NULL, SW_SHOWNORMAL);

	return hinstance;
}

CXTPString EnCodeStr(CXTPString enCode)
{
	char* text = enCode.c_ptr();
	char* old_locale = _strdup(setlocale(LC_ALL,NULL));
	setlocale(LC_ALL, "chs");

	int len;

	if(!text || !(len = strlen(text))) return "";

	if(len > 255) len = 255; // truncate

	char *p;
	if((p = (char *)malloc((len+2)*sizeof(char))) == NULL)
	{
		free(p);
		return "";
	}

	memcpy(p + 1, text, (len+1)*sizeof(char));
	p[0] = (char)len;

	for(int i=1; i<len+1; i++)
		p[i] = p[i]+1;

	setlocale(LC_ALL, old_locale);
	free(old_locale);
	return p;
}

CXTPString DeCodeStr(CXTPString deCode)
{
	char* text = deCode.c_ptr();
	char* old_locale = _strdup(setlocale(LC_ALL,NULL));
	setlocale(LC_ALL, "chs");

	int len;

	if(!text || !(len = text[0])) return "";

	if(len > 255) len = 255; // truncate

	char *p;
	if((p = (char *)malloc((len+1)*sizeof(char))) == NULL)
	{
		free(p);
		return "";
	}

	memcpy(p, text+1, (len+1)*sizeof(char));

	for(int i=0; i<len; i++)
		p[i] = p[i]-1;

	setlocale(LC_ALL, old_locale);
	free(old_locale);
	return p;
}

CXTPString RegGetString(HKEY hKey, LPCXTPSTR subKey, LPCXTPSTR name)
{
	HKEY hSubKey;
	DWORD type;
	XTPCHAR* val = new XTPCHAR[4096];
	DWORD size = sizeof(val);

	val = '\0';
	if ( RegOpenKeyEx(hKey, subKey, 0, KEY_QUERY_VALUE, &hSubKey) == ERROR_SUCCESS )
	{
		if ( (RegQueryValueEx(hSubKey, name, 0, &type, (LPBYTE)val, &size) != ERROR_SUCCESS) ||
			(type != REG_SZ) )
			val = '\0';
		RegCloseKey(hSubKey);
	}

	return CXTPString(val);
}

int RegPutString(HKEY hKey, LPCXTPSTR subKey, LPCXTPSTR name, LPCXTPSTR val)
{
	HKEY hSubKey;
	DWORD disp;
	int retval = 0;

	if ( RegCreateKeyEx(hKey, subKey, 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hSubKey, &disp) == ERROR_SUCCESS )
	{
		if ( RegSetValueEx(hSubKey, name, 0, REG_SZ, (LPBYTE)val, _tclen(val) + 1) == ERROR_SUCCESS )
			retval = 1;
		RegCloseKey(hSubKey);
	}
	return retval;
}

int RegGetInt(HKEY hKey, LPCXTPSTR subKey, LPCXTPSTR name)
{
	HKEY hSubKey;
	DWORD type;
	DWORD val;
	DWORD size = sizeof(val);
	if ( RegOpenKeyEx(hKey, subKey, 0, KEY_QUERY_VALUE, &hSubKey) == ERROR_SUCCESS )
	{
		if ( (RegQueryValueEx(hSubKey, name, 0, &type, (LPBYTE)&val, &size) != ERROR_SUCCESS) ||
			(type != REG_DWORD) )
			val = 0;
		RegCloseKey(hSubKey);
	}
	return val;
}

int RegPutInt(HKEY hKey, LPCXTPSTR subKey, LPCXTPSTR name, int val)
{
	HKEY hSubKey;
	DWORD disp;
	int retval = 0;
	if ( RegCreateKeyEx(hKey, subKey, 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hSubKey, &disp) == ERROR_SUCCESS )
	{
		if ( RegSetValueEx(hSubKey, name, 0, REG_DWORD, (LPBYTE)&val, sizeof(val)) == ERROR_SUCCESS )
			retval = 1;
		RegCloseKey(hSubKey);
	}
	return retval;
}

CXTPString CpuSerial()
{
	//获取CPU序列号
	unsigned long s1=0,s2=0;     
	CXTPString CpuID,CPUID1,CPUID2;  
	
#ifdef X64
	__asm
	{   
		mov eax,01h   
		xor edx,edx   
		cpuid   
		mov s1,edx   
		mov s2,eax   
	}   
#endif // X64

	CPUID1.Format(_T("%08X%08X"),s1,s2);

#ifdef X64
	__asm
 	{   
 		mov eax,03h   
 		xor ecx,ecx   
 		xor edx,edx   
 		cpuid   
 		mov s1,edx   
 		mov s2,ecx   
 	}
#endif // X64

	CPUID2.Format(_T("%08X%08X"),s1,s2);   

	CpuID=CPUID1+CPUID2;
	return CpuID;
}

CXTPString DiskSerial()
{
	DWORD ser;
	XTPCHAR namebuf[128];
	XTPCHAR filebuf[128];
	//获取C盘的序列号
	::GetVolumeInformation(_T("c:\\"),namebuf,128,&ser,0,0,filebuf,128);
	CString DiskID;
	DiskID.Format(_T("%08X"),ser);

	return DiskID;
}

#include <snmp.h>
#include <conio.h>
#pragma comment(lib, "Snmpapi.lib")
#include "nb30.h"
#pragma comment (lib,"netapi32.lib")
typedef BOOL(WINAPI * pSnmpExtensionInit) (
											IN DWORD dwTimeZeroReference,
											OUT HANDLE * hPollForTrapEvent,
											OUT AsnObjectIdentifier * supportedView);

typedef BOOL(WINAPI * pSnmpExtensionTrap) (
											OUT AsnObjectIdentifier * enterprise,
											OUT AsnInteger * genericTrap,
											OUT AsnInteger * specificTrap,
											OUT AsnTimeticks * timeStamp,
											OUT RFC1157VarBindList * variableBindings);

typedef BOOL(WINAPI * pSnmpExtensionQuery) (
											IN BYTE requestType,
											IN OUT RFC1157VarBindList * variableBindings,
											OUT AsnInteger * errorStatus,
											OUT AsnInteger * errorIndex);

typedef BOOL(WINAPI * pSnmpExtensionInitEx) (OUT AsnObjectIdentifier * supportedView);

struct ADAPTER_INFO
{	
	ADAPTER_STATUS nStatus;
	NAME_BUFFER    nBuffer;
};
CXTPString MacAddress()
{
    pSnmpExtensionInit Init = NULL;
    pSnmpExtensionInitEx InitEx = NULL;
    pSnmpExtensionQuery Query = NULL;
    pSnmpExtensionTrap Trap = NULL;
    HANDLE PollForTrapEvent;
    AsnObjectIdentifier SupportedView;
    UINT OID_ifEntryType[] = {1, 3, 6, 1, 2, 1, 2, 2, 1, 3};
    UINT OID_ifEntryNum[] = {1, 3, 6, 1, 2, 1, 2, 1};
    UINT OID_ipMACEntAddr[] = {1, 3, 6, 1, 2, 1, 2, 2, 1, 6};                          //, 1 ,6 };
    AsnObjectIdentifier MIB_ifMACEntAddr = { sizeof(OID_ipMACEntAddr) / sizeof(UINT), OID_ipMACEntAddr };
    AsnObjectIdentifier MIB_ifEntryType = {sizeof(OID_ifEntryType) / sizeof(UINT), OID_ifEntryType};
    AsnObjectIdentifier MIB_ifEntryNum = {sizeof(OID_ifEntryNum) / sizeof(UINT), OID_ifEntryNum};
    RFC1157VarBindList varBindList;
    RFC1157VarBind varBind[2];
    AsnInteger errorStatus;
    AsnInteger errorIndex;
    AsnObjectIdentifier MIB_NULL = {0, 0};
    int ret;
    int dtmp;
    int i = 0, j = 0;
    BOOL found = FALSE;
    char TempEthernet[13];

    /* Load the SNMP dll and get the addresses of the functions
       necessary */
    HINSTANCE hInst = LoadLibrary(_T("inetmib1.dll"));
    if (hInst < (HINSTANCE) HINSTANCE_ERROR)
	{
        hInst = NULL;
        return "";
    }
    Init = (pSnmpExtensionInit) GetProcAddress(hInst, "SnmpExtensionInit");
    InitEx = (pSnmpExtensionInitEx) GetProcAddress(hInst,"SnmpExtensionInitEx");
    Query = (pSnmpExtensionQuery) GetProcAddress(hInst,"SnmpExtensionQuery");
    Trap = (pSnmpExtensionTrap) GetProcAddress(hInst, "SnmpExtensionTrap");
    Init(GetTickCount(), &PollForTrapEvent, &SupportedView);

    /* Initialize the variable list to be retrieved by m_Query */
    varBindList.list = varBind;
    varBind[0].name = MIB_NULL;
    varBind[1].name = MIB_NULL;

    /* Copy in the OID to find the number of entries in the
       Inteface table */
    varBindList.len = 1;        /* Only retrieving one item */
    SNMP_oidcpy(&varBind[0].name, &MIB_ifEntryNum);
    ret = Query(ASN_RFC1157_GETNEXTREQUEST, &varBindList, &errorStatus, &errorIndex);
    printf("# of adapters in this system : %i\n", varBind[0].value.asnValue.number);
	varBindList.len = 2;

    /* Copy in the OID of ifType, the type of interface */
    SNMP_oidcpy(&varBind[0].name, &MIB_ifEntryType);

    /* Copy in the OID of ifPhysAddress, the address */
    SNMP_oidcpy(&varBind[1].name, &MIB_ifMACEntAddr);

    do {

        /* Submit the query.  Responses will be loaded into varBindList.
           We can expect this call to succeed a # of times corresponding
           to the # of adapters reported to be in the system */
        ret = Query(ASN_RFC1157_GETNEXTREQUEST, &varBindList, &errorStatus, &errorIndex);
		if (!ret)
			ret = 1;
        else
            /* Confirm that the proper type has been returned */
            ret = SNMP_oidncmp(&varBind[0].name, &MIB_ifEntryType, MIB_ifEntryType.idLength);
		if (!ret)
		{
            j++;
            dtmp = varBind[0].value.asnValue.number;
            printf("Interface #%i type : %i\n", j, dtmp);

            /* Type 6 describes ethernet interfaces */
            if (dtmp == 6)
			{
                /* Confirm that we have an address here */
                ret = SNMP_oidncmp(&varBind[1].name, &MIB_ifMACEntAddr, MIB_ifMACEntAddr.idLength);
                if ((!ret) && (varBind[1].value.asnValue.address.stream != NULL))
				{
                    if ((varBind[1].value.asnValue.address.stream[0] == 0x44)
                        && (varBind[1].value.asnValue.address.stream[1] == 0x45)
                        && (varBind[1].value.asnValue.address.stream[2] == 0x53)
                        && (varBind[1].value.asnValue.address.stream[3] == 0x54)
                        && (varBind[1].value.asnValue.address.stream[4] == 0x00))
					{
                        /* Ignore all dial-up networking adapters */
                        printf("Interface #%i is a DUN adapter\n", j);
                        continue;
                    }

                    if ((varBind[1].value.asnValue.address.stream[0] == 0x00)
                        && (varBind[1].value.asnValue.address.stream[1] == 0x00)
                        && (varBind[1].value.asnValue.address.stream[2] == 0x00)
                        && (varBind[1].value.asnValue.address.stream[3] == 0x00)
                        && (varBind[1].value.asnValue.address.stream[4] == 0x00)
                        && (varBind[1].value.asnValue.address.stream[5] == 0x00))
					{
                        /* Ignore NULL addresses returned by other network
                           interfaces */
                        printf("Interface #%i is a NULL address\n", j);
                        continue;
                    }

                    sprintf(TempEthernet, "%02x%02x%02x%02x%02x%02x",
                            varBind[1].value.asnValue.address.stream[0],
                            varBind[1].value.asnValue.address.stream[1],
                            varBind[1].value.asnValue.address.stream[2],
                            varBind[1].value.asnValue.address.stream[3],
                            varBind[1].value.asnValue.address.stream[4],
                            varBind[1].value.asnValue.address.stream[5]);
                    printf("MAC Address of interface #%i: %s\n", j, TempEthernet);
				}
            }
        }
    } while (!ret);         /* Stop only on an error.  An error will occur
                               when we go exhaust the list of interfaces to
                               be examined */
    getch();

    /* Free the bindings */
    SNMP_FreeVarBind(&varBind[0]);
    SNMP_FreeVarBind(&varBind[1]);

	return CXTPString(TempEthernet);

	NCB nInfo;
	memset(&nInfo,0,sizeof(NCB));
	nInfo.ncb_command  = NCBRESET;
	nInfo.ncb_lana_num = 0;
	Netbios(&nInfo);
	ADAPTER_INFO AdaINfo;
	//初始化NetBIOS
	memset(&nInfo,0,sizeof(NCB));
	nInfo.ncb_command  = NCBASTAT;
	nInfo.ncb_lana_num = 0;
	nInfo.ncb_buffer   = (unsigned char*)&AdaINfo;
	nInfo.ncb_length   = sizeof(ADAPTER_INFO);
	strncpy((char*)nInfo.ncb_callname,"*",NCBNAMSZ);
	Netbios(&nInfo);

	CXTPString MacAddr;
	MacAddr.Format("%02X%02X%02X%02X%02X%02X",
		AdaINfo.nStatus.adapter_address[0],
		AdaINfo.nStatus.adapter_address[1],
		AdaINfo.nStatus.adapter_address[2],
		AdaINfo.nStatus.adapter_address[3],
		AdaINfo.nStatus.adapter_address[4],
		AdaINfo.nStatus.adapter_address[5]);

	return MacAddr;
}

CXTPString SnKey(CXTPString SnCode)
{
	//定义一个密钥数组
	CXTPString code[16] = {
		"ah","tm","ib","nw",
		"rt","vx","zc","gf",
		"pn","xq","fc","oj",
		"wm","eq","np","qw"};

	SnCode.ToLower();

	CXTPString SN;
	int num = 0;
	for(int i=0; i<10; i++)
	{
		char p = SnCode[i];
		if(p >= 'a' && p <= 'f')
			num = p - 'a' + 10;
		else
			num = p - '0';

		SN += code[num];
	}

	return SN.ToUpper();
}


/*
bool DeleteFile(XTPCHAR* lpszFrom)
{
	SHFILEOPSTRUCT FileOp={0};
	FileOp.fFlags = FOF_ALLOWUNDO |   //允许放回回收站
		FOF_NOCONFIRMATION; //不出现确认对话框
	FileOp.pFrom = lpszFrom; 
	FileOp.pTo = NULL;
	FileOp.wFunc = FO_DELETE;
	return SHFileOperation(&FileOp) == 0; 
}

bool CopyFile(XTPCHAR* lpszFrom, XTPCHAR* lpszTo)
{
	SHFILEOPSTRUCT FileOp={0}; 
	FileOp.fFlags = FOF_NOCONFIRMATION|   //不出现确认对话框
		FOF_NOCONFIRMMKDIR; //需要时直接创建一个文件夹,不需用户确定
	FileOp.pFrom = lpszFrom; 
	FileOp.pTo = lpszTo; 
	FileOp.wFunc = FO_COPY; 
	return SHFileOperation(&FileOp) == 0; 
}

bool MoveFile(XTPCHAR* lpszFrom, XTPCHAR* lpszTo)
{
	SHFILEOPSTRUCT FileOp={0}; 
	FileOp.fFlags = FOF_NOCONFIRMATION|   //不出现确认对话框 
		FOF_NOCONFIRMMKDIR ; //需要时直接创建一个文件夹,不需用户确定
	FileOp.pFrom = lpszFrom; 
	FileOp.pTo = lpszTo; 
	FileOp.wFunc = FO_MOVE; 
	return SHFileOperation(&FileOp) == 0;   
}

bool ReNameFile(XTPCHAR* lpszFrom, XTPCHAR* lpszTo)
{
	SHFILEOPSTRUCT FileOp={0}; 
	FileOp.fFlags = FOF_NOCONFIRMATION;   //不出现确认对话框 
	FileOp.pFrom = lpszFrom; 
	FileOp.pTo = lpszTo;
	FileOp.wFunc = FO_RENAME; 
	return SHFileOperation(&FileOp) == 0;   
}
*/


//数据库处理
BOOL DataBackup(CString data, CString path)
{
	CString sql;
	_variant_t flag,ret;
	sql.Format(_T("%ssp_Data_Backup"), g_TablePrix);
	CXTPADOCommand cmd(theCon, sql);
	cmd.SetType(CXTPADOCommand::xtpAdoCmdStoredProc);
	cmd.MakeInParam(_T("@backup_db_name"), xtpAdoVarWChar, 128, _variant_t(data));
	cmd.MakeInParam(_T("@filename"), xtpAdoVarWChar, 255, _variant_t(path));
	cmd.MakeOutParam(_T("@ret"), xtpAdoTinyInt, 1, ret);
	cmd.MakeOutParam(_T("@flag"), xtpAdoVarChar, 20, flag);
	cmd.Execute();
	ret = cmd.GetParamValue(2);
	flag = cmd.GetParamValue(3);
	return ret.bVal;
}

BOOL DataRestore(CString data, CString path)
{
	CString sql;
	_variant_t flag,ret;
	sql.Format(_T("%ssp_Data_Restore"), g_TablePrix);
	CXTPADOCommand cmd(theCon, sql);
	cmd.SetType(CXTPADOCommand::xtpAdoCmdStoredProc);
	cmd.MakeInParam(_T("@restore_db_name"), xtpAdoVarWChar, 128, _variant_t(data));
	cmd.MakeInParam(_T("@filename"), xtpAdoVarWChar, 255, _variant_t(path));
	cmd.MakeOutParam(_T("@ret"), xtpAdoTinyInt, 1, ret);
	cmd.MakeOutParam(_T("@flag"), xtpAdoVarChar, 20, flag);
	cmd.Execute();
	ret = cmd.GetParamValue(2);
	flag = cmd.GetParamValue(3);

	return ret.bVal;
}

int DataClear()
{
	CString sql;
	sql.Format(_T("%ssp_Data_Clear"), g_TablePrix);
	return theCon.Execute(sql);
}

int ExecuteSql(CString sql)
{
	return theCon.Execute(sql);
}

XTPREPORTMSADODB::_RecordsetPtr ExecuteRst(CString sql)
{
	XTPREPORTMSADODB::_RecordsetPtr rst = NULL;
	rst.CreateInstance(__uuidof(XTPREPORTMSADODB::Recordset));
	rst->CursorLocation = XTPREPORTMSADODB::adUseClient;

	rst->Open(_variant_t(sql), _variant_t((IDispatch*)theCon.GetInterfacePtr(), TRUE), 
		XTPREPORTMSADODB::adOpenDynamic, XTPREPORTMSADODB::adLockOptimistic, XTPREPORTMSADODB::adCmdText);

	return rst;
}

int ExecuteProcedureSql(CString sp)
{
	CString sql;
	sql.Format(_T("%s%s"), g_TablePrix,sp);
	return ExecuteSql(sql);
}

XTPREPORTMSADODB::_RecordsetPtr ExecuteProcedureRst(CString sp)
{
	CString sql;
	sql.Format(_T("%s%s"), g_TablePrix,sp);
	return ExecuteRst(sql);
}


//用户信息
int Login()
{
	CString sql;
	sql.Format(_T("select * from %s[tb_users] where (sysuser = ?) and (password = ?)"), g_TablePrix);
	CXTPADOCommand cmd(theCon, sql);
	cmd.MakeInParam(_T("sysuser"), xtpAdoVarChar, 20, _variant_t(g_SysUser));
	cmd.MakeInParam(_T("password"), xtpAdoVarChar, 20, _variant_t(g_SysPwd));
	CXTPADORecordset rst;
	int ret = cmd.Execute(rst);
	if(rst.GetRecordCount()) rst.GetFieldValue(0, g_SysUid);
	return ret;
}

int FindSysUid(ado_users& src)
{
	CString sql;
	sql.Format(_T("select * from %s[tb_users] where id = '%s' order by id"), g_TablePrix, g_SysUid);
	CXTPADOCommand cmd(theCon, sql);
	CXTPADORecordset rst;
	int ret = cmd.Execute(rst);
	src = rst;
	return ret;
}

int SetSysStatus(bool remberpwd, bool autologin, bool autoframe, bool advanced, bool stat)
{
	CString sql;
	sql.Format(_T("update %s[tb_users] set remberpwd = %d, autologin = %d, autoframe = %d, advanced = %d, state = %d where id = ?"), g_TablePrix,remberpwd,autologin,autoframe,advanced,stat);
	CXTPADOCommand cmd(theCon, sql);
	cmd.MakeInParam(_T("id"), xtpAdoVarChar, 5, _variant_t(g_SysUid));
	//cmd.MakeInParam(_T("remberpwd"), xtpAdoTinyInt, 1, _variant_t(remberpwd));
	//cmd.MakeInParam(_T("autologin"), xtpAdoTinyInt, 1, _variant_t(autologin));
	//cmd.MakeInParam(_T("advanced"), xtpAdoTinyInt, 1, _variant_t(advanced));
	return cmd.Execute();
}

int AddSysUser()
{
	g_SysUid = GetAutoCode(_T("tb_users"));
	CString sql;
	sql.Format(_T("insert into %s[tb_users] (id, sysuser, password, md5pwd) values (?, ?, ?, ?)"), g_TablePrix);
	CXTPADOCommand cmd(theCon, sql);
	cmd.MakeInParam(_T("id"), xtpAdoVarChar, 5, _variant_t(g_SysUid));
	cmd.MakeInParam(_T("sysuser"), xtpAdoVarChar, 20, _variant_t(g_SysUser));
	cmd.MakeInParam(_T("password"), xtpAdoVarChar, 20, _variant_t(g_SysPwd));
	MD5 md(g_SysPwd);
	CString md5pwd = md.toXTPStr();
	cmd.MakeInParam(_T("md5pwd"), xtpAdoVarChar, 32, _variant_t(md5pwd));
	return cmd.Execute();
}

int SetSysPwd()
{
	CString sql;
	sql.Format(_T("update %s[tb_users] set password = ?, md5pwd = ? where id = ?"), g_TablePrix);
	CXTPADOCommand cmd(theCon, sql);
	cmd.MakeInParam(_T("password"), xtpAdoVarChar, 20, _variant_t(g_SysPwd));
	MD5 md(g_SysPwd);
	CString md5pwd = md.toXTPStr();
	cmd.MakeInParam(_T("md5pwd"), xtpAdoVarChar, 32, _variant_t(md5pwd));
	cmd.MakeInParam(_T("id"), xtpAdoVarChar, 5, _variant_t(g_SysUid));
	return cmd.Execute();
}

int DelSysUser()
{
	CString sql;
	sql.Format(_T("delete from %s[tb_users] where id='%s'"), g_TablePrix, g_SysUid);
	return theCon.Execute(sql);
}

// 获取数据信息
XTPREPORTMSADODB::_RecordsetPtr GetRecordset(CString table, CString fids, CString sql)
{
	if(!ExistsTable(table)) return NULL;

	if(fids.IsEmpty())
	{
		if(sql.IsEmpty())
			sql.Format(_T("select * from %s[%s]"), g_TablePrix, table);
		else
			sql.Format(_T("select * from %s[%s] %s"), g_TablePrix, table, sql);
	}
	else
	{
		if(sql.IsEmpty())
			sql.Format(_T("select %s from %s[%s]"), fids, g_TablePrix, table);
		else
			sql.Format(_T("select %s from %s[%s] %s"), fids, g_TablePrix, table, sql);
	}

	XTPREPORTMSADODB::_RecordsetPtr rst = NULL;
	rst.CreateInstance(__uuidof(XTPREPORTMSADODB::Recordset));
	rst->CursorLocation = XTPREPORTMSADODB::adUseClient;

	rst->Open(_variant_t(sql), _variant_t((IDispatch*)theCon.GetInterfacePtr(), TRUE), 
		XTPREPORTMSADODB::adOpenDynamic, XTPREPORTMSADODB::adLockOptimistic, XTPREPORTMSADODB::adCmdText);

	return rst;
}

CXTPADORecordset GetRecordset(CXTPADOConnection con, CString table, CString fids, CString sql)
{
	CXTPADORecordset rst(con);
	if(!ExistsTable(table)) return rst;

	if(fids.IsEmpty())
	{
		if(sql.IsEmpty())
			sql.Format(_T("select * from %s[%s]"), g_TablePrix, table);
		else
			sql.Format(_T("select * from %s[%s] %s"), g_TablePrix, table, sql);
	}
	else
	{
		if(sql.IsEmpty())
			sql.Format(_T("select %s from %s[%s]"), fids, g_TablePrix, table);
		else
			sql.Format(_T("select %s from %s[%s] %s"), fids, g_TablePrix, table, sql);
	}

	if(rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc))
		return rst;

	return rst;
}

void RequeryRecordset(XTPREPORTMSADODB::_RecordsetPtr rst)
{
	if(rst != NULL)
		rst->Requery(XTPREPORTMSADODB::adCmdStoredProc);
}

void ResyncRecordset(XTPREPORTMSADODB::_RecordsetPtr rst)
{
	if(rst != NULL)
		rst->Resync(XTPREPORTMSADODB::adAffectCurrent,XTPREPORTMSADODB::adResyncAllValues);
}

COleVariant GetAutoCode(CString table)
{
	if(!ExistsTable(table)) return COleVariant();

	CString sql;
	_variant_t fid,val;
	sql.Format(_T("%ssp_AutoCode"), g_TablePrix);
	CXTPADOCommand cmd(theCon, sql);
	cmd.SetType(CXTPADOCommand::xtpAdoCmdStoredProc);
	cmd.MakeInParam(_T("@tbl"), xtpAdoVarWChar, 20, _variant_t(table));
	cmd.MakeOutParam(_T("@fid"), xtpAdoVarWChar, 20, fid);
	cmd.MakeOutParam(_T("@val"), xtpAdoVarChar, 10, val);
	cmd.Execute();
	fid = cmd.GetParamValue(1);
	val = cmd.GetParamValue(2);
	return val;
}

CString GetFieldName(CString table, int idx)
{
	if(!ExistsTable(table)) return _T("");

	CString sql;
	_variant_t fid;
	sql.Format(_T("%ssp_GetFieldName"), g_TablePrix);
	CXTPADOCommand cmd(theCon, sql);
	cmd.SetType(CXTPADOCommand::xtpAdoCmdStoredProc);
	cmd.MakeInParam(_T("@tbl"), xtpAdoVarWChar, 20, _variant_t(table));
	cmd.MakeInParam(_T("@idx"), xtpAdoInteger, 4, _variant_t(idx));
	cmd.MakeOutParam(_T("@fid"), xtpAdoVarWChar, 20, fid);
	cmd.Execute();

	return CString(cmd.GetParamValue(2).bstrVal);
}

xtp_vector<CString> GetTableName(CXTPADOConnection con)
{
	xtp_vector<CString> tbls;
	if (con.Open())
	{
		CString sql = _T("select name from sysobjects where xtype='U' order by Name");
		CXTPADORecordset rst(con);
		if(rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc))
		{
			while (!rst.IsEOF())
			{
				CString tbl;
				rst.GetFieldValue(0,tbl);
				tbls.push_back(tbl);

				rst.MoveNext();
			}
			rst.Close();
		}
	}

	return tbls;
}

xtp_vector<CString> GetFieldName(CXTPADOConnection con, CString table)
{
	xtp_vector<CString> fields;
	if (con.Open())
	{
		CString sql;
		sql.Format(_T("select name from syscolumns where id=object_id('%s')"),table);
		CXTPADORecordset rst(con);
		if(rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc))
		{
			while (!rst.IsEOF())
			{
				CString field;
				rst.GetFieldValue(0,field);
				fields.push_back(field);

				rst.MoveNext();
			}
			rst.Close();
		}
	}

	return fields;
}

BOOL ExistsTable(CString table)
{
	CString sql;
	_variant_t ret;
	sql.Format(_T("%ssp_ExistsTable"), g_TablePrix);
	CXTPADOCommand cmd(theCon, sql);
	cmd.SetType(CXTPADOCommand::xtpAdoCmdStoredProc);
	cmd.MakeInParam(_T("@tbl"), xtpAdoVarWChar, 20, _variant_t(table));
	cmd.MakeOutParam(_T("@ret"), xtpAdoTinyInt, 1, ret);
	cmd.Execute();
	return cmd.GetParamValue(1).bVal;
}

long CountField(CString table, CString field, CString cond1, CString cond2)
{
	if(!ExistsTable(table)) return 0;

	CString sql;
	_variant_t val;
	sql.Format(_T("%ssp_CountField"), g_TablePrix);
	CXTPADOCommand cmd(theCon, sql);
	cmd.SetType(CXTPADOCommand::xtpAdoCmdStoredProc);
	cmd.MakeInParam(_T("@tbl"), xtpAdoVarWChar, 20, _variant_t(table));
	cmd.MakeInParam(_T("@fid"), xtpAdoVarWChar, 20, _variant_t(field));
	cmd.MakeInParam(_T("@cond1"), xtpAdoVarWChar, 20, _variant_t(cond1));
	cmd.MakeInParam(_T("@cond2"), xtpAdoVarWChar, 20, _variant_t(cond2));
	cmd.MakeOutParam(_T("@val"), xtpAdoBigInt, 8, val);
	cmd.Execute();
	val = cmd.GetParamValue(4);
	return val.uintVal;
}

CString TableToView(CString table)
{
	return _T("tv")+table.Mid(2,table.GetLength());
}

CString ViewToTable(CString view)
{
	return _T("tb")+view.Mid(2,view.GetLength());
}

double SumTable(CString table, int idx)
{
	if(!ExistsTable(table)) return 0;

	CString sql;
	_variant_t val;
	CString fid = GetFieldName(table, idx+1);
	sql.Format(_T("%ssp_SumTable"), g_TablePrix);
	CXTPADOCommand cmd(theCon, sql);
	cmd.SetType(CXTPADOCommand::xtpAdoCmdStoredProc);
	cmd.MakeInParam(_T("@tbl"), xtpAdoVarWChar, 20, _variant_t(table));
	cmd.MakeInParam(_T("@fid"), xtpAdoVarWChar, 20, _variant_t(fid));
	cmd.MakeOutParam(_T("@val"), xtpAdoDouble, 8, val);
	cmd.Execute();
	return cmd.GetParamValue(2).dblVal;
}

int AddRecordset(CString table)
{
	if(!ExistsTable(table)) return 0;

	CString fid = GetFieldName(table);
	CString code = CString(GetAutoCode(table).bstrVal);
	CString sql;
	sql.Format(_T("insert into %s[%s] (%s) values ('%s')"), g_TablePrix, table, fid, code);
	return theCon.Execute(sql);
}

int AddRecordset(CString table, CString& code)
{
	if(!ExistsTable(table)) return 0;

	CString fid = GetFieldName(table);
	if(code.GetLength() == 0) code = CString(GetAutoCode(table).bstrVal);
	CString sql;
	sql.Format(_T("insert into %s[%s] (%s) values ('%s')"), g_TablePrix, table, fid, code);
	return theCon.Execute(sql);
}

int AddRecordset(CString table, int& idx)
{
	if(!ExistsTable(table)) return 0;

	CString fid = GetFieldName(table);
	if(idx == 0) idx = GetAutoCode(table).intVal;
	CString sql;
	sql.Format(_T("insert into %s[%s] (%s) values (%d)"), g_TablePrix, table, fid, idx);
	return theCon.Execute(sql);
}

void ResetCode(CString table)
{
	if(!ExistsTable(table)) return;

	CString fid = GetFieldName(table);
	CString sql;
	sql.Format(_T("select %s from %s[%s] order by %s"), fid, g_TablePrix, table, fid);
	CXTPADORecordset rst(theCon);
	rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
	CString val;
	rst.GetFieldValue(0,val);
	CString ch = val.Mid(0,2);
	unsigned long id = 1;
	while (!rst.IsEOF())
	{
		rst.Edit();
		val.Format(_T("%s%8d"),ch,id++);
		rst.SetFieldValue(0,val);
		rst.Update();
		rst.MoveNext();
	}

	rst.Close();
}

void DropTable(CString table)
{
	if(!ExistsTable(table)) return;
	CString sql;
	sql.Format(_T("drop table %s%s"),g_TablePrix, table);
	theCon.Execute(sql);
}

void DeleteTable(CString table)
{
	if(!ExistsTable(table)) return;
	CString sql;
	sql.Format(_T("delete from %s%s"),g_TablePrix, table);
	theCon.Execute(sql);
}

BOOL ResetIdent(CString table, int seed)
{
	CString sql;
	_variant_t ret;
	sql.Format(_T("%ssp_ResetIdent"), g_TablePrix);
	CXTPADOCommand cmd(theCon, sql);
	cmd.SetType(CXTPADOCommand::xtpAdoCmdStoredProc);
	cmd.MakeInParam(_T("@tbl"), xtpAdoVarWChar, 20, _variant_t(table));
	cmd.MakeInParam(_T("@seed"), xtpAdoInteger, 4, seed);
	cmd.MakeOutParam(_T("@ret"), xtpAdoTinyInt, 1, ret);
	cmd.Execute();
	return cmd.GetParamValue(2).bVal;
}

BOOL CopyTable(CString tblOld, CString tblNew)
{
	CString sql;
	_variant_t ret;
	sql.Format(_T("%ssp_CopyTable"), g_TablePrix);
	CXTPADOCommand cmd(theCon, sql);
	cmd.SetType(CXTPADOCommand::xtpAdoCmdStoredProc);
	cmd.MakeInParam(_T("@tblOld"), xtpAdoVarWChar, 30, _variant_t(tblOld));
	cmd.MakeInParam(_T("@tblNew"), xtpAdoVarWChar, 30, _variant_t(tblNew));
	cmd.MakeOutParam(_T("@ret"), xtpAdoTinyInt, 1, ret);
	cmd.Execute();
	return cmd.GetParamValue(2).intVal == 0;
	/*
	int ret = 0;
	if(!ExistsTable(tblOld)) return ret;

	if(ExistsTable(tblNew))
	{
		CString sql;
		sql.Format(_T("delete %s%s insert into %s%s select * from %s%s"),
			        g_TablePrix, tblNew, g_TablePrix, tblNew, g_TablePrix, tblOld);
		ret = theCon.Execute(sql);
	}
	else
	{
		CString sql;
		sql.Format(_T("select * into %s%s from %s%s"),
			g_TablePrix, tblNew, g_TablePrix, tblOld);
		ret = theCon.Execute(sql);
	}

	return ret;
	*/
}

int DelRecordset(CString table, CString val)
{
	if(!ExistsTable(table)) return 0;
	CString fid = GetFieldName(table);
	CString sql;
	sql.Format(_T("delete from %s[%s] where %s like '%s'"), g_TablePrix, table, fid, val);
	return theCon.Execute(sql);
}

void SetRecordset(CString table, CXTPADOData data)
{
	if(!ExistsTable(table)) return;

	CString fid = GetFieldName(table);
	CString sql;
	_variant_t* vals = (_variant_t*)data.vals[1];
	CString code(vals[0].bstrVal);
	sql.Format(_T("select * from %s[%s] where %s = '%s' order by %s"), g_TablePrix, table, fid, code, fid);

	CXTPADORecordset rst(theCon);
	rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
	rst.Edit();
	int cs = data.cols;
	if(rst.GetFieldCount()*rst.GetRecordCount() > 0)
	{
		if(cs == rst.GetFieldCount())
		{
			for(int i=1;i<cs;i++) rst.SetFieldValue(i,vals[i]);
			rst.Update();
			rst.Close();
		}
	}
}

int SetRecordset(CString table, CString fid, CString code, COleVariant val)
{
	if(!ExistsTable(table)) return 0;

	CString sql;
	CString id = GetFieldName(table);
	switch (val.vt)
	{
	case VT_I1:
		sql.Format(_T("update %s[%s] set %s = %i where %s='%s'"), g_TablePrix,table,fid,val.iVal,id,code);
		break;
	case VT_I4:
		sql.Format(_T("update %s[%s] set %s = %d where %s='%s'"), g_TablePrix,table,fid,val.intVal,id,code);
		break;
	case VT_BSTR:
		sql.Format(_T("update %s[%s] set %s = '%s' where %s='%s'"), g_TablePrix,table,fid,CString(val.bstrVal),id,code);
		break;
	case VT_R8:
		sql.Format(_T("update %s[%s] set %s = %.3f where %s='%s'"), g_TablePrix,table,fid,val.dblVal,id,code);
		break;
	case VT_BOOL:
		sql.Format(_T("update %s[%s] set %s = %d where %s='%s'"), g_TablePrix,table,fid,val.boolVal ? 1:0,id,code);
		break;
	case VT_DATE:
		COleDateTime dt(val.date);
		sql.Format(_T("update %s[%s] set %s = '%s' where %s='%s'"), g_TablePrix,table,fid,dt.Format(_T("%Y-%m-%d")),id,code);
		break;
	}
	return theCon.Execute(sql);
}

int SetRecordset(CString table, CString fid, int idx, COleVariant val)
{
	if(!ExistsTable(table)) return 0;

	CString sql;
	CString id = GetFieldName(table);
	switch (val.vt)
	{
	case VT_I1:
		sql.Format(_T("update %s[%s] set %s = %i where %s=%d"), g_TablePrix,table,fid,val.iVal,id,idx);
		break;
	case VT_I4:
		sql.Format(_T("update %s[%s] set %s = %d where %s=%d"), g_TablePrix,table,fid,val.lVal,id,idx);
		break;
	case VT_BSTR:
		sql.Format(_T("update %s[%s] set %s = '%s' where %s=%d"), g_TablePrix,table,fid,CString(val.bstrVal),id,idx);
		break;
	case VT_R8:
		sql.Format(_T("update %s[%s] set %s = %.3f where %s=%d"), g_TablePrix,table,fid,val.dblVal,id,idx);
		break;
	case VT_BOOL:
		sql.Format(_T("update %s[%s] set %s = %d where %s=%d"), g_TablePrix,table,fid,val.boolVal ? 1:0,id,idx);
		break;
	case VT_DATE:
		COleDateTime dt(val.date);
		sql.Format(_T("update %s[%s] set %s = '%s' where %s=%d"), g_TablePrix,table,fid,dt.Format(_T("%Y-%m-%d")),id,idx);
		break;
	}
	return theCon.Execute(sql);
}

void GetRecord(CXTPADOData& data, CString table, CString fids)
{
	if(!ExistsTable(table)) return;

	CString fid = GetFieldName(table);
	CString sql;
	sql.Format(_T("select %s from %s[%s] order by %s"), fids, g_TablePrix, table, fid);

	CXTPADORecordset rst(theCon);
	rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
	long rs = rst.GetRecordCount();
	int cs = rst.GetFieldCount();
	data.row2 = rs-1;
	data.col2 = cs-1;
	data.rows = rs;
	data.cols = cs;
	if(rs*cs > 0)
	{
		_variant_t** val = new _variant_t*[rs];
		for(int i=0;i<rs;i++)
		{
			val[i] = new _variant_t[cs];
			for(int j=0;j<cs;j++) rst.GetFieldValue(j,val[i][j]);
			rst.MoveNext();
		}
		data.vals[0] = val;
	}
	rst.Close();
}

void GetRecord(CXTPADOData& data, CString table, CString code, CString fids)
{
	if(!ExistsTable(table)) return;

	CString fid = GetFieldName(table);
	CString sql;
	sql.Format(_T("select %s from %s[%s] where %s = '%s' order by %s"), fids, g_TablePrix, table, fid, code, fid);
	
	CXTPADORecordset rst(theCon);
	rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
	long rs = rst.GetRecordCount();
	int cs = rst.GetFieldCount();
	data.col2 = cs-1;
	data.rows = 1;
	data.cols = cs;
	if(rs*cs > 0)
	{
		_variant_t* val = new _variant_t[cs];
		for(int i=0;i<cs;i++) rst.GetFieldValue(i,val[i]);
		data.vals[1] = val;
	}

	rst.Close();
}

void GetRecord(CXTPADOData& data, CString table, int idx, CString fids)
{
	if(!ExistsTable(table)) return;

	CString fid = GetFieldName(table);
	CString sql;
	sql.Format(_T("select %s from %s[%s] where %s = %d order by %s"), fids, g_TablePrix, table, fid, idx, fid);

	CXTPADORecordset rst(theCon);
	rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
	long rs = rst.GetRecordCount();
	int cs = rst.GetFieldCount();
	data.col2 = cs-1;
	data.rows = 1;
	data.cols = cs;
	if(rs*cs > 0)
	{
		_variant_t* val = new _variant_t[cs];
		for(int i=0;i<cs;i++) rst.GetFieldValue(i,val[i]);
		data.vals[1] = val;
	}

	rst.Close();
}

void GetRecord(CXTPADOData& data, CString table, CString code1, CString code2, CString fids)
{
	CString fid = GetFieldName(table);
	CString sql;
	sql.Format(_T("select %s from %s[%s] where %s between '%s' and '%s' order by %s"), fids, g_TablePrix, table, fid, code1, code2, fid);
	
	CXTPADORecordset rst(theCon);
	rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
	long rs = rst.GetRecordCount();
	int cs = rst.GetFieldCount();
	data.row2 = rs-1;
	data.col2 = cs-1;
	data.rows = rs;
	data.cols = cs;
	if(rs*cs > 0)
	{
		_variant_t** val = new _variant_t*[rs];
		for(int i=0;i<rs;i++)
		{
			val[i] = new _variant_t[cs];
			for(int j=0;j<cs;j++) rst.GetFieldValue(j,val[i][j]);
			rst.MoveNext();
		}
		data.vals[0] = val;
	}
	rst.Close();
}

void GetRecord(CXTPADOData& data, CString table, int idx1, int idx2, CString fids)
{
	CString fid = GetFieldName(table);
	CString sql;
	sql.Format(_T("select %s from %s[%s] where %s between %d and %d order by %s"), fids, g_TablePrix, table, fid, idx1, idx2, fid);

	CXTPADORecordset rst(theCon);
	rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
	long rs = rst.GetRecordCount();
	int cs = rst.GetFieldCount();
	data.row2 = rs-1;
	data.col2 = cs-1;
	data.rows = rs;
	data.cols = cs;
	if(rs*cs > 0)
	{
		_variant_t** val = new _variant_t*[rs];
		for(int i=0;i<rs;i++)
		{
			val[i] = new _variant_t[cs];
			for(int j=0;j<cs;j++) rst.GetFieldValue(j,val[i][j]);
			rst.MoveNext();
		}
		data.vals[0] = val;
	}
	rst.Close();
}

void SumRecord(CXTPADOData& data, CString table, int idx, CString*& fids)
{
	if(!ExistsTable(table)) return;

	CString fid = GetFieldName(table);
	CString sql,str;
	for(int i=0; i<idx; i++)
	{
		CString s;
		s.Format(_T("sum([%s]), "),fids[i]);
		str += s;
	}
	str = str.Mid(0, str.GetLength() - 2);
	sql.Format(_T("select %s from %s[%s] %s order by %s"), str, g_TablePrix, table, fid);

	CXTPADORecordset rst(theCon);
	rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
	int cs = rst.GetFieldCount();
	data.col2 = cs-1;
	data.rows = 1;
	data.cols = cs;
	if(cs > 0)
	{
		_variant_t* val = new _variant_t[cs];
		for(int i=0;i<cs;i++) rst.GetFieldValue(i,val[i]);
		data.vals[1] = val;
	}
	rst.Close();
}

void FindRecord(CXTPADOData& data, CString table, CString fid, int nSearchDirection)
{
	if(!ExistsTable(table)) return;

	if(fid.IsEmpty()) return;
	CString id = GetFieldName(table);
	CString sql;
	sql.Format(_T("select * from %s[%s] order by %s"), g_TablePrix, table, id);

	CXTPADORecordset rst(theCon);
	rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
	CString fids = theCon.GetFields(table,data.col1,data.col1);
	fid.Format(_T("%s=%s"), fids, fid);

	if(rst.Find(fid, nSearchDirection))
	{
		rst.GetFieldValue(0,data.row1);
		_variant_t val;
		rst.GetFieldValue(data.col2,val);
		data.vals[2] = &val;
	}
	rst.Close();
}

void SetConfig(CString config)
{
	_SetConfig((LPXTPSTR)(LPCTSTR)config);
}

void LogDebug(CString debug)
{
	_LogDebug((LPXTPSTR)(LPCTSTR)debug);
}

void LogDebugExp(CString debug, CException *e)
{
	XTPCHAR szError[1024];
	e->GetErrorMessage(szError,1024);
	_LogDebugExp((LPXTPSTR)(LPCTSTR)debug, szError);
}

void LogInfo(CString info)
{
	_LogInfo((LPXTPSTR)(LPCTSTR)info);
}

void LogInfoExp(CString info, CException *e)
{
	XTPCHAR szError[1024];
	e->GetErrorMessage(szError,1024);
	_LogInfoExp((LPXTPSTR)(LPCTSTR)info, szError);
}

void LogWarn(CString warn)
{
	_LogWarn((LPXTPSTR)(LPCTSTR)warn);
}

void LogWarnExp(CString warn, CException *e)
{
	XTPCHAR szError[1024];
	e->GetErrorMessage(szError,1024);
	_LogWarnExp((LPXTPSTR)(LPCTSTR)warn, szError);
}

void LogError(CString error)
{
	_LogError((LPXTPSTR)(LPCTSTR)error);
}

void LogErrorExp(CString error, CException *e)
{
	XTPCHAR szError[1024];
	e->GetErrorMessage(szError,1024);
	_LogErrorExp((LPXTPSTR)(LPCTSTR)error, szError);
}

void LogFatal(CString fatal)
{
	_LogFatal((LPXTPSTR)(LPCTSTR)fatal);
}

void LogFatalExp(CString fatal, CException *e)
{
	XTPCHAR szError[1024];
	e->GetErrorMessage(szError,1024);
	_LogFatalExp((LPXTPSTR)(LPCTSTR)fatal, szError);
}