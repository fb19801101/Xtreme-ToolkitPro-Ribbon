// DlgLoan.h : header file
//

#pragma once

#include "resource.h"

class CDlgLoan : public CDialog
{
public:
	CDlgLoan(CWnd* pParent = NULL);

	enum { IDD = IDD_DLG_LOAN };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);

protected:
	HICON m_hIcon;

	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()

public:
	CListCtrl	m_listPrincipal;
	CListCtrl	m_listInterest;
	double	m_fYearRate;
	double	m_fTotalInterest;
	int		m_nLoanYears;
	double	m_fMonthRepayment;
	double	m_fLoanTotal;
	double	m_fYearRepayment;
	double	m_fMonthRate;
	double	m_fMonthRate2;
	double	m_fYearRate2;
	double	m_fTotalInterest2;
	double	m_fDayRate;
	BOOL	m_bEqualMonthRate;

	void InitListPrincipal(int flag);
	void InitListInterest();
	afx_msg void OnBnCalcequalmortgage();
	afx_msg void OnBnCheckyearprincipal();
	afx_msg void OnBnClacmonthmortgage();
};