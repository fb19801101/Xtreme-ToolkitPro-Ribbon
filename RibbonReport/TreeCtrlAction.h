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
	CActions* m_pActions;            //�ؼ�ITEM��������
	CResourceManager* m_pResManager; //�ؼ�Action��Դ����

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

void TreeCtrl�ؼ��ܽ�()
{
CTreeCtrl wndTreeCtrl;
//��������
//---1����ڵ�
//---1��������ڵ�

//������ڵ�
HTREEITEM hRoot,hItem;
CString str=L"ROOT";
hRoot = wndTreeCtrl.InsertItem(str);
//�൱��
hRoot=wndTreeCtrl.InsertItem(str,TVI_ROOT,TVI_LAST);


//---2�����뺢�ӽڵ�
//���hRoot�ڵ�ĺ��ӽڵ㣬���ұ���ӵĽڵ�λ��hRoot���к��ӽڵ��ĩβ
HTREEITEM hChild=wndTreeCtrl.InsertItem(str,hRoot);
//�൱��
HTREEITEM hChild=wndTreeCtrl.InsertItem(str,hRoot,TVI_LAST);


//---2��ýڵ���
//��ø��ڵ�
HTREEITEM hRootItem;
hRootItem=wndTreeCtrl.GetRootItem();

//��õ�ǰ�ڵ�
HTREEITEM hCurrentItem;
hCurrentItem=wndTreeCtrl.GetSelectedItem();

//���hItem��ǰһ���ڵ�
HTREEITEM hPreItem;
hPreItem=wndTreeCtrl.GetNextItem(hItem,TVGN_PREVIOUS);

//���hItem����һ���ڵ�
HTREEITEM hNextItem;
hNextItem=wndTreeCtrl.GetNextItem(hItem,TVGN_NEXT);


//---3�ж�ĳ�ڵ��Ƿ��к��ӽڵ�
//�ж�ĳ�ڵ��Ƿ��к��ӽڵ�
if(wndTreeCtrl.ItemHasChildren(hRoot)) return;


//---4չ���������ӽڵ�
HTREEITEM hParentItem;
if(wndTreeCtrl.ItemHasChildren(hRoot))
	wndTreeCtrl.Expand(hParentItem,TVE_EXPAND);


//---5��õ�һ�����ӽڵ�ľ��
//�ж�ĳ�ڵ��Ƿ��к��ӽڵ�
if(wndTreeCtrl.ItemHasChildren(hRoot))
{
	//��ú��ӽڵ�
	HTREEITEM hChild=wndTreeCtrl.GetChildItem(hRoot);
}


//---6����hRoot��һ������к��ӽڵ�
//�ж�ĳ�ڵ��Ƿ��к��ӽڵ�
if(wndTreeCtrl.ItemHasChildren(hRoot))
{
	//��ú��ӽڵ�
	HTREEITEM hChild=wndTreeCtrl.GetChildItem(hRoot);

	//����hRoot��һ������к��ӽڵ�
	while(hChild)
	{
		hChild=wndTreeCtrl.GetNextItem(hChild,TVGN_NEXT);
	}
}


//---7���ĳ�ڵ��ϵ�����
//���ĳ�ڵ��ϵ�����
CString str;
wndTreeCtrl.GetItemText(hRoot);


//---8ѡ��ĳ�ڵ㣬�������ý���
//���ȣ�TREE�ؼ�����ʽ��������ΪTVS_SHOWSELALWAYS
//��Σ�ѡ��ýڵ�
wndTreeCtrl.SelectItem(hItem);
//������ý���

wndTreeCtrl.SetFocus();
//Tree�ؼ����ý���󣬻��Զ������㶨λ��ѡ��Ľڵ���


//---9������ؼ�
wndTreeCtrl.DeleteAllItems();

}

//---10��ָ��Ŀ¼�µ��ļ�����ڵ�
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

		//·��
		if(nFindFile.IsDirectory())
		{
			hSubItem=ctrl.InsertItem(nPicFileName,hRoot);
			InsertPath(nFindFile.GetFilePath(),hSubItem,ctrl);
		}
		else
		{
			//�ļ�
			str=nPicFileName.Right(4);
			if(!str.CompareNoCase(_T(".jpg"))||!str.CompareNoCase(_T(".tif")))
			{
				ctrl.InsertItem(nPicFileName,hRoot);
			}
		}
	}
	nFindFile.Close();
}

void LoadPath(CString path)//pathΪָ��Ŀ¼�˺���������Ϊ��pathĿ¼�µ��ļ��������ؼ���
{
	CTreeCtrl& ctrl=GetTreeCtrl();
	ASSERT(ctrl);
	ctrl.DeleteAllItems();
	HTREEITEM hRoot=ctrl.InsertItem(path);
	InsertPath(path,hRoot,ctrl);
	ctrl.Expand(hRoot,TVE_EXPAND);
}


//---11���ļ��б��е��ļ��������ؼ���

void InsetAllFile(list<CString>& filePathList)
{
	CTreeCtrl wndTreeCtrl;
	wndTreeCtrl.DeleteAllItems();

	list<CString>::iterator it=filePathList.begin();
	HTREEITEM hRoot=NULL;
	CString filePath;
	CString treeRootName=L"��Ŀ¼";//���е��ļ����ڸ�Ŀ¼�¼���Ĭ�����е��ļ�����ͬһ��Ŀ¼��

	while(it!=filePathList.end())
	{
		filePath=*it;

		if(hRoot==NULL)
			hRoot=wndTreeCtrl.InsertItem(treeRootName);//������Ŀ¼

		if(filePath.Find(treeRootName)==0)//�ļ���һ��Ŀ¼���Ŀ¼��ͬ�����ȥ�ļ���һ��Ŀ¼���ļ��ӵڶ���Ŀ¼��ʼ
			filePath=filePath.Right(filePath.GetLength()-treeRootName.GetLength()-1);


		LoadPicFiles(wndTreeCtrl,filePath,hRoot);

		it++;
	}
}

void LoadPicFiles(CTreeCtrl& wndTreeCtrl,CString nFilePath,HTREEITEM nRoot)
{
	//�ж�nPicFolder��Ŀ¼�����ļ�
	//������ļ�
	//ֱ�ӽ��ļ����뵽���ؼ���wndTreeCtrl.InsertItem(nPicFolder,nRoot);
	//�����Ŀ¼
	//��ȡnPicFolder�ĵ�һ��Ŀ¼
	//�ж�nRootĿ¼���Ƿ��Ѿ��д˲�Ŀ¼
	//����д˲�Ŀ¼
	//�ݹ��������
	//����޴˲�Ŀ¼
	//����˲�Ŀ¼��Ȼ��ݹ��������


	CString nSubFolder;//�ײ�Ŀ¼
	CString nSubFilePath;//ȥ���ײ�Ŀ¼����ļ���
	BOOL IsExist=FALSE;

	int nIndex=-1;
	nIndex=nFilePath.Find(L'\\');

	if(nIndex>=0)//Ŀ¼
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



//����չ����
//---1��ӦTVN_ITEMEXPANDING��Ϣʱ��λ�ý�Ҫչ������������һ���ڵ�ľ��

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


//��TV_ITEM��hItem�д����Ҫչ����ľ��
void CLeftView::OnItemexpanding(NMHDR*pNMHDR,LRESULT*pResult)
{
	LPNMTREEVIEW pNMTreeView=reinterpret_cast<LPNMTREEVIEW>(pNMHDR);
	//TODO:�ڴ���ӿؼ�֪ͨ��������
	HTREEITEM htree=pNMTreeView->itemNew.hItem;//������ǽ�Ҫ����չ�������ڵ�ľ��
}



//2��ô֪��CTreeCtrl��һ���ڵ���չ���Ļ��������ŵ�
//����1
GetItemState(hItem,TVIS_EXPANDED)&TVIS_EXPANDED)!=TVIS_EXPANDED//�����ȣ���˵���Ľڵ�����չ�ģ��������ȣ���˵���ýڵ���������


//����2
//��ӦTVN_ITEMEXPANDING�¼�ʱ��
void CExampleDlg::OnItemexpandingTree1(NMHDR* pNMHDR,LRESULT* pResult)
{
	NM_TREEVIEW*pNMTreeView=(NM_TREEVIEW*)pNMHDR;

	if(pNMTreeView->action==TVE_COLLAPSE)//�ж�action��ֵ
}





//---3�жϽڵ��Ƿ���չ��
if((GetTreeCtrl().GetItemState(hItem,TVIS_EXPANDEDONCE)&TVIS_EXPANDEDONCE)!=0)//�ж��Ƿ���չ��һ�Σ�����=0��˵������չ��


//---4ʹ��CImageListm_ImageList;����λͼ��ͼ�꣬�����������ؼ���ϵ��һ���ɴ˱��������ÿ���ڵ��ͼ��
    	CImageList m_ImageList;
		m_ImageList.Create(12,12,ILC_COLORDDB|ILC_MASK,3,1);
		HICON hAdd=::LoadIcon(::AfxGetInstanceHandle(),(LPCTSTR)IDI_ADD);
		HICON hRemove=::LoadIcon(::AfxGetInstanceHandle(),(LPCTSTR)IDI_REMOVE);
		HICON hLeaf=::LoadIcon(::AfxGetInstanceHandle(),(LPCTSTR)IDI_LEAF);
		m_ImageList.Add(hAdd);
		m_ImageList.Add(hRemove);
		m_ImageList.Add(hLeaf);
		GetTreeCtrl().SetImageList(&m_ImageList,TVSIL_NORMAL);//���ؼ���ͼ���б�����

		m_treeCtrl.SetItemImage(htree,0,0)//ͨ��SetItemImage(htree,0,0)���ýڵ��ͼ��



//---5ʲôʱ����ӦOnItemexpanding��Ϣ
//���ڵ��һ�α�չ��ʱ������Ӧ����Ϣ��Ҳ����˵�����Կ���ýڵ���չ��������ʱ���㲻����Ӧ����Ϣ�ˡ�



//6�������ؼ���ʽΪTVS_HASBUTTONS|TVS_LINESATROOTʱ�����ؼ��ڵ�ǰ�Ż����+-��
//����Ϊ�ۺ����ӣ������ť��һ����ʾ�ýڵ����һ���ֵܽڵ㣬�����Ŀؼ�����
//���ÿؼ���ʽ��
BOOL CTreePathView::PreCreateWindow(CREATESTRUCT& cs)
{
	//TODO:�ڴ˴�ͨ���޸�
	//CREATESTRUCTcs���޸Ĵ��������ʽ

	cs.style|=TVS_HASLINES|TVS_SHOWSELALWAYS;//��������CImageList��ͼ�꣬��Ҫ����ΪTVS_HASBUTTONS��ʽ


	return CTreeView::PreCreateWindow(cs);
}

//�����ť5�������ƶ�����һ���ֵܽڵ㣩
void NewImageView::OnBnClickedButton5()//��һ��ͼ
{
	//TODO:�ڴ���ӿؼ�֪ͨ����������

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


//�����ť6�������ƶ�����һ���ֵܽڵ㣩
void NewImageView::OnBnClickedButton6()//��һ��
{
	//TODO:�ڴ���ӿؼ�֪ͨ����������

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


//---7�������ؼ������нڵ�
//---1����ø��ڵ���
CTreeCtrl& wndTreeCtrl=((CImportTreeView*)m_SplitterWnd.GetPane(0,0))->GetTreeCtrl();

		HTREEITEM hItem;
		//��ø�Ŀ¼�ڵ�
		hItem=wndTreeCtrl.GetRootItem();
		//�������ؼ��ڵ�
		TreeVisit(&wndTreeCtrl,hItem);


//---2���������нڵ�
void TreeVisit(CTreeCtrl*pCtrl,HTREEITEM hItem)
{
	if(pCtrl->ItemHasChildren(hItem))
	{
		HTREEITEMhChildItem=pCtrl->GetChildItem(hItem);
		while(hChildItem!=NULL)
		{
			TreeVisit(pCtrl,hChildItem);//�ݹ�������ӽڵ�
			hChildItem=pCtrl->GetNextItem(hChildItem,TVGN_NEXT);
		}
	}
	else//��Ҷ�ӽڵ���в���
		Leaf(pCtrl,hItem);
}


//---8���ĳItem�ڵ��ȫ·��
	CString m_ParentFolder[10];
		CString m_OldParentFolder[10];

			//--------------------��nParent��ӵ�nParentFolder[10]��һλ----------------------
BOOL AddParentFolder(CString nParentFolder[10],CString nParent)
{
	for(int i=9;i>0;i--)
		nParentFolder[i]=nParentFolder[i-1];
	nParentFolder[0]=nParent;
	return TRUE;
}

//---------------------nParentFolder[10]�е���Ч��������(��\)---------------------
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


//---���Item�ڵ�·���ĺ���
CString GetItemPath(CTreeCtrl* pCtrl,HTREEITEM hItem)
{
	CString nSelItemName=pCtrl->GetItemText(hItem);

	HTREEITEM parentItem=pCtrl->GetParentItem(hItem);

	if(parentItem==NULL)//hItem��Ϊ��Ŀ¼
		return nSelItemName;

	//���OLD
	for(int i=0;i<10;i++)m_OldParentFolder[i]=L"";

	//m_OldParentFolder��¼��һ���ڵ�ĸ��ڵ�
	for(int i=0;i<10;i++)
		m_OldParentFolder[i]=m_ParentFolder[i];

	//m_ParentFolder��¼��ǰ�ڵ�ĸ��׽ڵ�
	for(int i=0;i<10;i++)
		m_ParentFolder[i]=L"";

	CString itemPath;
	CString parentFolder=nSelItemName;

	//��parentFolder��ӵ�m_ParentFolder[0],����ֵ���κ���
	AddParentFolder(m_ParentFolder,parentFolder);



	//m_PicFolderΪ���ڵ��Ӧ������
	while(parentItem!=NULL&&pCtrl->GetItemText(parentItem).Compare(m_PicFolder))
	{
		parentFolder=pCtrl->GetItemText(parentItem);
		AddParentFolder(m_ParentFolder,parentFolder);
		parentItem=pCtrl->GetParentItem(parentItem);

	}

	itemPath.Format(L"%s%s",m_PicFolder,AllCString(m_ParentFolder));

	//���OLD
	for(int i=0;i<10;i++)m_OldParentFolder[i]=L"";
	//���
	for(int i=0;i<10;i++)
		m_ParentFolder[i]=L"";

	return itemPath;
}





//���Ҷ�ӽڵ�ĺ���
void Leaf(CTreeCtrl* pCtrl,HTREEITEM hItem)
{

	CString itemName=pCtrl->GetItemText(hItem);

	//Ҷ�ӽڵ���jpg�ļ���tif�ļ�
	if(nSelItemName.Find(L".jpg")!=-1||nSelItemName.Find(L".tif")!=-1)
	{

		//m_OldParentFolder��¼��һ���ڵ�ĸ��ڵ�
		for(int i=0;i<10;i++)
			m_OldParentFolder[i]=m_ParentFolder[i];

		//m_ParentFolder��¼��ǰ�ڵ�ĸ��׽ڵ�
		for(int i=0;i<10;i++)
			m_ParentFolder[i]=L"";

		CString imgPath=L"";
		CString parentFolder=itemName;

		//��parentFolder��ӵ�m_ParentFolder[0],����ֵ���κ���
		AddParentFolder(m_ParentFolder,parentFolder);

		HTREEITEM parentItem=pCtrl->GetParentItem(hItem);

		//m_imgPathΪ���ڵ��Ӧ������
		while(pCtrl->GetItemText(parentItem).Compare(m_imgPath))
		{
			parentFolder=pCtrl->GetItemText(parentItem);
			AddParentFolder(m_ParentFolder,parentFolder);
			parentItem=pCtrl->GetParentItem(parentItem)

		}

		//���Ҷ�ӽڵ��ȫ·��
		imgPath.Format(L"%s%s",m_imgPath,AllCString(m_ParentFolder));

	}


	//��imgPath��ָ���ļ����в���
	ShowPic(imgPath);
}
			

//ʹ��ջ�����ν����ڵ�-->���ڵ���ջ��ջʱ˳���Ϊ���ڵ�-->���ڵ�
//1��Ҷ�ӽڵ�
//�����Ƿ���ڴ�����
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

//2��Ŀ¼�ڵ�
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



//---9�����������Ҷ�ӽڵ�ĸ�Ŀ¼
//�������п��������֦�ɣ���ȡ��Щ֦�ɵ�·��
std::vector<CString>m_BookDirectory;//�������Ҷ�ӽڵ�ĸ�Ŀ¼
void GetBookDirectory(CTreeCtrl* pCtrl,HTREEITEM hItem)
{
	if(pCtrl->ItemHasChildren(hItem))
	{
		HTREEITEM hChildItem=pCtrl->GetChildItem(hItem);
		while(hChildItem!=NULL)
		{
			GetBookDirectory(pCtrl,hChildItem);//�ݹ�������ӽڵ�

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
GetBookDirectory(&wndTreeCtrl,hItem);//��ü����鼰���·��


//---10����InsertItem��SetItemData�����ýڵ��йص�������Ϣ
HTREEITEM InsertItem(
LPCTSTR lpszItem,
int nImage,//ʵ�ⷶΧ0-65535
int nSelectedImage,
HTREEITEM hParent=TVI_ROOT,
HTREEITEM hInsertAfter=TVI_LAST
);
//���65535���ϵĴ�����ʱ��SetItemData
BOOL SetItemData(HTREEITEM hItem, DWORD_PTR dwData);

*/