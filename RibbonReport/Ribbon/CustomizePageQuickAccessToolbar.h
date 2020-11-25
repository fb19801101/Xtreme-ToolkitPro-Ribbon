#if !defined(AFX_CUSTOMIZEPAGEQUICKACCESSTOOLBAR_H__163B7B41_F44C_432F_8D73_B0996EDF2E56__INCLUDED_)
#define AFX_CUSTOMIZEPAGEQUICKACCESSTOOLBAR_H__163B7B41_F44C_432F_8D73_B0996EDF2E56__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// CustomizePageQuickAccessToolbar.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CCustomizePageQuickAccessToolbar dialog

class CCustomizePageQuickAccessToolbar : public CXTPRibbonCustomizeQuickAccessPage
{
// Construction
public:
	CCustomizePageQuickAccessToolbar(CXTPCommandBars* pCommandBars);
	~CCustomizePageQuickAccessToolbar();


// Dialog Data
	//{{AFX_DATA(CCustomizePageQuickAccessToolbar)
		// NOTE - ClassWizard will add data members here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_DATA


// Overrides
	// ClassWizard generate virtual function overrides
	//{{AFX_VIRTUAL(CCustomizePageQuickAccessToolbar)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL
	BOOL OnInitDialog();

// Implementation
protected:
	// Generated message map functions
	//{{AFX_MSG(CCustomizePageQuickAccessToolbar)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CUSTOMIZEPAGEQUICKACCESSTOOLBAR_H__163B7B41_F44C_432F_8D73_B0996EDF2E56__INCLUDED_)
