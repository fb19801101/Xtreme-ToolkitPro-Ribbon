// DlgReg.h : header file
//

#pragma once

#include "resource.h"
class CDlgReg : public CDialog
{
public:
	CDlgReg(CWnd* pParent = NULL);

	enum { IDD = IDD_DLG_REG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);

protected:
	HICON m_hIcon;

	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()

public:
	afx_msg void OnBnClickedRegBnCode();
	afx_msg void OnBnClickedRegBnSerial();
	afx_msg void OnBnClickedRegBnReg();
	afx_msg void OnBnClickedRegBnExit();
};
