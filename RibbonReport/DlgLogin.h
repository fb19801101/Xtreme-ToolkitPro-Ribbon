// DlgLogin.h : header file
//

#pragma once

#include "resource.h"
#include "afxwin.h"
class CDlgLogin : public CDialog
{
public:
	CDlgLogin(CWnd* pParent = NULL);

	enum { IDD = IDD_DLG_LOGIN };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);

protected:
	HICON m_hIcon;

	virtual BOOL OnInitDialog();
	virtual void OnOK();
	DECLARE_MESSAGE_MAP()

public:
	CString m_strUser;
	CString m_strPwd;
	BOOL m_bRemberPwd;
	BOOL m_bAutoLogin;
	BOOL m_bAutoFrame;

	CButton m_bnUser;
	CButton m_bnPwd;

	afx_msg void OnBnClickedLoginBnUser();
	afx_msg void OnBnClickedLoginBnPwd();
	afx_msg void OnBnClickedLoginCkPwd();
	afx_msg void OnBnClickedLoginCkLogin();
	afx_msg void OnBnClickedLoginCkFrame();
};
