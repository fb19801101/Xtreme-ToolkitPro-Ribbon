#if !defined(AFX_CUSTOMIZEPAGEGENERAL_H__0CAF45CE_5C45_41A3_A227_61AFB789188C__INCLUDED_)
#define AFX_CUSTOMIZEPAGEGENERAL_H__0CAF45CE_5C45_41A3_A227_61AFB789188C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// CustomizePageGeneral.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CCustomizePageGeneral dialog

class CCustomizePageGeneral : public CXTPPropertyPage
{
	DECLARE_DYNCREATE(CCustomizePageGeneral)

// Construction
public:
	CCustomizePageGeneral();
	~CCustomizePageGeneral();

// Dialog Data
	//{{AFX_DATA(CCustomizePageGeneral)
	enum { IDD = IDD_CUSTOMIZEPAGE_GENERAL };
	BOOL	m_bShowKeyboardTips;
	BOOL	m_bShowMiniToolbar;
	int		m_nColor;
	//}}AFX_DATA


// Overrides
	// ClassWizard generate virtual function overrides
	//{{AFX_VIRTUAL(CCustomizePageGeneral)
	public:
	virtual void OnOK();
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

	CXTPMarkupStatic m_wndCaption1;
	CXTPMarkupStatic m_wndTitle;
	BOOL OnInitDialog();

// Implementation
protected:
	// Generated message map functions
	//{{AFX_MSG(CCustomizePageGeneral)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CUSTOMIZEPAGEGENERAL_H__0CAF45CE_5C45_41A3_A227_61AFB789188C__INCLUDED_)
