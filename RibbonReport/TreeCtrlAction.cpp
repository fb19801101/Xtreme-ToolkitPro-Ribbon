// TreeCtrlAction.cpp: implementation of the CTreeCtrlAction class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "RibbonReport.h"
#include "MainFrm.h"
#include <fstream>

#include "TreeCtrlAction.h"


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CTreeCtrlAction::CTreeCtrlAction()
{
	m_pActions = new CActions();
	m_pResManager = new CResourceManager;
}

CTreeCtrlAction::~CTreeCtrlAction()
{
	m_pActions->InternalRelease();
	delete m_pResManager;
}

void CTreeCtrlAction::DeleteItem(HTREEITEM hItem)
{
	if (hItem != NULL)
	{
		CXTPControlAction* pAction = GetAction(hItem);
		m_pActions->Remove(pAction->GetID());
		CXTPTreeCtrlEx::DeleteItem(hItem);
	}
	else
	{
		HTREEITEM _hItem = GetSelectedItem();
		if (_hItem != NULL)
		{
			CXTPControlAction* pAction = GetAction(_hItem);
			m_pActions->Remove(pAction->GetID());
			CXTPTreeCtrlEx::DeleteItem(_hItem);
		}
	}
}

void CTreeCtrlAction::DeleteAllItems()
{
	m_pActions->RemoveAll();
	CXTPTreeCtrlEx::DeleteAllItems();
	CXTPTreeCtrlEx::DeleteItem(TVI_ROOT);
}

void CTreeCtrlAction::SetTag(HTREEITEM hItem, DWORD_PTR tag)
{
	CXTPControlAction *pAction = (CXTPControlAction*)GetItemData(hItem);
	pAction->SetTag(tag);
}

DWORD_PTR CTreeCtrlAction::GetTag(HTREEITEM hItem)
{
	CXTPControlAction *pAction = (CXTPControlAction*)GetItemData(hItem);
	return pAction->GetTag();
}

void CTreeCtrlAction::SetAction(HTREEITEM hItem, CXTPControlAction *pAction)
{
	SetItemData(hItem, (DWORD_PTR)pAction);
}

CXTPControlAction* CTreeCtrlAction::GetAction(HTREEITEM hItem)
{
	return (CXTPControlAction*)GetItemData(hItem);
}

CXTPControlAction* CTreeCtrlAction::AddAction(HTREEITEM hItem, LPCTSTR lpszCaption, UINT nID, UINT nIconID, UINT nHelpID, LPCTSTR lpszKey, LPCTSTR lpszCategory, UINT nImage, LPCTSTR lpszDescription, LPCTSTR lpszTooltip, DWORD_PTR tag)
{
	CXTPControlAction* pAction = m_pActions->Add(nID);
	pAction->SetIconId(nIconID);
	pAction->SetHelpId(nHelpID);
	pAction->SetCaption(lpszCaption);
	pAction->SetKey(lpszKey);
	pAction->SetCategory(lpszCategory);
	pAction->SetIconId(nImage);
	pAction->SetDescription(lpszDescription);
	pAction->SetTooltip(lpszTooltip);
	pAction->SetTag(tag);
	SetAction(hItem, pAction);
	return pAction;
}

CXTPControlAction* CTreeCtrlAction::SetAction(HTREEITEM hItem, LPCTSTR lpszCaption, UINT nID, UINT nIconID, UINT nHelpID, LPCTSTR lpszKey, LPCTSTR lpszCategory, UINT nImage, LPCTSTR lpszDescription, LPCTSTR lpszTooltip, DWORD_PTR tag)
{
	CXTPControlAction* pAction = m_pActions->FindAction(nID);
	pAction->SetIconId(nIconID);
	pAction->SetHelpId(nHelpID);
	pAction->SetCaption(lpszCaption);
	pAction->SetKey(lpszKey);
	pAction->SetCategory(lpszCategory);
	pAction->SetIconId(nImage);
	pAction->SetDescription(lpszDescription);
	pAction->SetTooltip(lpszTooltip);
	pAction->SetTag(tag);
	SetAction(hItem, pAction);
	return pAction;
}

void CTreeCtrlAction::ReplaceActionId(CXTPControlAction *pAction, int nId)
{
	m_pActions->ReplaceActionId(pAction, nId);
}

void CTreeCtrlAction::RefreshResourceManager()
{
	m_pResManager->FreeAll();

	for (int i = 0; i < m_pActions->GetCount(); i++)
	{
		m_pResManager->Set(m_pActions->GetAt(i)->GetID(), m_pActions->GetAt(i)->GetKey());
	}
}


BOOL CTreeCtrlAction::SaveTreeData(XTPTVITEMS &tis, HTREEITEM hItem, XTPTreeParam tp)
{
	WORD wCurNode = 0;

	if (tp != xtpParamNone)
	{
		tis.items = 0;
		tis.vtn[0].hti = 0;
	}
	else
	{
		CXTPString str = GetItemText(hItem);
		if (tis.vtn.size())
		{
			tis.items++;
			XTPTVITEM& tn = tis.vtn[tis.items];
			tn.size = strlen(str);
			tn.hti = hItem;
			tn.buf = new char[tn.size + 1];
			if (tn.buf == NULL) return FALSE;
			strcpy(tn.buf, str);
			tn.state = CXTPTreeCtrl::GetItemState(hItem, TVIF_STATE);
			GetItemImage(hItem, tn.img, tn.sel);
			CXTPControlAction *pAction = (CXTPControlAction*)GetItemData(hItem);
			if (pAction)
			{
				void* rValue;
				if(LookupPtr(pAction->GetID(), rValue))
				{
					LPTVACTIONTAG pTag = (LPTVACTIONTAG)rValue;
					tn.id = pTag->id;
					tn.pid = pTag->pid;
					tn.lv = pTag->lv;
					tn.tag = (DWORD_PTR)pTag;
				}
			}
			else
			{
				tn.id = 0;
				tn.pid = 0;
				tn.lv = 0;
				tn.tag = NULL;
			}

			wCurNode = tis.items;
			tis.vtn[wCurNode].items = 0;
		}
		hItem = GetChildItem(hItem);
	}

	while(hItem != NULL)
	{
		tis.vtn[wCurNode].items++;
		if (!SaveTreeData(tis, hItem)) // If an error occurs return from all levels of recursion.
			return FALSE;

		if (tp == xtpParamSubTree)
			return TRUE;
		else
			hItem = GetNextSiblingItem(hItem);
	}

	return TRUE;
}

BOOL CTreeCtrlAction::LoadTreeData(XTPTVITEMS &tis, HTREEITEM hItem, XTPTreeParam tp)
{
	WORD wCurNode;
	static int wAllocateItems = 0;
	static BOOL ret = TRUE;

	if (tp != xtpParamNone)
	{
		wAllocateItems = tis.items;
		tis.items = 0;
	}
	wCurNode = tis.items;

	for (int i = 0; i < tis.vtn[wCurNode].items; i++)
	{
		if (tp == xtpParamSubTree && wAllocateItems == tis.items)
			return TRUE;
		tis.items++;

		if (tis.items > wAllocateItems)
		{
			tis.items = wAllocateItems;
			return FALSE;
		}
		XTPTVITEM& tn = tis.vtn[tis.items];
		HTREEITEM hSonItem = InsertItem(CXTPString(tn.buf), tn.img, tn.sel, hItem);
		tn.hti = hSonItem;

		CString strKeyAction,lpszCategory;
		strKeyAction.Format(_T("%d"),tn.id);
		lpszCategory.Format(_T("%d"),tn.pid);
		CString strCaption = CXTPString(tn.buf);
		LPTVACTIONTAG pTag = (LPTVACTIONTAG)tn.tag;
		if(pTag) AddAction(hSonItem, strCaption, tn.id, tn.pid, tn.lv, strKeyAction, lpszCategory, tn.img, strCaption, strCaption,(DWORD_PTR)pTag);
		SetAtPtr(tn.id, pTag);

		ret = LoadTreeData(tis, hSonItem);
		if (!ret)
			return FALSE;
	}

	return TRUE;
}

BOOL CTreeCtrlAction::SaveIndentTreeToFile1(const char *lpszFileName, XTPTVITEMS &tis)
{
	try
	{
		int iMaxLevel = CalculateMaxLevel(tis), iLevel;
		int iPreviousLevel = -1;
		char szRecord[256];

		if (iMaxLevel > 256) throw xtpErrorMaxLevel;
		int *piCurrentLevels = new int[iMaxLevel];
		if (piCurrentLevels == NULL) throw xtpErrorMemory;
		for (int i = 0; i < iMaxLevel; i++)
			piCurrentLevels[i] = 0;

		FILE *fp = fopen(lpszFileName, "wt");
		if (fp == NULL) throw xtpErrorOpen;
		for (int i = 1; i <= tis.items; i++)
		{
			*szRecord = 0;
			iLevel = tis.vtn[i].lv;
			if (iLevel < iPreviousLevel)
			{
				for (int j=iLevel; j<iMaxLevel; j++)                            
					piCurrentLevels[j] = 0;
			}
			piCurrentLevels[iLevel - 1]++;
			iPreviousLevel = iLevel;
			for (int j=0; j<iLevel; j++)
			{
				CXTPString str;
				str.Format("%d", piCurrentLevels[j]);
				strcat(szRecord, str);
				strcat(szRecord, "-");
			}
			if (iLevel != 1)
				szRecord[strlen(szRecord) - 1] = 0;
			strcat(szRecord, "\t");
			strcat(szRecord, tis.vtn[i].buf);
			fprintf(fp, "%s,%d\n", szRecord,tis.vtn[i].id);
			if (ferror(fp)) throw xtpErrorWrite;
		}

		fclose(fp);
		if (feof(fp)) throw xtpErrorClose;

		if (piCurrentLevels != NULL)
			delete [] piCurrentLevels;
	}
	catch(XTPTreeError te)
	{
		CString str;
		switch(te)
		{
		case xtpErrorMaxLevel:
			str.Format(_T("Up to %d levels are supported!"), 256);
			break;
		case xtpErrorMemory:
			str.Format(_T("Out of memory"));
			break;
		case xtpErrorWrite:
			str.Format(_T("Cannot write to indent tree file %s: %s"), lpszFileName,  _wcserror(errno));
			break;
		case xtpErrorClose:
			str.Format(_T("Cannot close output indent tree file %s: %s"), lpszFileName,  _wcserror(errno));
			break;
		case xtpErrorOpen:
			str.Format(_T("Cannot open output indent tree file %s: %s"), lpszFileName,  _wcserror(errno));
			break;
		}
		AfxMessageBox(str);
		return FALSE;
	}

	return TRUE;
}

BOOL CTreeCtrlAction::SaveCsvTreeToFile(const char *lpszFileName, XTPTVITEMS &tis)
{
	try
	{
		FILE *fp = fopen(lpszFileName, "wt");
		if (fp == NULL) throw xtpErrorOpen;

		CString str;
		int iMaxLevel = CalculateMaxLevel(tis);
		char szRecord[256];

		for (int i = 1; i <= tis.items; i++)
		{
			*szRecord = 0;
			int iLevel = tis.vtn[i].lv;
			for (int j=1; j<=iMaxLevel; j++)
			{
				if (j == iLevel)
					strcat(szRecord, tis.vtn[i].buf);
				if (j != iMaxLevel)
					strcat(szRecord, GetDelimiter());
			}
			fprintf(fp, "%s,%d,%d\n", szRecord,tis.vtn[i].id,tis.vtn[i].pid);
			if (ferror(fp)) throw xtpErrorWrite;
		}

		fclose(fp);
		if (feof(fp)) throw xtpErrorClose;
	}
	catch(XTPTreeError te)
	{
		CString str;
		switch(te)
		{
		case xtpErrorWrite:
			str.Format(_T("Cannot write to csv tree file %s: %s"), lpszFileName,  _wcserror(errno));
			break;
		case xtpErrorClose:
			str.Format(_T("Cannot close output csv tree file %s: %s"), lpszFileName,  _wcserror(errno));
			break;
		case xtpErrorOpen:
			str.Format(_T("Cannot open output csv tree file %s: %s"), lpszFileName,  _wcserror(errno));
			break;
		}
		AfxMessageBox(str);
		return FALSE;
	}

	return TRUE;
}

BOOL CTreeCtrlAction::SaveTagToFile(const char *lpszFileName, XTPTVITEMS &tis)
{
	try
	{
		FILE *fp = fopen(lpszFileName, "wt");
		if (fp == NULL || tis.items == 0) throw xtpErrorMemory;

		XTPJSON::Value val;
		val["Count"] = tis.items;

		XTPJSON::Value Tags;
		XTPTVITEMVECTOR vtn = tis.vtn;
		int n = vtn.size();
		for (int i = 0; i < n; i++)
		{
			XTPTVITEM& tn = tis.vtn[i];
			LPTVACTIONTAG pTag = (LPTVACTIONTAG)tn.tag;
			if (pTag) Tags.append(pTag->ToJson());
		}
		val["Tags"] = Tags;

		XTPJSON::FastWriter writer;
		string json = writer._write(val);
		fprintf(fp, "%s", json.c_str());
		if (feof(fp)) throw xtpErrorWrite;

		fclose(fp);
		if (feof(fp)) throw xtpErrorClose;
	}
	catch(XTPTreeError te)
	{
		CString str;
		switch(te)
		{
		case xtpErrorMemory:
			str.Format(_T("Out of memory"));
			break;
		case xtpErrorWrite:
			str.Format(_T("Cannot write to json tag file %s: %s"), lpszFileName,  _wcserror(errno));
			break;
		case xtpErrorClose:
			str.Format(_T("Cannot close output json tag file %s: %s"), lpszFileName,  _wcserror(errno));
			break;
		}
		AfxMessageBox(str);

		return FALSE;
	}

	return TRUE;
}

BOOL CTreeCtrlAction::LoadTagFromFile(const char *lpszFileName, XTPTVITEMS &tis)
{
	try
	{
		filebuf file;
		if (!file.open(lpszFileName, ios::in)) throw xtpErrorOpen;

		istream ist(&file);
		XTPJSON::Reader reader;
		XTPJSON::Value val;

		if (!reader.parse(ist, val, false)) throw xtpErrorRead;

		WORD wTotalItems = val["Count"].asInt();
		if (wTotalItems == 0) throw xtpErrorEmptyFile;

		const XTPJSON::Value Tags = val["Tags"];
		int n = Tags.size();
		if (wTotalItems != n+1) throw xtpErrorInvalidFile;
		for (int i = 0; i < n; i++)
		{
			XTPTVITEM& tn = tis.vtn[i+2];
			LPTVACTIONTAG pTag = new TVACTIONTAG;
			pTag->ReadJson(Tags[i]);
			SetAtPtr(pTag->id, pTag);

			CString strKeyAction,lpszCategory;
			strKeyAction.Format(_T("%d"),tn.id);
			lpszCategory.Format(_T("%d"),tn.pid);
			CString strCaption = CXTPString(tn.buf);
			SetAction(tn.hti, strCaption, tn.id, tn.pid, tn.lv, strKeyAction, lpszCategory, tn.img, strCaption, strCaption,(DWORD_PTR)pTag);
		}

		if(!file.close()) throw xtpErrorClose;
		tis.items = wTotalItems;
	}
	catch(XTPTreeError te)
	{
		CXTPString str;
		switch(te)
		{
		case xtpErrorEmptyFile:
			str.Format("Input json tag file %s is empty", lpszFileName);
			break;
		case xtpErrorMemory:
			str.Format("Out of memory");
			break;
		case xtpErrorRead:
			str.Format("Cannot read from json tag file %s: %s", lpszFileName,  strerror(errno));
			break;
		case xtpErrorClose:
			str.Format("Cannot close input json tag file %s: %s", lpszFileName,  strerror(errno));
			break;
		case xtpErrorOpen:
			str.Format("Cannot open input json tag file %s: %s", lpszFileName,  strerror(errno));
			break;
		case xtpErrorInvalidFile:
			str.Format("Input json tag file: %s is invalid or empty", lpszFileName);
			break;
		}
		AfxMessageBox(str);

		return FALSE;
	}

	return TRUE;
}

BOOL CTreeCtrlAction::SaveExcelTreeToFile(const char *lpszFileName, XTPTVITEMS &tis)
{
	try
	{
		CXTPExcelUtil excel;
		excel.InitExcel();
		excel.CloseAlert();
		if(!excel.CreateExcel(CXTPString(lpszFileName))) throw xtpErrorCreate;
		if(!excel.OpenExcel(CXTPString(lpszFileName))) throw xtpErrorOpen;
		if(!excel.LoadSheet(1)) throw xtpErrorWrite;

		int iMaxLevel = CalculateMaxLevel(tis);
		int iRow = 1;

		for (int i=1; i<=iMaxLevel; i++)
		{
			excel.SetCell(CXTPMathUtils::DigitalSerialNumber(i)+_T("级"), iRow, i);
		}

		iRow = 2;
		int iPreviousLevel = -1;
		for (int i = 1; i <= tis.items; i++)
		{
			XTPTVITEM& tn = tis.vtn[i];
			int iLevel = GetItemLevel(tn.hti);
			//int iLevel = tn.lv;

			if (iLevel == iPreviousLevel || iLevel < iPreviousLevel)
				iRow++;

			excel.SetCell(CXTPString(tn.buf), iRow, iLevel);

			iPreviousLevel = iLevel;
		}

		for (int i = 1; i <= iRow; i++)
		{
			for (int j=1; j<=iMaxLevel; j++)
			{
				excel.SetCellBorder(i, j, 1, 2, RGB(255,0,0));
			}
		}

		excel.SetColumnsAutoFit(iMaxLevel);
		excel.SetRowsAutoFit(iRow);

		excel.Save();
		excel.CloseExcel();
		excel.ReleaseExcel();
	}
	catch(XTPTreeError te)
	{
		CString str;
		switch(te)
		{
		case xtpErrorWrite:
			str.Format(_T("Cannot write to excel tree file %s: %s"), lpszFileName,  _wcserror(errno));
			break;
		case xtpErrorCreate:
			str.Format(_T("Cannot create excel tree file %s: %s"), lpszFileName,  _wcserror(errno));
			break;
		case xtpErrorOpen:
			str.Format(_T("Cannot open output excel tree file %s: %s"), lpszFileName,  _wcserror(errno));
			break;
		}
		AfxMessageBox(str);
		return FALSE;
	}

	return TRUE;
}


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CXTPControlAction* CActions::operator[](int nIndex)
{
	return GetAt(nIndex);
}

int CActions::InsertAction(CXTPControlAction* pAction)
{
	int nIndex = 0;
	for (; nIndex < GetCount(); nIndex++)
	{
		if (GetAt(nIndex)->GetID() > pAction->GetID())
			break;
	}

	m_arrActions.InsertAt(nIndex, pAction);
	return nIndex;
}

CXTPControlAction* CActions::AddAction(UINT nID, LPCTSTR lpszKey, LPCTSTR lpszCategory, UINT nImage, LPCTSTR lpszDescription, LPCTSTR lpszTooltip)
{
	CXTPControlAction* pAction = Add(nID);
	pAction->SetKey(lpszKey);
	pAction->SetCategory(lpszCategory);
	if(nImage > 0) pAction->SetIconId(nImage);
	if(_tcslen(lpszDescription)) pAction->SetDescription(lpszDescription);
	if(_tcslen(lpszTooltip)) pAction->SetTooltip(lpszTooltip);
	return pAction;
}

CXTPControlAction* CActions::AddAction(UINT nID, UINT nIconID, UINT nHelpID, LPCTSTR lpszKey, LPCTSTR lpszCategory, UINT nImage, LPCTSTR lpszDescription, LPCTSTR lpszTooltip)
{
	CXTPControlAction* pAction = Add(nID);
	pAction->SetIconId(nIconID);
	pAction->SetHelpId(nHelpID);
	pAction->SetKey(lpszKey);
	pAction->SetCategory(lpszCategory);
	if(nImage > 0) pAction->SetIconId(nImage);
	if(_tcslen(lpszDescription)) pAction->SetDescription(lpszDescription);
	if(_tcslen(lpszTooltip)) pAction->SetTooltip(lpszTooltip);
	return pAction;
}

CXTPControlAction* CActions::AddAction(LPCTSTR lpszCaption, UINT nID, LPCTSTR lpszKey, LPCTSTR lpszCategory, UINT nImage, LPCTSTR lpszDescription, LPCTSTR lpszTooltip)
{
	CXTPControlAction* pAction = Add(nID);
	pAction->SetCaption(lpszCaption);
	pAction->SetKey(lpszKey);
	pAction->SetCategory(lpszCategory);
	if(nImage > 0) pAction->SetIconId(nImage);
	if(_tcslen(lpszDescription)) pAction->SetDescription(lpszDescription);
	if(_tcslen(lpszTooltip)) pAction->SetTooltip(lpszTooltip);
	return pAction;
}

CXTPControlAction* CActions::AddAction(LPCTSTR lpszCaption, UINT nID, UINT nIconID, UINT nHelpID, LPCTSTR lpszKey, LPCTSTR lpszCategory, UINT nImage, LPCTSTR lpszDescription, LPCTSTR lpszTooltip)
{
	CXTPControlAction* pAction = Add(nID);
	pAction->SetIconId(nIconID);
	pAction->SetHelpId(nHelpID);
	pAction->SetCaption(lpszCaption);
	pAction->SetKey(lpszKey);
	pAction->SetCategory(lpszCategory);
	if(nImage > 0) pAction->SetIconId(nImage);
	if(_tcslen(lpszDescription)) pAction->SetDescription(lpszDescription);
	if(_tcslen(lpszTooltip)) pAction->SetTooltip(lpszTooltip);
	return pAction;
}

int CActions::GetIndex(CXTPControlAction* pAction)
{
	for (int nIndex = 0; nIndex < GetCount(); nIndex++)
	{
		if (GetAt(nIndex)->GetID() == pAction->GetID())
			return nIndex;
	}

	return -1;
}

int CActions::GetIndex(UINT nID)
{
	for (int nIndex = 0; nIndex < GetCount(); nIndex++)
	{
		if (GetAt(nIndex)->GetID() == nID)
			return nIndex;
	}

	return -1;
}

void CActions::DeleteAction(CXTPControlAction* pAction)
{
	for (int i = 0; i < GetCount(); i++)
	{
		if (GetAt(i) == pAction)
		{
			m_arrActions.RemoveAt(i);

			pAction->InternalRelease();
		}
	}
}

void CActions::ReplaceActionId(CXTPControlAction* pAction, int nID)
{
	if (FindAction(nID) != 0)
		return;

	for (int i = 0; i < GetCount(); i++)
	{
		if (GetAt(i) == pAction)
		{
			m_arrActions.RemoveAt(i);

			SetActionId(pAction, nID);			
			Insert(pAction);
		}
	}
}

