// TreeCtrlAction.h: interface for the CTreeCtrlAction class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_TREECTRLACTION_H__6C481840_FE83_4798_9524_1A01F1FB13DB__INCLUDED_)
#define AFX_TREECTRLACTION_H__6C481840_FE83_4798_9524_1A01F1FB13DB__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000


typedef struct STRU_QTY
{
public:
	char *rnk;
	char *mut;
	char *bud;
	double qty;
	double qty1;
	double qty2;
	double qty3;

	STRU_QTY()
	{
		rnk = "rnk";
		mut = "mut";
		bud = "bud";
		qty = qty1 = qty2 = qty3 = 0;
	}

	STRU_QTY(const char *_rnk, const char *_mut, const char *_bud, double _qty, double _qty1, double _qty2, double _qty3)
	{
		rnk = const_cast<char*>(_rnk);
		mut = const_cast<char*>(_mut);
		bud = const_cast<char*>(_bud);
		qty = _qty;
		qty1 = _qty1;
		qty2 = _qty2;
		qty3 = _qty3;
	}

	STRU_QTY(const char *_rnk, const char *_mut, double _qty)
	{
		rnk = const_cast<char*>(_rnk);
		mut = const_cast<char*>(_mut);
		qty = _qty;
		bud = "bud";
		qty1 = qty2 = qty3 = 0;
	}

	STRU_QTY(const char *_rnk, const char *_mut, const char *_bud, double _qty)
	{
		rnk = const_cast<char*>(_rnk);
		mut = const_cast<char*>(_mut);
		bud = const_cast<char*>(_bud);
		qty = _qty;
		qty1 = qty2 = qty3 = 0;
	}

	STRU_QTY(const STRU_QTY& src)
	{
		rnk = const_cast<char*>(src.rnk);
		mut = const_cast<char*>(src.mut);
		bud = const_cast<char*>(src.bud);
		qty = src.qty;
		qty1 = src.qty1;
		qty2 = src.qty2;
		qty3 = src.qty3;
	}

	STRU_QTY& operator = (const STRU_QTY& src)
	{
		rnk = const_cast<char*>(src.rnk);
		mut = const_cast<char*>(src.mut);
		bud = const_cast<char*>(src.bud);
		qty = src.qty;
		qty1 = src.qty1;
		qty2 = src.qty2;
		qty3 = src.qty3;
		return *this;
	}

	XTPJSON::Value ToJson()
	{
		XTPJSON::Value val;

		val["rnk"] = const_cast<char*>(rnk);
		val["mut"] = const_cast<char*>(mut);
		val["bud"] = const_cast<char*>(bud);
		val["qty"] = qty;
		val["qty1"] = qty1;
		val["qty2"] = qty2;
		val["qty3"] = qty3;

		return val;
	}

	char* WriteJson() const
	{
		XTPJSON::Value val;

		val["rnk"] = const_cast<char*>(rnk);
		val["mut"] = const_cast<char*>(mut);
		val["bud"] = const_cast<char*>(bud);
		val["qty"] = qty;
		val["qty1"] = qty1;
		val["qty2"] = qty2;
		val["qty3"] = qty3;

		XTPJSON::FastWriter writer;
		string json = writer._write(val);

		return const_cast<char*>(json.c_str());
	}

	bool ReadJson(const char *json)
	{
		XTPJSON::Reader reader;
		XTPJSON::Value val;

		if (!reader.parse(json, val, false))
			return false;

		if (!val["rnk"].isNull())
		{
			string _rnk = val["rnk"].asString();
			rnk = const_cast<char*>(_rnk.c_str());
		}
		if (!val["mut"].isNull())
		{
			string _mut = val["mut"].asString();
			mut = const_cast<char*>(_mut.c_str());
		}
		if (!val["bud"].isNull())
		{
			string _bud = val["bud"].asString();
			bud = const_cast<char*>(_bud.c_str());
		}
		qty = val["qty"].asDouble();
		qty1 = val["qty1"].asDouble();
		qty2 = val["qty2"].asDouble();
		qty3 = val["qty3"].asDouble();

		return true;
	}

	void ReadJson(XTPJSON::Value val)
	{
		if (!val["rnk"].isNull())
		{
			string _rnk = val["rnk"].asString();
			rnk = const_cast<char*>(_rnk.c_str());
		}
		if (!val["mut"].isNull())
		{
			string _mut = val["mut"].asString();
			mut = const_cast<char*>(_mut.c_str());
		}
		if (!val["bud"].isNull())
		{
			string _bud = val["bud"].asString();
			bud = const_cast<char*>(_bud.c_str());
		}
		qty = val["qty"].asDouble();
		qty1 = val["qty1"].asDouble();
		qty2 = val["qty2"].asDouble();
		qty3 = val["qty3"].asDouble();
	}
} TVTAGQTY,*LPTVTAGQTY;

typedef map<LPCSTR, TVTAGQTY> MAPTAGQTY;
typedef pair<LPCSTR, TVTAGQTY> PAIRTAGQTY;
typedef struct STRU_ACTION_TAG
{
public:
	int id,pid,lv,spi;
	int ids[7];
	COleDateTime  bdt,_bdt;
	COleDateTime edt,_edt;
	MAPTAGQTY qty;
	MAPTAGQTY lab;
	MAPTAGQTY dev;
	MAPTAGQTY mat;

	DWORD_PTR tag;

	STRU_ACTION_TAG()
	{
		id = pid = lv = spi = -1;
		ids[0] = ids[1] = ids[2] = ids[3] = ids[4] = ids[5] = -1;
		bdt = _bdt = COleDateTime::GetCurrentTime();
		edt = _edt = COleDateTime::GetCurrentTime();
		qty.clear(); lab.clear(); dev.clear(); mat.clear();
		tag = NULL;
	}

	STRU_ACTION_TAG(int _id, int _pid, int _lv, int _spi, int _id1, int _id2, int _id3, int _id4, int _id5, int _id6, int _id7, COleDateTime &_bdt1, COleDateTime &_edt1, COleDateTime &_bdt2, COleDateTime &_edt2, MAPTAGQTY &_qty, MAPTAGQTY &_lab, MAPTAGQTY &_dev, MAPTAGQTY &_mat, DWORD_PTR _tag)
	{
		id = _id;
		pid = _pid;
		lv = _lv;
		spi = _spi;
		ids[0] = _id1;
		ids[1] = _id2;
		ids[2] = _id3;
		ids[3] = _id4;
		ids[4] = _id5;
		ids[5] = _id6;
		ids[6] = _id7;
		bdt = _bdt1;
		edt = _edt1;
		_bdt = _bdt2;
		_edt = _edt2;
		qty = _qty;
		lab = _lab;
		dev = _dev;
		mat = _mat;
		tag = _tag;
	}

	STRU_ACTION_TAG(const STRU_ACTION_TAG& src)
	{
		id = src.id;
		pid = src.pid;
		lv = src.lv;
		spi = src.spi;
		ids[0] = src.ids[0];
		ids[1] = src.ids[1];
		ids[2] = src.ids[2];
		ids[3] = src.ids[3];
		ids[4] = src.ids[4];
		ids[5] = src.ids[5];
		ids[6] = src.ids[6];
		bdt = src.bdt;
		edt = src.edt;
		_bdt = src._bdt;
		_edt = src._edt;
		qty = src.qty;
		lab = src.lab;
		dev = src.dev;
		mat = src.mat;
		tag = src.tag;
	}

	STRU_ACTION_TAG& operator = (const STRU_ACTION_TAG& src)
	{
		id = src.id;
		pid = src.pid;
		lv = src.lv;
		spi = src.spi;
		ids[0] = src.ids[0];
		ids[1] = src.ids[1];
		ids[2] = src.ids[2];
		ids[3] = src.ids[3];
		ids[4] = src.ids[4];
		ids[5] = src.ids[5];
		ids[6] = src.ids[6];
		bdt = src.bdt;
		edt = src.edt;
		_bdt = src._bdt;
		_edt = src._edt;
		qty = src.qty;
		lab = src.lab;
		dev = src.dev;
		mat = src.mat;
		tag = src.tag;

		return *this;
	}

	XTPJSON::Value ToJson()
	{
		XTPJSON::Value val;
		val["id"] = id;
		val["pid"] = pid;
		val["lv"] = lv;
		val["spi"] = spi;
		val["id1"] = ids[0];
		val["id2"] = ids[1];
		val["id3"] = ids[2];
		val["id4"] = ids[3];
		val["id5"] = ids[4];
		val["id6"] = ids[5];
		val["id7"] = ids[6];
		val["bdt"] = CXTPString(FormatDateTime(bdt)).c_ptr();
		val["edt"] = CXTPString(FormatDateTime(edt)).c_ptr();
		val["_bdt"] = CXTPString(FormatDateTime(_bdt)).c_ptr();
		val["_edt"] = CXTPString(FormatDateTime(_edt)).c_ptr();
		MAPTAGQTY::iterator _iterQty = qty.begin();
		PAIRTAGQTY _pairQty = *_iterQty;
		XTPJSON::Value _qty;
		while(_iterQty != qty.end())
		{
			XTPJSON::Value _val;
			_pairQty = *_iterQty++;
			_val["key"] = const_cast<char*>(_pairQty.first);
			_val["val"] = _pairQty.second.ToJson();
			_qty.append(_val);
		}
		val["qty"] = _qty;

		MAPTAGQTY::iterator _iterLab = lab.begin();
		PAIRTAGQTY _pairLab = *_iterLab;
		XTPJSON::Value _lab;
		while(_iterLab != lab.end())
		{
			XTPJSON::Value _val;
			_pairLab = *_iterLab++;
			_val["key"] = const_cast<char*>(_pairLab.first);
			_val["val"] = _pairLab.second.ToJson();
			_lab.append(_val);
		}
		val["lab"] = _lab;

		MAPTAGQTY::iterator _iterDev = dev.begin();
		PAIRTAGQTY _pairDev = *_iterDev;
		XTPJSON::Value _dev;
		while(_iterDev != dev.end())
		{
			XTPJSON::Value _val;
			_pairDev = *_iterDev++;
			_val["key"] = const_cast<char*>(_pairDev.first);
			_val["val"] = _pairDev.second.ToJson();
			_dev.append(_val);
		}
		val["dev"] = _dev;

		MAPTAGQTY::iterator _iterMat = mat.begin();
		PAIRTAGQTY _pairMat = *_iterMat;
		XTPJSON::Value _mat;
		while(_iterMat != mat.end())
		{
			XTPJSON::Value _val;
			_pairMat = *_iterMat++;
			_val["key"] = const_cast<char*>(_pairMat.first);
			_val["val"] = _pairMat.second.ToJson();
			_mat.append(_val);
		}
		val["mat"] = _mat;

		return val;
	}

	char* WriteJson()
	{
		XTPJSON::Value val;
		val["id"] = id;
		val["pid"] = pid;
		val["lv"] = lv;
		val["spi"] = spi;
		val["id1"] = ids[0];
		val["id2"] = ids[1];
		val["id3"] = ids[2];
		val["id4"] = ids[3];
		val["id5"] = ids[4];
		val["id6"] = ids[5];
		val["id7"] = ids[6];
		val["bdt"] = CXTPString(FormatDateTime(bdt)).c_ptr();
		val["edt"] = CXTPString(FormatDateTime(edt)).c_ptr();
		val["_bdt"] = CXTPString(FormatDateTime(_bdt)).c_ptr();
		val["_edt"] = CXTPString(FormatDateTime(_edt)).c_ptr();
		MAPTAGQTY::iterator _iterQty = qty.begin();
		PAIRTAGQTY _pairQty = *_iterQty;
		XTPJSON::Value _qty;
		while(_iterQty != qty.end())
		{
			XTPJSON::Value _val;
			_pairQty = *_iterQty++;
			_val["key"] = const_cast<char*>(_pairQty.first);
			_val["val"] = _pairQty.second.ToJson();
			_qty.append(_val);
		}
		val["qty"] = _qty;

		MAPTAGQTY::iterator _iterLab = lab.begin();
		PAIRTAGQTY _pairLab = *_iterLab;
		XTPJSON::Value _lab;
		while(_iterLab != lab.end())
		{
			XTPJSON::Value _val;
			_pairLab = *_iterLab++;
			_val["key"] = const_cast<char*>(_pairLab.first);
			_val["val"] = _pairLab.second.ToJson();
			_lab.append(_val);
		}
		val["lab"] = _lab;

		MAPTAGQTY::iterator _iterDev = dev.begin();
		PAIRTAGQTY _pairDev = *_iterDev;
		XTPJSON::Value _dev;
		while(_iterDev != dev.end())
		{
			XTPJSON::Value _val;
			_pairDev = *_iterDev++;
			_val["key"] = const_cast<char*>(_pairDev.first);
			_val["val"] = _pairDev.second.ToJson();
			_dev.append(_val);
		}
		val["dev"] = _dev;

		MAPTAGQTY::iterator _iterMat = mat.begin();
		PAIRTAGQTY _pairMat = *_iterMat;
		XTPJSON::Value _mat;
		while(_iterMat != mat.end())
		{
			XTPJSON::Value _val;
			_pairMat = *_iterMat++;
			_val["key"] = const_cast<char*>(_pairMat.first);
			_val["val"] = _pairMat.second.ToJson();
			_mat.append(_val);
		}
		val["mat"] = _mat;

		XTPJSON::FastWriter writer;
		string json = writer._write(val);

		return const_cast<char*>(json.c_str());
	}

	bool ReadJson(const char *json)
	{
		XTPJSON::Reader reader;
		XTPJSON::Value val;

		if (!reader.parse(json, val, false))
			return false;

		id = val["id"].asInt();
		pid = val["pid"].asInt();
		lv = val["lv"].asInt();
		spi = val["spi"].asInt();

		ids[0] = val["id1"].asInt();
		ids[1] = val["id2"].asInt();
		ids[2] = val["id3"].asInt();
		ids[3] = val["id4"].asInt();
		ids[4] = val["id5"].asInt();
		ids[5] = val["id6"].asInt();
		ids[6] = val["id7"].asInt();

		bdt.ParseDateTime(CXTPString(val["bdt"].asString()));
		edt.ParseDateTime(CXTPString(val["edt"].asString()));
		_bdt.ParseDateTime(CXTPString(val["_bdt"].asString()));
		_edt.ParseDateTime(CXTPString(val["_edt"].asString()));

		XTPJSON::Value _qty = val["qty"];
		for (int i = 0; i < _qty.size(); i++)
		{
			PAIRTAGQTY _pair;
			const char *buf = _qty[i]["key"].asCString();
			_pair.first = const_cast<char*>(buf);
			_pair.second.ReadJson(_qty[i]["val"]);
		}

		XTPJSON::Value _lab = val["lab"];
		for (int i = 0; i < _lab.size(); i++)
		{
			PAIRTAGQTY _pair;
			const char *buf = _lab[i]["key"].asCString();
			_pair.first = const_cast<char*>(buf);
			_pair.second.ReadJson(_lab[i]["val"]);
		}

		XTPJSON::Value _dev = val["dev"];
		for (int i = 0; i < _dev.size(); i++)
		{
			PAIRTAGQTY _pair;
			const char *buf = _dev[i]["key"].asCString();
			_pair.first = const_cast<char*>(buf);
			_pair.second.ReadJson(_dev[i]["val"]);
		}

		XTPJSON::Value _mat = val["mat"];
		for (int i = 0; i < _mat.size(); i++)
		{
			PAIRTAGQTY _pair;
			const char *buf = _mat[i]["key"].asCString();
			_pair.first = const_cast<char*>(buf);
			_pair.second.ReadJson(_mat[i]["val"]);
		}

		return true;
	}

	void ReadJson(XTPJSON::Value val)
	{
		id = val["id"].asInt();
		pid = val["pid"].asInt();
		lv = val["lv"].asInt();
		spi = val["spi"].asInt();

		ids[0] = val["id1"].asInt();
		ids[1] = val["id2"].asInt();
		ids[2] = val["id3"].asInt();
		ids[3] = val["id4"].asInt();
		ids[4] = val["id5"].asInt();
		ids[5] = val["id6"].asInt();
		ids[6] = val["id7"].asInt();

		CString strDateTime = CXTPString(val["bdt"].asString()).t_str();
		bdt = ParseDateTime(strDateTime);
		strDateTime = CXTPString(val["edt"].asString()).t_str();
		edt = ParseDateTime(strDateTime);
		strDateTime = CXTPString(val["_bdt"].asString()).t_str();
		_bdt = ParseDateTime(strDateTime);
		strDateTime = CXTPString(val["_edt"].asString()).t_str();
		_edt = ParseDateTime(strDateTime);

		XTPJSON::Value _qty = val["qty"];
		for (int i = 0; i < _qty.size(); i++)
		{
			PAIRTAGQTY _pair;
			const char *buf = _qty[i]["key"].asCString();
			_pair.first = const_cast<char*>(buf);
			_pair.second.ReadJson(_qty[i]["val"]);
		}

		XTPJSON::Value _lab = val["lab"];
		for (int i = 0; i < _lab.size(); i++)
		{
			PAIRTAGQTY _pair;
			const char *buf = _lab[i]["key"].asCString();
			_pair.first = const_cast<char*>(buf);
			_pair.second.ReadJson(_lab[i]["val"]);
		}

		XTPJSON::Value _dev = val["dev"];
		for (int i = 0; i < _dev.size(); i++)
		{
			PAIRTAGQTY _pair;
			const char *buf = _dev[i]["key"].asCString();
			_pair.first = const_cast<char*>(buf);
			_pair.second.ReadJson(_dev[i]["val"]);
		}

		XTPJSON::Value _mat = val["mat"];
		for (int i = 0; i < _mat.size(); i++)
		{
			PAIRTAGQTY _pair;
			const char *buf = _mat[i]["key"].asCString();
			_pair.first = const_cast<char*>(buf);
			_pair.second.ReadJson(_mat[i]["val"]);
		}
	}
} TVACTIONTAG, *LPTVACTIONTAG;

class CActions;
class CTreeCtrlAction : public CXTPTreeCtrlEx
{
	// Construction
public:
	CTreeCtrlAction();
	virtual ~CTreeCtrlAction();

	// Operations
public:
	void DeleteItem(HTREEITEM hItem);
	void DeleteAllItems();
	void SetTag(HTREEITEM hItem, DWORD_PTR tag);
	DWORD_PTR GetTag(HTREEITEM hItem);
	void SetAction(HTREEITEM hItem, CXTPControlAction *pAction);
	CXTPControlAction* GetAction(HTREEITEM hItem);
	CXTPControlAction* AddAction(HTREEITEM hItem, LPCTSTR lpszCaption, UINT nID, UINT nIconID, UINT nHelpID, LPCTSTR lpszKey, LPCTSTR lpszCategory, UINT nImage = -1, LPCTSTR lpszDescription=_T(""), LPCTSTR lpszTooltip=_T(""), DWORD_PTR tag = NULL);
	CXTPControlAction* SetAction(HTREEITEM hItem, LPCTSTR lpszCaption, UINT nID, UINT nIconID, UINT nHelpID, LPCTSTR lpszKey, LPCTSTR lpszCategory, UINT nImage = -1, LPCTSTR lpszDescription=_T(""), LPCTSTR lpszTooltip=_T(""), DWORD_PTR tag = NULL);
	void ReplaceActionId(CXTPControlAction *pAction, int nId);
	void RefreshResourceManager();


public:
	virtual BOOL SaveTreeData(XTPTVITEMS &tis, HTREEITEM hItem, XTPTreeParam tp = xtpParamNone);
	virtual BOOL LoadTreeData(XTPTVITEMS &tis, HTREEITEM hItem, XTPTreeParam tp = xtpParamNone);
	virtual BOOL SaveIndentTreeToFile1(const char *lpszFileName, XTPTVITEMS &tis);
	virtual BOOL SaveCsvTreeToFile(const char *lpszFileName, XTPTVITEMS &tis);
	virtual BOOL SaveTagToFile(const char *lpszFileName, XTPTVITEMS &tis);
	virtual BOOL LoadTagFromFile(const char *lpszFileName, XTPTVITEMS &tis);
	virtual BOOL SaveExcelTreeToFile(const char *lpszFileName, XTPTVITEMS &tis);

private:
	CActions* m_pActions;            //控件ITEM链接数据
	CResourceManager* m_pResManager; //控件Action资源数据

private:
	friend class CActions;
};

class CActions : public CXTPControlActions
{
public:
	CActions() : CXTPControlActions(NULL) {}
	CXTPControlAction* operator[](int nIndex);

public:
	int InsertAction(CXTPControlAction* pAction);
	CXTPControlAction* AddAction(UINT nID, LPCTSTR lpszKey, LPCTSTR lpszCategory, UINT nImage = -1, LPCTSTR lpszDescription=_T(""), LPCTSTR lpszTooltip=_T(""));
	CXTPControlAction* AddAction(UINT nID, UINT nIconID, UINT nHelpID, LPCTSTR lpszKey, LPCTSTR lpszCategory, UINT nImage = -1, LPCTSTR lpszDescription=_T(""), LPCTSTR lpszTooltip=_T(""));
	CXTPControlAction* AddAction(LPCTSTR lpszCaption, UINT nID, LPCTSTR lpszKey, LPCTSTR lpszCategory, UINT nImage = -1, LPCTSTR lpszDescription=_T(""), LPCTSTR lpszTooltip=_T(""));
	CXTPControlAction* AddAction(LPCTSTR lpszCaption, UINT nID, UINT nIconID, UINT nHelpID, LPCTSTR lpszKey, LPCTSTR lpszCategory, UINT nImage = -1, LPCTSTR lpszDescription=_T(""), LPCTSTR lpszTooltip=_T(""));
	int GetIndex(CXTPControlAction* pAction);
	int GetIndex(UINT nID);
	void ReplaceActionId(CXTPControlAction* pAction, int nID);
	void DeleteAction(CXTPControlAction* pAction);
};

#endif // !defined(AFX_TREECTRLACTION_H__6C481840_FE83_4798_9524_1A01F1FB13DB__INCLUDED_)




/*

void TreeCtrl控件总结()
{
CTreeCtrl wndTreeCtrl;
//基础操作
//---1插入节点
//---1）插入根节点

//插入根节点
HTREEITEM hRoot,hItem;
CString str=L"ROOT";
hRoot = wndTreeCtrl.InsertItem(str);
//相当于
hRoot=wndTreeCtrl.InsertItem(str,TVI_ROOT,TVI_LAST);


//---2）插入孩子节点
//添加hRoot节点的孩子节点，并且被添加的节点位于hRoot所有孩子节点的末尾
HTREEITEM hChild=wndTreeCtrl.InsertItem(str,hRoot);
//相当于
HTREEITEM hChild=wndTreeCtrl.InsertItem(str,hRoot,TVI_LAST);


//---2获得节点句柄
//获得根节点
HTREEITEM hRootItem;
hRootItem=wndTreeCtrl.GetRootItem();

//获得当前节点
HTREEITEM hCurrentItem;
hCurrentItem=wndTreeCtrl.GetSelectedItem();

//获得hItem的前一个节点
HTREEITEM hPreItem;
hPreItem=wndTreeCtrl.GetNextItem(hItem,TVGN_PREVIOUS);

//获得hItem的下一个节点
HTREEITEM hNextItem;
hNextItem=wndTreeCtrl.GetNextItem(hItem,TVGN_NEXT);


//---3判断某节点是否有孩子节点
//判断某节点是否有孩子节点
if(wndTreeCtrl.ItemHasChildren(hRoot)) return;


//---4展开或收缩子节点
HTREEITEM hParentItem;
if(wndTreeCtrl.ItemHasChildren(hRoot))
	wndTreeCtrl.Expand(hParentItem,TVE_EXPAND);


//---5获得第一个孩子节点的句柄
//判断某节点是否有孩子节点
if(wndTreeCtrl.ItemHasChildren(hRoot))
{
	//获得孩子节点
	HTREEITEM hChild=wndTreeCtrl.GetChildItem(hRoot);
}


//---6遍历hRoot下一层的所有孩子节点
//判断某节点是否有孩子节点
if(wndTreeCtrl.ItemHasChildren(hRoot))
{
	//获得孩子节点
	HTREEITEM hChild=wndTreeCtrl.GetChildItem(hRoot);

	//遍历hRoot下一层的所有孩子节点
	while(hChild)
	{
		hChild=wndTreeCtrl.GetNextItem(hChild,TVGN_NEXT);
	}
}


//---7获得某节点上的文字
//获得某节点上的文字
CString str;
wndTreeCtrl.GetItemText(hRoot);


//---8选择某节点，并让其获得焦点
//首先，TREE控件的样式必须设置为TVS_SHOWSELALWAYS
//其次：选择该节点
wndTreeCtrl.SelectItem(hItem);
//最后，设置焦点

wndTreeCtrl.SetFocus();
//Tree控件设置焦点后，会自动将焦点定位到选择的节点上


//---9清空树控件
wndTreeCtrl.DeleteAllItems();

}

//---10将指定目录下的文件插入节点
void InsertPath(CString path,HTREEITEM hRoot,CTreeCtrl& ctrl)
{
	CFileFind nFindFile;
	CString str=L"";
	CString nPicFileName=L"";
	BOOL IsExist=FALSE;
	HTREEITEM hSubItem;

	nPicFileName.Format(L"%s\\*.*",path);
	IsExist=nFindFile.FindFile(nPicFileName);
	while(IsExist)
	{
		IsExist=nFindFile.FindNextFile();
		if(nFindFile.IsDots())
			continue;
		nPicFileName=nFindFile.GetFileName();

		//路径
		if(nFindFile.IsDirectory())
		{
			hSubItem=ctrl.InsertItem(nPicFileName,hRoot);
			InsertPath(nFindFile.GetFilePath(),hSubItem,ctrl);
		}
		else
		{
			//文件
			str=nPicFileName.Right(4);
			if(!str.CompareNoCase(_T(".jpg"))||!str.CompareNoCase(_T(".tif")))
			{
				ctrl.InsertItem(nPicFileName,hRoot);
			}
		}
	}
	nFindFile.Close();
}

void LoadPath(CString path)//path为指定目录此函数的作用为将path目录下的文件插入树控件中
{
	CTreeCtrl& ctrl=GetTreeCtrl();
	ASSERT(ctrl);
	ctrl.DeleteAllItems();
	HTREEITEM hRoot=ctrl.InsertItem(path);
	InsertPath(path,hRoot,ctrl);
	ctrl.Expand(hRoot,TVE_EXPAND);
}


//---11将文件列表中的文件插入树控件中

void InsetAllFile(list<CString>& filePathList)
{
	CTreeCtrl wndTreeCtrl;
	wndTreeCtrl.DeleteAllItems();

	list<CString>::iterator it=filePathList.begin();
	HTREEITEM hRoot=NULL;
	CString filePath;
	CString treeRootName=L"根目录";//所有的文件都在根目录下即：默认所有的文件都在同一个目录下

	while(it!=filePathList.end())
	{
		filePath=*it;

		if(hRoot==NULL)
			hRoot=wndTreeCtrl.InsertItem(treeRootName);//建立根目录

		if(filePath.Find(treeRootName)==0)//文件第一层目录与根目录相同，则截去文件第一层目录，文件从第二层目录开始
			filePath=filePath.Right(filePath.GetLength()-treeRootName.GetLength()-1);


		LoadPicFiles(wndTreeCtrl,filePath,hRoot);

		it++;
	}
}

void LoadPicFiles(CTreeCtrl& wndTreeCtrl,CString nFilePath,HTREEITEM nRoot)
{
	//判断nPicFolder是目录还是文件
	//如果是文件
	//直接将文件插入到树控件中wndTreeCtrl.InsertItem(nPicFolder,nRoot);
	//如果是目录
	//获取nPicFolder的第一层目录
	//判断nRoot目录下是否已经有此层目录
	//如果有此层目录
	//递归插入其他
	//如果无此层目录
	//插入此层目录，然后递归插入其他


	CString nSubFolder;//首层目录
	CString nSubFilePath;//去掉首层目录后的文件名
	BOOL IsExist=FALSE;

	int nIndex=-1;
	nIndex=nFilePath.Find(L'\\');

	if(nIndex>=0)//目录
	{
		nSubFolder=nFilePath.Left(nIndex);
		nSubFilePath=nFilePath.Right(nFilePath.GetLength()-nIndex-1);

		HTREEITEM nSubRoot=NULL;
		if(wndTreeCtrl.ItemHasChildren(nRoot))
			nSubRoot=wndTreeCtrl.GetChildItem(nRoot);
		CString str;
		BOOL bExist=FALSE;
		while(nSubRoot)
		{
			str=wndTreeCtrl.GetItemText(nSubRoot);

			if(str.CompareNoCase(nSubFolder)==0)
			{

				bExist=TRUE;
				break;
			}

			nSubRoot=wndTreeCtrl.GetNextSiblingItem(nSubRoot);
		}

		if(!bExist)
		{

			nSubRoot=wndTreeCtrl.InsertItem(nSubFolder,nRoot);

			LoadPicFiles(wndTreeCtrl,nSubFilePath,nSubRoot);
		}else{
			LoadPicFiles(wndTreeCtrl,nSubFilePath,nSubRoot);
		}
	}
	else if(nFilePath.Find(L".jpg")!=-1||nFilePath.Find(L".tif")!=-1)
	{
		wndTreeCtrl.InsertItem(nFilePath,nRoot);
	}
}



//二扩展操作
//---1响应TVN_ITEMEXPANDING消息时如何获得将要展开或收缩的那一个节点的句柄

			TVN_ITEMEXPANDING pnmtv=(NM_TREEVIEWFAR*)lParam

			typedef struct_NM_TREEVIEW{
				NMHDR hdr;
				UINT action;
				TV_ITEM itemOld;
				TV_ITEM itemNew;
				POINT ptDrag;
		}NM_TREEVIEW;
		typedef NM_TREEVIEWFAR* LPNM_TREEVIEW;

			typedef struct_TV_ITEM
			{tvi
			UINT mask;
		HTREEITEM hItem;
		UINT state;
		UINT stateMask;
		LPSTR pszText;
		int cchTextMax;
		int iImage;
		int iSelectedImage;
		int cChildren;
		LPARAM lParam;}
		TV_ITEM,FAR*LPTV_ITEM;


//在TV_ITEM的hItem中存放着要展开项的句柄
void CLeftView::OnItemexpanding(NMHDR*pNMHDR,LRESULT*pResult)
{
	LPNMTREEVIEW pNMTreeView=reinterpret_cast<LPNMTREEVIEW>(pNMHDR);
	//TODO:在此添加控件通知处理程序代
	HTREEITEM htree=pNMTreeView->itemNew.hItem;//这个就是将要被扩展或收缩节点的句柄
}



//2怎么知道CTreeCtrl的一个节点是展开的还是收缩着的
//方法1
GetItemState(hItem,TVIS_EXPANDED)&TVIS_EXPANDED)!=TVIS_EXPANDED//如果相等，则说明改节点是扩展的，如果不相等，则说明该节点是收缩的


//方法2
//响应TVN_ITEMEXPANDING事件时：
void CExampleDlg::OnItemexpandingTree1(NMHDR* pNMHDR,LRESULT* pResult)
{
	NM_TREEVIEW*pNMTreeView=(NM_TREEVIEW*)pNMHDR;

	if(pNMTreeView->action==TVE_COLLAPSE)//判断action的值
}





//---3判断节点是否被扩展过
if((GetTreeCtrl().GetItemState(hItem,TVIS_EXPANDEDONCE)&TVIS_EXPANDEDONCE)!=0)//判断是否扩展过一次，若！=0则说明被扩展过


//---4使用CImageListm_ImageList;加载位图或图标，并将其与树控件联系在一起，由此便可以设置每个节点的图标
    	CImageList m_ImageList;
		m_ImageList.Create(12,12,ILC_COLORDDB|ILC_MASK,3,1);
		HICON hAdd=::LoadIcon(::AfxGetInstanceHandle(),(LPCTSTR)IDI_ADD);
		HICON hRemove=::LoadIcon(::AfxGetInstanceHandle(),(LPCTSTR)IDI_REMOVE);
		HICON hLeaf=::LoadIcon(::AfxGetInstanceHandle(),(LPCTSTR)IDI_LEAF);
		m_ImageList.Add(hAdd);
		m_ImageList.Add(hRemove);
		m_ImageList.Add(hLeaf);
		GetTreeCtrl().SetImageList(&m_ImageList,TVSIL_NORMAL);//树控件和图像列表相连

		m_treeCtrl.SetItemImage(htree,0,0)//通过SetItemImage(htree,0,0)设置节点的图标



//---5什么时候响应OnItemexpanding消息
//当节点第一次被展开时，才响应此消息。也就是说：当以开后该节点再展开或收缩时，便不再响应此消息了。



//6设置树控件形式为TVS_HASBUTTONS|TVS_LINESATROOT时，树控件节点前才会出现+-号
//以下为综合例子：点击按钮上一个显示该节点的上一个兄弟节点，并更改控件焦点
//设置控件样式：
BOOL CTreePathView::PreCreateWindow(CREATESTRUCT& cs)
{
	//TODO:在此处通过修改
	//CREATESTRUCTcs来修改窗口类或样式

	cs.style|=TVS_HASLINES|TVS_SHOWSELALWAYS;//若是想用CImageList的图标，则不要设置为TVS_HASBUTTONS形式


	return CTreeView::PreCreateWindow(cs);
}

//点击按钮5（焦点移动到上一个兄弟节点）
void NewImageView::OnBnClickedButton5()//上一个图
{
	//TODO:在此添加控件通知处理程序代码

	CTreePathView* pTree=(CTreePathView*)(((CMainFrame*)AfxGetMainWnd())->m_wndSplitter.GetPane(0,0));

	CTreeCtrl& wndTreeCtrl=pTree->GetTreeCtrl();

	HTREEITEM hItem=wndTreeCtrl.GetSelectedItem();
	if(hItem!=NULL)
	{
		hItem=wndTreeCtrl.GetNextItem(hItem,TVGN_PREVIOUS);

		if(hItem!=NULL)
		{
			CString str;
			str=pTree->GetFullPath(hItem);
			SetImage(str);
			wndTreeCtrl.SelectItem(hItem);
			wndTreeCtrl.SetFocus();
			InvalidateRect(m_ClientRect);
		}
	}
}


//点击按钮6（焦点移动到下一个兄弟节点）
void NewImageView::OnBnClickedButton6()//下一个
{
	//TODO:在此添加控件通知处理程序代码

	CTreePathView* pTree=(CTreePathView*)(((CMainFrame*)AfxGetMainWnd())->m_wndSplitter.GetPane(0,0));
	CTreeCtrl&wndTreeCtrl=pTree->GetTreeCtrl();
	HTREEITEM hItem=wndTreeCtrl.GetSelectedItem();

	if(hItem!=NULL)
	{
		hItem=wndTreeCtrl.GetNextItem(hItem,TVGN_NEXT);

		if(hItem!=NULL)
		{
			CString str;
			str=pTree->GetFullPath(hItem);
			SetImage(str);

			wndTreeCtrl.SelectItem(hItem);
			wndTreeCtrl.SetFocus();
			InvalidateRect(m_ClientRect);
		}
	}
}


//---7遍历树控件的所有节点
//---1）获得根节点句柄
CTreeCtrl& wndTreeCtrl=((CImportTreeView*)m_SplitterWnd.GetPane(0,0))->GetTreeCtrl();

		HTREEITEM hItem;
		//获得根目录节点
		hItem=wndTreeCtrl.GetRootItem();
		//遍历树控件节点
		TreeVisit(&wndTreeCtrl,hItem);


//---2）遍历所有节点
void TreeVisit(CTreeCtrl*pCtrl,HTREEITEM hItem)
{
	if(pCtrl->ItemHasChildren(hItem))
	{
		HTREEITEMhChildItem=pCtrl->GetChildItem(hItem);
		while(hChildItem!=NULL)
		{
			TreeVisit(pCtrl,hChildItem);//递归遍历孩子节点
			hChildItem=pCtrl->GetNextItem(hChildItem,TVGN_NEXT);
		}
	}
	else//对叶子节点进行操作
		Leaf(pCtrl,hItem);
}


//---8获得某Item节点的全路径
	CString m_ParentFolder[10];
		CString m_OldParentFolder[10];

			//--------------------将nParent添加到nParentFolder[10]第一位----------------------
BOOL AddParentFolder(CString nParentFolder[10],CString nParent)
{
	for(int i=9;i>0;i--)
		nParentFolder[i]=nParentFolder[i-1];
	nParentFolder[0]=nParent;
	return TRUE;
}

//---------------------nParentFolder[10]中的有效数据整合(加\)---------------------
CString AllCString(CString nParentFolder[10])
{
	CString nAllCString=L"";
	for(int i=0;i<10;i++)
	{
		if(nParentFolder[i]==L"")break;
		nAllCString+=L"\\"+nParentFolder[i];
	}
	return nAllCString;
}


//---获得Item节点路径的函数
CString GetItemPath(CTreeCtrl* pCtrl,HTREEITEM hItem)
{
	CString nSelItemName=pCtrl->GetItemText(hItem);

	HTREEITEM parentItem=pCtrl->GetParentItem(hItem);

	if(parentItem==NULL)//hItem即为根目录
		return nSelItemName;

	//清空OLD
	for(int i=0;i<10;i++)m_OldParentFolder[i]=L"";

	//m_OldParentFolder记录上一个节点的父节点
	for(int i=0;i<10;i++)
		m_OldParentFolder[i]=m_ParentFolder[i];

	//m_ParentFolder记录当前节点的父亲节点
	for(int i=0;i<10;i++)
		m_ParentFolder[i]=L"";

	CString itemPath;
	CString parentFolder=nSelItemName;

	//将parentFolder添加到m_ParentFolder[0],其他值依次后移
	AddParentFolder(m_ParentFolder,parentFolder);



	//m_PicFolder为根节点对应的名字
	while(parentItem!=NULL&&pCtrl->GetItemText(parentItem).Compare(m_PicFolder))
	{
		parentFolder=pCtrl->GetItemText(parentItem);
		AddParentFolder(m_ParentFolder,parentFolder);
		parentItem=pCtrl->GetParentItem(parentItem);

	}

	itemPath.Format(L"%s%s",m_PicFolder,AllCString(m_ParentFolder));

	//清空OLD
	for(int i=0;i<10;i++)m_OldParentFolder[i]=L"";
	//清空
	for(int i=0;i<10;i++)
		m_ParentFolder[i]=L"";

	return itemPath;
}





//获得叶子节点的函数
void Leaf(CTreeCtrl* pCtrl,HTREEITEM hItem)
{

	CString itemName=pCtrl->GetItemText(hItem);

	//叶子节点是jpg文件或tif文件
	if(nSelItemName.Find(L".jpg")!=-1||nSelItemName.Find(L".tif")!=-1)
	{

		//m_OldParentFolder记录上一个节点的父节点
		for(int i=0;i<10;i++)
			m_OldParentFolder[i]=m_ParentFolder[i];

		//m_ParentFolder记录当前节点的父亲节点
		for(int i=0;i<10;i++)
			m_ParentFolder[i]=L"";

		CString imgPath=L"";
		CString parentFolder=itemName;

		//将parentFolder添加到m_ParentFolder[0],其他值依次后移
		AddParentFolder(m_ParentFolder,parentFolder);

		HTREEITEM parentItem=pCtrl->GetParentItem(hItem);

		//m_imgPath为根节点对应的名字
		while(pCtrl->GetItemText(parentItem).Compare(m_imgPath))
		{
			parentFolder=pCtrl->GetItemText(parentItem);
			AddParentFolder(m_ParentFolder,parentFolder);
			parentItem=pCtrl->GetParentItem(parentItem)

		}

		//获得叶子节点的全路径
		imgPath.Format(L"%s%s",m_imgPath,AllCString(m_ParentFolder));

	}


	//对imgPath所指的文件进行操作
	ShowPic(imgPath);
}
			

//使用栈，依次将本节点-->根节点入栈出栈时顺序便为根节点-->本节点
//1）叶子节点
//本地是否存在此文章
void CMainFrame::PostPath(CTreeCtrl& wndTreeCtrl,HTREEITEM hItem,CString& path)
{
	stack<HTREEITEM> itemStack;
	while(hItem!=wndTreeCtrl.GetRootItem())
	{
		itemStack.push(hItem);
		hItem=wndTreeCtrl.GetParentItem(hItem);
	}
	itemStack.push(wndTreeCtrl.GetRootItem());
	CString itemName;
	while(!itemStack.empty())
	{
		hItem=(HTREEITEM)itemStack.top();
		itemStack.pop();
		itemName=wndTreeCtrl.GetItemText(hItem);
		path+=itemName;
		path+=L"\\";
	}
	path.TrimRight(L"\\");
	path+=L".xml";
}

//2）目录节点
void CMainFrame::DirPath(CTreeCtrl& wndTreeCtrl,HTREEITEM nRoot,CString& path)
{
	stack<HTREEITEM>itemStack;
	while(hItem!=wndTreeCtrl.GetRootItem())
	{
		itemStack.push(hItem);
		hItem=wndTreeCtrl.GetParentItem(hItem);
	}
	itemStack.push(wndTreeCtrl.GetRootItem());
	CString itemName;
	while(!itemStack.empty())
	{
		hItem=(HTREEITEM)itemStack.top();
		itemStack.pop();
		itemName=wndTreeCtrl.GetItemText(hItem);
		path+=itemName;
		path+=L"\\";
	}
}



//---9获得树中所有叶子节点的父目录
//即：树中可能有许多枝干，获取这些枝干的路径
std::vector<CString>m_BookDirectory;//存放所有叶子节点的父目录
void GetBookDirectory(CTreeCtrl* pCtrl,HTREEITEM hItem)
{
	if(pCtrl->ItemHasChildren(hItem))
	{
		HTREEITEM hChildItem=pCtrl->GetChildItem(hItem);
		while(hChildItem!=NULL)
		{
			GetBookDirectory(pCtrl,hChildItem);//递归遍历孩子节点

			if(pCtrl->ItemHasChildren(hChildItem))
				hChildItem=pCtrl->GetNextItem(hChildItem,TVGN_NEXT);
			else
				break;
		}
	}
	else
	{
		HTREEITEM parentItem=pCtrl->GetParentItem(hItem);
		CString bookPath=GetItemPath(pCtrl,parentItem);

		m_BookDirectory.push_back(bookPath);

	}
}

CTreeCtrl& wndTreeCtrl=((CImportTreeView*)m_SplitterWnd.GetPane(0,0))->GetTreeCtrl();
HTREEITEM hItem;
hItem=wndTreeCtrl.GetRootItem();

m_BookDirectory.clear();
GetBookDirectory(&wndTreeCtrl,hItem);//获得几本书及书的路径


//---10利用InsertItem、SetItemData存放与该节点有关的数字信息
HTREEITEM InsertItem(
LPCTSTR lpszItem,
int nImage,//实测范围0-65535
int nSelectedImage,
HTREEITEM hParent=TVI_ROOT,
HTREEITEM hInsertAfter=TVI_LAST
);
//存放65535以上的大数据时用SetItemData
BOOL SetItemData(HTREEITEM hItem, DWORD_PTR dwData);

*/