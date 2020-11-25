// common.h : header file
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

#if !defined(AFX_COMMON_H__97381D7E_4FD5_48BB_AAA0_91D67C0D9FE5__INCLUDED_)
#define AFX_COMMON_H__97381D7E_4FD5_48BB_AAA0_91D67C0D9FE5__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
#include <vector>

// common.h 公共变量定义

template<class T>
class xtp_vector : public std::vector<T>
{
public:
	xtp_vector() : vector() {}
	xtp_vector(const vector<T>& t) : vector(t) {}
	~xtp_vector() {vector::~vector();}

	template <typename T, size_t N>
	xtp_vector(T(&t)[N])
	{
		int n = xtpcountof(t);
		for(int i=0; i<n; i++)
			push_back(t[i]);
	}

	xtp_vector(const xtp_vector<T>& t)
	{
		clear();
		for (size_t i=0;i<t.size();i++)
		{
			push_back(t[i]);
		}
	}

	template <typename T, size_t N>
	xtp_vector& operator=(T(&t)[N])
	{
		int n = xtpcountof(t);
		for(int i=0; i<n; i++)
			push_back(t[i]);

		return *this;
	}

	xtp_vector& operator=(const vector<T>& t)
	{
		clear();
		for (size_t i=0;i<t.size();i++)
		{
			push_back(t[i]);
		}

		return *this;
	}

	xtp_vector& operator=(const xtp_vector<T>& t)
	{
		clear();
		for (size_t i=0;i<t.size();i++)
		{
			push_back(t[i]);
		}

		return *this;
	}

	T& operator [](const int i)
	{
		return at(i);
	}

	operator vector<T>() const
	{
		vector<T> t;
		for (int i=0;i<size();i++)
		{
			t.push_back(at(i));
		}

		return t;
	}

	operator T*() const
	{
		T* t = new T[size()];
		for (size_t i=0;i<size();i++)
		{
			t[i] = at(i);
		}

		return t;
	}

public:
	int contains(T t)
	{
		size_t i=0;
		size_t index=0;
		for (i=0;i<size();i++)
		{
			if(at(i)==t) index++;
		}
		return index;
	}

	int count() const
	{
		return size();
	}

	void append(T t)
	{
		if(!contains(t)) push_back(t);
	}

	void remove(T t)
	{
		size_t i=0;
		for (i=0;i<size();i++)
		{
			if(at(i) == t)
				break;
		}
		erase(i);
	}
};

struct ado_users
{
public:
	CString id;
	CString sysuser;
	CString password;
	CString md5pwd;
	CString cip;
	int cport;
	CString sip;
	int sport;
	int state;
	bool advanced;
	bool remberpwd;
	bool autologin;
	bool autoframe;


	ado_users()
	{
		id = _T("SYS00");
		sysuser = _T("admin");
		password = _T("admin");
		md5pwd = _T("");
		cip = _T("127.0.0.1");
		cport = 51000;
		sip = _T("127.0.0.1");
		sport = 50000;
		state = 12;
		advanced = false;
		remberpwd = false;
		autologin = false;
		autoframe = false;
	}

	ado_users(const ado_users& src)
	{
		id = src.id;
		sysuser = src.sysuser;
		password = src.password;
		md5pwd = src.md5pwd;
		cip = src.cip;
		cport = src.cport;
		sip = src.sip;
		sport = src.sport;
		state = src.state;
		advanced = src.advanced;
		remberpwd = src.remberpwd;
		autologin = src.autologin;
		autoframe = src.autoframe;
	}

	ado_users(CXTPADORecordset& rst)
	{
		if(rst.GetRecordCount() && rst.GetFieldCount() == 13)
		{
			rst.GetFieldValue(0,id);
			rst.GetFieldValue(1,sysuser);
			rst.GetFieldValue(2,password);
			rst.GetFieldValue(3,md5pwd);
			rst.GetFieldValue(4,cip);
			rst.GetFieldValue(5,cport);
			rst.GetFieldValue(6,sip);
			rst.GetFieldValue(7,sport);
			rst.GetFieldValue(8,state);
			rst.GetFieldValue(9,advanced);
			rst.GetFieldValue(10,remberpwd);
			rst.GetFieldValue(11,autologin);
			rst.GetFieldValue(12,autoframe);
		}
	}

	ado_users& operator = (const ado_users& src)
	{
		id = src.id;
		sysuser = src.sysuser;
		password = src.password;
		md5pwd = src.md5pwd;
		cip = src.cip;
		cport = src.cport;
		sip = src.sip;
		sport = src.sport;
		state = src.state;
		advanced = src.advanced;
		remberpwd = src.remberpwd;
		autologin = src.autologin;
		autoframe = src.autoframe;
		return *this;
	}

	ado_users& operator = (CXTPADORecordset& rst)
	{
		if(rst.GetRecordCount() && rst.GetFieldCount() == 13)
		{
			rst.GetFieldValue(0,id);
			rst.GetFieldValue(1,sysuser);
			rst.GetFieldValue(2,password);
			rst.GetFieldValue(3,md5pwd);
			rst.GetFieldValue(4,cip);
			rst.GetFieldValue(5,cport);
			rst.GetFieldValue(6,sip);
			rst.GetFieldValue(7,sport);
			rst.GetFieldValue(8,state);
			rst.GetFieldValue(9,advanced);
			rst.GetFieldValue(10,remberpwd);
			rst.GetFieldValue(11,autologin);
			rst.GetFieldValue(12,autoframe);
		}

		return *this;
	}
};

struct xls_variant
{
public:
	int row,col;
	int id;
	VARIANT val;
	DWORD_PTR tag;

	xls_variant()
	{
		row=0;
		col=0;
		id=0;
		val.vt=VT_EMPTY;
		tag=NULL;
	}

	xls_variant(VARIANT _val,int _id=0,int _row=0,int _col=0,DWORD_PTR _tag=NULL)
	{
		row=_row;
		col=_col;
		id=_id;
		val=_val;
		tag=_tag;
	}

	xls_variant(const xls_variant& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		tag=src.tag;
	}

	xls_variant& operator = (const xls_variant& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		tag=src.tag;
		return *this;
	}

	bool operator<(const xls_variant& src) const
	{
		if (id < src.id)
			return true;

		return false;
	}

	bool operator>(const xls_variant& src) const
	{
		if (id > src.id)
			return true;

		return false;
	}

	bool operator==(const xls_variant& src) const
	{
		if (id == src.id)
			return true;

		return false;
	}

	bool operator<=(const xls_variant& src) const
	{
		if (id <= src.id)
			return true;

		return false;
	}

	bool operator>=(const xls_variant& src) const
	{
		if (id >= src.id)
			return true;

		return false;
	}

	bool operator!=(const xls_variant& src) const
	{
		if (id != src.id)
			return true;

		return false;
	}
};

struct xls_int
{
public:
	int row,col;
	int id;
	int val;
	DWORD_PTR tag;

	xls_int()
	{
		row=0;
		col=0;
		id=0;
		val=0;
		tag=NULL;
	}

	xls_int(int _val,int _id=0,int _row=0,int _col=0,DWORD_PTR _tag=NULL)
	{
		row=_row;
		col=_col;
		id=_id;
		val=_val;
		tag=_tag;
	}

	xls_int(const xls_int& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		tag=src.tag;
	}

	xls_int& operator = (const xls_int& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		return *this;
	}

	bool operator<(const xls_int& src) const
	{
		if (val < src.val)
			return true;

		return false;
	}

	bool operator>(const xls_int& src) const
	{
		if (val > src.val)
			return true;

		return false;
	}

	bool operator==(const xls_int& src) const
	{
		if (val == src.val)
			return true;

		return false;
	}

	bool operator<=(const xls_int& src) const
	{
		if (val <= src.val)
			return true;

		return false;
	}

	bool operator>=(const xls_int& src) const
	{
		if (val >= src.val)
			return true;

		return false;
	}

	bool operator!=(const xls_int& src) const
	{
		if (val != src.val)
			return true;

		return false;
	}
};

struct xls_double
{
public:
	int row,col;
	int id;
	double val;
	DWORD_PTR tag;

	xls_double()
	{
		row=0;
		col=0;
		id=0;
		val=0;
		tag=NULL;
	}

	xls_double(double _val,int _id=0,int _row=0,int _col=0,DWORD_PTR _tag=NULL)
	{
		row=_row;
		col=_col;
		id=_id;
		val=_val;
		tag=_tag;
	}

	xls_double(const xls_double& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		tag=src.tag;
	}

	xls_double& operator = (const xls_double& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		tag=src.tag;
		return *this;
	}

	bool operator<(const xls_double& src) const
	{
		if (abs(val-src.val) < 0.0000001)
			return false;
		else if(val < src.val)
			return true;

		return false;
	}

	bool operator>(const xls_double& src) const
	{
		if (abs(val-src.val) < 0.0000001)
			return false;
		else if(val > src.val)
			return true;

		return false;
	}

	bool operator==(const xls_double& src) const
	{
		if (abs(val-src.val) < 0.0000001)
			return true;

		return false;
	}

	bool operator<=(const xls_double& src) const
	{
		if (abs(val-src.val) < 0.0000001 || val < src.val)
			return true;

		return false;
	}

	bool operator>=(const xls_double& src) const
	{
		if (abs(val-src.val) < 0.0000001 || val > src.val)
			return true;

		return false;
	}

	bool operator!=(const xls_double& src) const
	{
		if (abs(val-src.val) > 0.0000001)
			return true;

		return false;
	}
};

struct xls_string
{
public:
	int row,col;
	int id;
	CString val;
	DWORD_PTR tag;

	xls_string()
	{
		row=0;
		col=0;
		id=0;
		val.Empty();
		tag=NULL;
	}

	xls_string(CString _val,int _id=0,int _row=0,int _col=0,DWORD_PTR _tag=NULL)
	{
		row=_row;
		col=_col;
		id=_id;
		val=_val;
		tag=_tag;
	}

	xls_string(const xls_string& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		tag=src.tag;
	}

	xls_string& operator = (const xls_string& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		tag=src.tag;
		return *this;
	}

	bool operator<(const xls_string& src) const
	{
		return val.Compare(src.val) == -1;
	}

	bool operator>(const xls_string& src) const
	{
		return val.Compare(src.val) == 1;
	}

	bool operator==(const xls_string& src) const
	{
		return val.Compare(src.val) == 0;
	}

	bool operator<=(const xls_string& src) const
	{
		return val.Compare(src.val) < 1;
	}

	bool operator>=(const xls_string& src) const
	{
		return val.Compare(src.val) > -1;
	}

	bool operator!=(const xls_string& src) const
	{
		return val.Compare(src.val) != 0;
	}
};

struct xls_datetime
{
public:
	int row,col;
	int id;
	COleDateTime val;
	DWORD_PTR tag;

	xls_datetime()
	{
		row=0;
		col=0;
		id=0;
		val=COleDateTime::GetCurrentTime();
		tag=NULL;
	}

	xls_datetime(COleDateTime _val,int _id=0,int _row=0,int _col=0,DWORD_PTR _tag=NULL)
	{
		row=_row;
		col=_col;
		id=_id;
		val=_val;
		tag=_tag;
	}

	xls_datetime(const xls_datetime& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		tag=src.tag;
	}

	xls_datetime& operator = (const xls_datetime& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		tag=src.tag;
		return *this;
	}

	bool operator<(const xls_datetime& src) const
	{
		return val < src.val;
	}

	bool operator>(const xls_datetime& src) const
	{
		return val > src.val;
	}

	bool operator==(const xls_datetime& src) const
	{
		return val == src.val;
	}

	bool operator<=(const xls_datetime& src) const
	{
		return val <= src.val;
	}

	bool operator>=(const xls_datetime& src) const
	{
		return val >= src.val;
	}

	bool operator!=(const xls_datetime& src) const
	{
		return val != src.val;
	}
};

struct xls_constlog
{
public:
	int row,col;
	int id;
	COleDateTime val;
	CString work,posi,unit;
	double qty;
	DWORD_PTR tag;

	xls_constlog()
	{
		row=0;
		col=0;
		id=0;
		val=COleDateTime::GetCurrentTime();
		posi.Empty();
		unit.Empty();
		qty=0;
		tag=NULL;
	}

	xls_constlog(COleDateTime _val, int _row,int _col,CString _work,CString _posi,CString _unit=_T(""),double _qty=0,int _id=-1,DWORD_PTR _tag=NULL)
	{
		row=_row;
		col=_col;
		id=_id;
		val=_val;
		work=_work;
		posi=_posi;
		unit=_unit;
		qty=_qty;
		tag=_tag;
	}

	xls_constlog(const xls_constlog& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		work=src.work;
		posi=src.posi;
		unit=src.unit;
		qty=src.qty;
		tag=src.tag;
	}

	xls_constlog& operator = (const xls_constlog& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		work=src.work;
		posi=src.posi;
		unit=src.unit;
		qty=src.qty;
		tag=src.tag;
		return *this;
	}

	bool operator<(const xls_constlog& src) const
	{
		return val < src.val;
	}

	bool operator>(const xls_constlog& src) const
	{
		return val > src.val;
	}

	bool operator==(const xls_constlog& src) const
	{
		return val == src.val;
	}

	bool operator<=(const xls_constlog& src) const
	{
		return val <= src.val;
	}

	bool operator>=(const xls_constlog& src) const
	{
		return val >= src.val;
	}

	bool operator!=(const xls_constlog& src) const
	{
		return val != src.val;
	}
};

struct xls_logconst
{
public:
	int row,col;
	int id;
	CString val;
	CString work,posi,unit;
	double qty;
	DWORD_PTR tag;

	xls_logconst()
	{
		row=0;
		col=0;
		id=0;
		val.Empty();
		work.Empty();
		posi.Empty();
		unit.Empty();
		qty=0;
	}

	xls_logconst(CString _val,int _row,int _col,CString _work,CString _posi,CString _unit=_T(""),double _qty=0,int _id=-1,DWORD_PTR _tag=NULL)
	{
		row=_row;
		col=_col;
		id=_id;
		val=_val;
		posi=_posi;
		work=_work;
		unit=_unit;
		qty=_qty;
		tag=_tag;
	}

	xls_logconst(const xls_logconst& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		work=src.work;
		posi=src.posi;
		unit=src.unit;
		qty=src.qty;
		tag=src.tag;
	}

	xls_logconst& operator = (const xls_logconst& src)
	{
		row=src.row;
		col=src.col;
		id=src.id;
		val=src.val;
		work=src.work;
		posi=src.posi;
		unit=src.unit;
		qty=src.qty;
		tag=src.tag;
		return *this;
	}

	bool operator<(const xls_logconst& src) const
	{
		return val.Compare(src.val) == -1;
	}

	bool operator>(const xls_logconst& src) const
	{
		return val.Compare(src.val) == 1;
	}

	bool operator==(const xls_logconst& src) const
	{
		return val.Compare(src.val) == 0;
	}

	bool operator<=(const xls_logconst& src) const
	{
		return val.Compare(src.val) < 1;
	}

	bool operator>=(const xls_logconst& src) const
	{
		return val.Compare(src.val) > -1;
	}

	bool operator!=(const xls_logconst& src) const
	{
		return val.Compare(src.val) != 0;
	}
};

struct xls_budget
{
public:
	int id;
	CString code;
	CString name;
	CString unit;
	double qty;
	double price;

	xls_budget()
	{
		id=0;
		qty=price=0;
		code.Empty();
		name.Empty();
		unit.Empty();
	}

	xls_budget(int _id, CString _code, CString _name, CString _unit, double _qty, double _price)
	{
		id=_id;
	 	code=_code;
		name=_name;
		unit=_unit;
		qty=_qty;
		price=_price;
	}

	xls_budget(const xls_budget& src)
	{
		id=src.id;
		code=src.code;
		name=src.name;
		unit=src.unit;
		qty=src.qty;
		price=src.price;
	}

	xls_budget& operator = (const xls_budget& src)
	{
		id=src.id;
		code=src.code;
		name=src.name;
		unit=src.unit;
		qty=src.qty;
		price=src.price;
		return *this;
	}

	bool operator<(const xls_budget& src) const
	{
		if (id < src.id)
			return true;

		return false;
	}

	bool operator>(const xls_budget& src) const
	{
		if (id > src.id)
			return true;

		return false;
	}

	bool operator==(const xls_budget& src) const
	{
		if (id == src.id)
			return true;

		return false;
	}

	bool operator<=(const xls_budget& src) const
	{
		if (id <= src.id)
			return true;

		return false;
	}

	bool operator>=(const xls_budget& src) const
	{
		if (id >= src.id)
			return true;

		return false;
	}

	bool operator!=(const xls_budget& src) const
	{
		if (id != src.id)
			return true;

		return false;
	}
};

struct xls_treenode
{
public:
	int id;
	int pid;
	int lv;
	CString node;

	xls_treenode()
	{
		id=0;
		pid=0;
		lv=0;
	}

	xls_treenode(int _id, int _pid, int _lv, CString _node)
	{
		id=_id;
		pid=_pid;
		lv=_lv;
		node=_node;
	}

	xls_treenode(const xls_treenode& src)
	{
		id=src.id;
		pid=src.pid;
		lv=src.lv;
		node=src.node;
	}

	xls_treenode& operator = (const xls_treenode& src)
	{
		id=src.id;
		pid=src.pid;
		lv=src.lv;
		node=src.node;
		return *this;
	}

	bool operator<(const xls_treenode& src) const
	{
		if (id < src.id)
			return true;

		return false;
	}

	bool operator>(const xls_treenode& src) const
	{
		if (id > src.id)
			return true;

		return false;
	}

	bool operator==(const xls_treenode& src) const
	{
		if (id == src.id)
			return true;

		return false;
	}

	bool operator<=(const xls_treenode& src) const
	{
		if (id <= src.id)
			return true;

		return false;
	}

	bool operator>=(const xls_treenode& src) const
	{
		if (id >= src.id)
			return true;

		return false;
	}

	bool operator!=(const xls_treenode& src) const
	{
		if (id != src.id)
			return true;

		return false;
	}

	static int FindTreeId(xtp_vector<xls_treenode>& vecNode, int lv)
	{
		for(int i=vecNode.size()-1; i>=0; i--)
		{
			if(lv >= vecNode[i].lv)
				return vecNode[i].id;
		}

		return -1;
	}

	static xls_treenode& FindTreeNode(xtp_vector<xls_treenode>& vecNode, int id)
	{
		int left = 0;
		int right = vecNode.size();
		int mid = (left+right)/2;
		int _id = vecNode[mid].id;
		while(_id != id)
		{
			if(_id > id)
				right = mid;
			else
				left = mid;

			mid = (left+right)/2;
			_id = vecNode[mid].id;
		}

		return vecNode[mid];
	}
};

extern CString g_ServerIp;
extern CString g_SysUid;
extern CString g_SysUser;
extern CString g_SysPwd;
extern bool g_SysRemberPwd;
extern bool g_SysAutoLogin;
extern bool g_SysAutoFrame;
extern CString g_DataBase;
extern CString g_TablePrix;
extern CString g_SqlPrix;

extern void InitCommon();
extern const char* ToColumnLabel(int col);
extern const char* ToRangeLabel(long row_begin, int col_begin, long row_end, int col_end);
extern double Round(double fA, int nB = 3);
extern BOOL Bound(double fA, double fB, double fC, int nType = 0);
extern void ArraySort(xtp_vector<xls_variant>& arr, int nSortType=1);
extern int ArraySearch(xtp_vector<xls_variant>& arr,int id);
extern int ArrayInsert(xtp_vector<xls_variant>& arr,xls_variant val);
//1、K#+###.###  2、+###.###  3、K#  4、+#  5、K#+### 6、K#+###.##  7、K#+###.#  8、+###.##  9、+###.#
extern CString FormatStat(double fStat, int mode = 1, CString prefix = _T("D"));
//1、%Y/%m/%d %H:%M:%S  2、%Y/%m/%d  3、%H:%M:%S
extern CString FormatDateTime(COleDateTime dt, int mode = 1);
extern COleDateTime ParseDateTime(CString dt, int mode = 1);
extern CString ToString(double fValue, int nPrec = 3);
extern CString NumToBinary(int nNum);
extern CString GetCurPath();
extern BOOL FileExist(CString strFilePath);
extern BOOL ReNameFile(CString strFilePath, CString strNewFilePath);
extern BOOL DirExist(CString strDirPath);
extern BOOL ModifyDir(CString strDirPath, BOOL bCreate=TRUE);
extern void CreateArray(CStringArray& array, LPCTSTR lpszList, char ch = ';');
extern CString LoadResourceString(UINT nID);
extern CString GetDefineID(UINT nID);
extern HINSTANCE ShellExecuteOpen(CXTPString fileName, CXTPString exeName = "");
extern CXTPString EnCodeStr(CXTPString enCode);
extern CXTPString DeCodeStr(CXTPString deCode);
extern CXTPString RegGetString(HKEY hKey, LPCXTPSTR subKey, LPCXTPSTR name);
extern int RegPutString(HKEY hKey, LPCXTPSTR subKey, LPCXTPSTR name, LPCXTPSTR val);
extern int RegGetInt(HKEY hKey, LPCXTPSTR subKey, LPCXTPSTR name);
extern int RegPutInt(HKEY hKey, LPCXTPSTR subKey, LPCXTPSTR name, int val);
extern CXTPString CpuSerial();
extern CXTPString DiskSerial();
extern CXTPString MacAddress();
extern CXTPString SnKey(CXTPString SnCode);

//数据库处理
extern BOOL DataBackup(CString data, CString path);
extern BOOL DataRestore(CString data, CString path);
extern int DataClear();
extern int ExecuteSql(CString sql);
extern XTPREPORTMSADODB::_RecordsetPtr ExecuteRst(CString sql);
extern int ExecuteProcedureSql(CString sp);
extern XTPREPORTMSADODB::_RecordsetPtr ExecuteProcedureRst(CString sp);

//用户信息
extern int Login();
extern int FindSysUid(ado_users& src);
extern int SetSysStatus(bool remberpwd = true, bool autologin = false, bool advanced = false, bool autoframe = false, bool stat = true);
extern int AddSysUser();
extern int SetSysPwd();
extern int DelSysUser();

// 获取数据信息
extern BOOL ExistsTable(CString table);
extern long CountField(CString table, CString field, CString cond1, CString cond2=_T(""));
extern XTPREPORTMSADODB::_RecordsetPtr GetRecordset(CString table, CString fids = _T(""), CString sql = _T(""));
extern CXTPADORecordset GetRecordset(CXTPADOConnection con, CString table, CString fids = _T(""), CString sql = _T(""));
extern void RequeryRecordset(XTPREPORTMSADODB::_RecordsetPtr rst);
extern void ResyncRecordset(XTPREPORTMSADODB::_RecordsetPtr rst);
extern COleVariant GetAutoCode(CString table);
extern CString GetFieldName(CString table, int idx = 1);
extern xtp_vector<CString> GetTableName(CXTPADOConnection con);
extern xtp_vector<CString> GetFieldName(CXTPADOConnection con, CString table);
extern CString TableToView(CString table);
extern CString ViewToTable(CString view);
extern double SumTable(CString table, int idx);
extern int AddRecordset(CString table);
extern int AddRecordset(CString table, CString& code);
extern int AddRecordset(CString table, int& idx);
extern void ResetCode(CString table);
extern void DropTable(CString table);
extern void DeleteTable(CString table);
extern BOOL ResetIdent(CString table, int seed);
extern BOOL CopyTable(CString tblOld, CString tblNew);
extern int DelRecordset(CString table, CString val);
extern void SetRecordset(CString table, CXTPADOData data);
extern int SetRecordset(CString table, CString fid, CString code, COleVariant val);
extern int SetRecordset(CString table, CString fid, int idx, COleVariant val);
extern void GetRecord(CXTPADOData& data, CString table, CString fids);
extern void GetRecord(CXTPADOData& data, CString table, CString code, CString fids);
extern void GetRecord(CXTPADOData& data, CString table, int idx, CString fids);
extern void GetRecord(CXTPADOData& data, CString table, CString code1, CString code2, CString fids);
extern void GetRecord(CXTPADOData& data, CString table, int idx1, int idx2, CString fids);
extern void SumRecord(CXTPADOData& data, CString tbl, int idx, CString*& fids);
extern void FindRecord(CXTPADOData& data, CString tbl, CString strFind, int nSearchDirection);

extern void LogDebug(CString debug);
extern void LogDebugExp(CString debug, CException *e);
extern void SetConfig(CString config);
extern void LogInfo(CString info);
extern void LogInfoExp(CString info, CException *e);
extern void LogWarn(CString warn);
extern void LogWarnExp(CString warn, CException *e);
extern void LogError(CString error);
extern void LogErrorExp(CString error, CException *e);
extern void LogFatal(CString fatal);
extern void LogFatalExp(CString fatal, CException *e);

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_COMMON_H__97381D7E_4FD5_48BB_AAA0_91D67C0D9FE5__INCLUDED_)
