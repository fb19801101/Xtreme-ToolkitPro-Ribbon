#if !defined(AFX_CUSTOMIZEPAGERIBBON_H__5EE0BF5B_4AE4_43BE_9EC0_CD0A5C36ECB3__INCLUDED_)
#define AFX_CUSTOMIZEPAGERIBBON_H__5EE0BF5B_4AE4_43BE_9EC0_CD0A5C36ECB3__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// CustomizePageRibbon.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CCustomizePageRibbon dialog

class CCustomizePageRibbon : public CXTPRibbonCustomizePage
{

// Construction
public:
	CCustomizePageRibbon(CXTPCommandBars* pCommandBars);
	~CCustomizePageRibbon();

// Dialog Data
	//{{AFX_DATA(CCustomizePageRibbon)
		// NOTE - ClassWizard will add data members here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_DATA


// Overrides
	// ClassWizard generate virtual function overrides
	//{{AFX_VIRTUAL(CCustomizePageRibbon)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

	BOOL OnInitDialog();

	void OnButtonReset();

// Implementation
protected:
	// Generated message map functions
	//{{AFX_MSG(CCustomizePageRibbon)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CUSTOMIZEPAGERIBBON_H__5EE0BF5B_4AE4_43BE_9EC0_CD0A5C36ECB3__INCLUDED_)
