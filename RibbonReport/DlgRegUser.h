// DlgRegUser.h : header file
//

#pragma once

#include "resource.h"
#include "afxwin.h"
class CDlgRegUser : public CDialog
{
public:
	CDlgRegUser(CWnd* pParent = NULL);

	enum { IDD = IDD_DLG_REGUSER };

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
};
