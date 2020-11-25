// ShellListView.cpp : implementation file
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "ShellListView.h"
#include "ShellTreeView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CShellListView

IMPLEMENT_DYNCREATE(CShellListView, CXTPShellListView)

CShellListView::CShellListView()
{
	m_bSortColor = true;

	COLORREF crSortBack(GetXtremeColor(COLOR_WINDOW));
	crSortBack = RGB(max(0, GetRValue(crSortBack) - 8), max(0, GetGValue(crSortBack) - 8), max(0, GetBValue(crSortBack) - 8));

	SetSortTextColor(GetXtremeColor(COLOR_WINDOWTEXT));
	SetSortBackColor(crSortBack);

	m_iItem = -1;
	m_iSubItem = -1;
	m_idShellStyle = -1;
	m_idShellSort = -1;

	m_pShellTreeView = NULL;
}

CShellListView::~CShellListView()
{
}


BEGIN_MESSAGE_MAP(CShellListView, CXTPShellListView)
	//{{AFX_MSG_MAP(CShellListView)
		// NOTE - the ClassWizard will add and remove mapping macros here.
	//}}AFX_MSG_MAP
	ON_SHELLLIST_REFLECT()
	ON_WM_DROPFILES()
	ON_MESSAGE(WM_USER_DROPFILESTOLISTCTRL, OnDropFilesToListCtrl)
	//}}AFX_MSG_MAP
	ON_NOTIFY_REFLECT(LVN_ITEMCHANGED, OnLVNItemChanged)
	ON_NOTIFY_REFLECT(LVN_ENDLABELEDIT, OnLVNEndlabelEdit)
	//}}AFX_MSG_MAP
	ON_COMMAND_RANGE(ID_SHELL_STYLE_ICON, ID_SHELL_STYLE_REPORT, OnShellStyle)
	ON_UPDATE_COMMAND_UI_RANGE(ID_SHELL_STYLE_ICON, ID_SHELL_STYLE_REPORT, OnUpdateShellStyle)
	ON_COMMAND_RANGE(ID_SHELL_SORT_NAME, ID_SHELL_SORT_DATE, OnShellSort)
	ON_UPDATE_COMMAND_UI_RANGE(ID_SHELL_SORT_NAME, ID_SHELL_SORT_DATE, OnUpdateShellSort)
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// CShellListView diagnostics

#ifdef _DEBUG
void CShellListView::AssertValid() const
{
	CXTPShellListView::AssertValid();
}

void CShellListView::Dump(CDumpContext& dc) const
{
	CXTPShellListView::Dump(dc);
}
#endif //_DEBUG


/////////////////////////////////////////////////////////////////////////////
// CShellListView message handlers

BOOL CShellListView::PreCreateWindow(CREATESTRUCT& cs) 
{
	if (!CXTPShellListView::PreCreateWindow(cs))
		return FALSE;

	cs.style |= WS_VISIBLE|WS_TABSTOP|LVS_AUTOARRANGE|
		LVS_ICON|LVS_EDITLABELS|LVS_SHOWSELALWAYS;
	cs.dwExStyle |= WS_EX_STATICEDGE|WS_EX_ACCEPTFILES|LVS_EX_FULLROWSELECT;
	
	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// CShellListView message handlers

void CShellListView::OnInitialUpdate()
{
	CXTPShellListView::OnInitialUpdate();
	m_pListCtrl->ModifyStyle(LVS_TYPEMASK,LVS_REPORT & LVS_TYPEMASK);
}

void CShellListView::OnDropFiles(HDROP hDropInfo)
{
	UINT  nNumOfFiles = DragQueryFile(hDropInfo, 0xFFFFFFFF, NULL, 0); //文件的个数
	for ( UINT nIndex=0 ; nIndex< nNumOfFiles; ++nIndex )
	{
		XTPCHAR lpszPathName[_MAX_PATH] = {0};
		DragQueryFile(hDropInfo, nIndex, lpszPathName, _MAX_PATH);  //得到文件名
		// 把得到的文件名传给父窗口
		LPARAM lParam = (LPARAM)lpszPathName;
		SendMessage(WM_USER_DROPFILESTOLISTCTRL,0,lParam);
	}
	DragFinish(hDropInfo);

	CXTPShellListView::OnDropFiles(hDropInfo);
}

LRESULT CShellListView::OnDropFilesToListCtrl(WPARAM wParam, LPARAM lParam)
{
	XTPCHAR* lpszPathName = (XTPCHAR*)lParam;
	CXTPString strSrcPathName(lpszPathName);
	int idx = strSrcPathName.ReverseFind('\\');
	if(idx != -1 && m_pShellTreeView != NULL)
	{
		CString strFileName = strSrcPathName.Mid(idx, strSrcPathName.GetLength()-idx);
		CString strItemPath;
		m_pShellTreeView->GetSelectedFolderPath(strItemPath);
		idx = strItemPath.ReverseFind('.');
		if(idx != -1)
		{
			idx = strItemPath.ReverseFind('\\');
			strItemPath = strItemPath.Mid(0, idx);
		}
		CXTPString strDestPathName = strItemPath+strFileName;
		CopyFile(strSrcPathName, strDestPathName,TRUE);
		return TRUE;
	}

	return FALSE;
}

void CShellListView::OnLVNItemChanged(NMHDR *pNMHDR, LRESULT *pResult)
{
	NMLISTVIEW* pNMListView = (NMLISTVIEW*)pNMHDR;

	if((LVIF_STATE == pNMListView->uChanged) && (pNMListView->uNewState & LVIS_SELECTED))
	{
		m_iItem = pNMListView->iItem;
		if(m_iItem != -1) m_iSubItem = pNMListView->iSubItem;
	}

	*pResult = 0;
}

void CShellListView::OnLVNEndlabelEdit(NMHDR *pNMHDR, LRESULT *pResult)
{
	NMLVDISPINFO *pDispInfo = reinterpret_cast<NMLVDISPINFO*>(pNMHDR);

	if(pDispInfo->item.pszText != NULL)
	{
		m_pListCtrl->SetItemText(pDispInfo->item.iItem, 0, pDispInfo->item.pszText);
	
		//CEdit* pEdit = m_pListCtrl->EditLabel(pDispInfo->item.iItem);
		//if(!pEdit) return;
		//CString str;
		//pEdit->GetWindowText(str);

		CString strItemPath;
		GetItemPath(pDispInfo->item.iItem, strItemPath);
		CString strItemNewPath = strItemPath;
		int idx = strItemNewPath.ReverseFind('\\');
		CString strFileTitle = strItemNewPath.Mid(idx+1, strItemNewPath.GetLength()-idx);
		strItemNewPath.Replace(strFileTitle,pDispInfo->item.pszText);

		CXTPString oldname(strItemPath);
		CXTPString newname(strItemNewPath);
		rename(oldname.c_ptr(), newname.c_ptr());
	}

	*pResult = 0;
}

void CShellListView::DownLoad()
{
	CString strItemPath;
	GetItemPath(m_iItem, strItemPath);
	int idx = strItemPath.ReverseFind('.');
	if(idx != -1)
	{
		idx = strItemPath.ReverseFind('\\');
		CString strFileName = strItemPath.Mid(idx+1, strItemPath.GetLength()-idx);
		CFileDialog dlgFile(FALSE,NULL,strFileName);
		if (dlgFile.DoModal() == IDOK)
		{
			CXTPString strDestPath(dlgFile.GetPathName());
			CXTPString strSrcPath(strItemPath);
			CopyFile(strSrcPath, strDestPath, TRUE);
		}
	}
}

void CShellListView::UpLoad()
{
	CFileDialog dlgFile(TRUE,_T(""),_T("*.*"));
	if (dlgFile.DoModal() == IDOK)
	{
		CString strItemPath = dlgFile.GetPathName();
		int idx = strItemPath.ReverseFind('.');
		if(idx != -1)
		{
			idx = strItemPath.ReverseFind('\\');
			CString strFileName = strItemPath.Mid(idx+1, strItemPath.GetLength()-idx);

			if (m_pShellTreeView == NULL) return;
			CString strFolderPath;
			m_pShellTreeView->GetSelectedFolderPath(strFolderPath);
			strFolderPath = strFolderPath+_T("\\")+strFileName;
			CXTPString strDestPath(strFolderPath);
			CXTPString strSrcPath(strItemPath);
			CopyFile(strSrcPath, strDestPath, TRUE);
		}
	}
}

void CShellListView::Delete()
{
	CString strItemPath;

	GetItemPath(m_iItem, strItemPath);

	CString a =OneUpPATH(strItemPath);
	LPITEMIDLIST pidlPath = IDLFromPath(strItemPath);
	UINT m = GetPidlCount(pidlPath);
	UINT n = GetPidlItemCount(pidlPath);
	FreePidl(pidlPath);

	CXTPString strSrcPathName(strItemPath);
	DeleteFile(strSrcPathName);
}

void CShellListView::Flush()
{
	if (m_pShellTreeView == NULL) return;
	CString strFolderPath;
	m_pShellTreeView->GetSelectedFolderPath(strFolderPath);
	m_pShellTreeView->TunnelTree(strFolderPath);
}

void CShellListView::OnShellStyle(UINT nId)
{
	m_idShellStyle = nId;
	DWORD dwStyle = m_pListCtrl->GetStyle() & LVS_TYPEMASK;
	switch (m_idShellStyle)
	{
	case ID_SHELL_STYLE_ICON:
		dwStyle = LVS_ICON;
		break;
	case ID_SHELL_STYLE_SMALLICON:
		dwStyle = LVS_SMALLICON;
		break;
	case ID_SHELL_STYLE_LIST:
		dwStyle = LVS_LIST;
		break;
	case ID_SHELL_STYLE_REPORT:
		dwStyle = LVS_REPORT;
		break;
	}

	m_pListCtrl->ModifyStyle(LVS_TYPEMASK,dwStyle & LVS_TYPEMASK);
}

void CShellListView::OnUpdateShellStyle(CCmdUI* pCmdUI)
{
	pCmdUI->SetCheck(pCmdUI->m_nID == m_idShellStyle ? TRUE : FALSE);
}

void CShellListView::OnShellSort(UINT nId)
{
	m_idShellSort = nId;
	switch (m_idShellSort)
	{
	case ID_SHELL_SORT_NAME:
		SortList(0,true);
		break;
	case ID_SHELL_SORT_TYPE:
		SortList(2,true);
		break;
	case ID_SHELL_SORT_SIZE:
		SortList(1,true);
		break;
	case ID_SHELL_SORT_DATE:
		SortList(3,true);
		break;
	}
}

void CShellListView::OnUpdateShellSort(CCmdUI* pCmdUI)
{
	pCmdUI->SetCheck(pCmdUI->m_nID == m_idShellSort ? TRUE : FALSE);
}
