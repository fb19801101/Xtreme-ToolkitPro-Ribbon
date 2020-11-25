// DlgLoadPwd.h : header file
//

#pragma once

#include "resource.h"
#include "afxwin.h"
class CDlgLoadPwd : public CDialog
{
public:
	CDlgLoadPwd(CWnd* pParent = NULL);

	enum { IDD = IDD_DLG_LOADPWD };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);

protected:
	HICON m_hIcon;

	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()

public:
	CString m_strPwd;
};
