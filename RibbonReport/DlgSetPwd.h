// DlgSetPwd.h : header file
//

#pragma once

#include "resource.h"
#include "afxwin.h"
class CDlgSetPwd : public CDialog
{
public:
	CDlgSetPwd(CWnd* pParent = NULL);

	enum { IDD = IDD_DLG_SETPWD };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);

protected:
	HICON m_hIcon;

	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()

public:
	CString m_strUser;
	CString m_strPwd;
	CString m_strPwd2;
	CString m_strPwd3;
};
