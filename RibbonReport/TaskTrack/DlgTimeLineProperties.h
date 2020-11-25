#if !defined(AFX_DLGTIMELINEPROPERTIES_H__09F62D04_C136_4376_8B7D_C468F3A9F9DE__INCLUDED_)
#define AFX_DLGTIMELINEPROPERTIES_H__09F62D04_C136_4376_8B7D_C468F3A9F9DE__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// DialogTimeLineProperties.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CDlgTimeLineProperties dialog

class CDlgTimeLineProperties : public CDialog
{
// Construction
public:
	CDlgTimeLineProperties(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CDlgTimeLineProperties)
	enum { IDD = IDD_DLG_PROPERTIES };
	int		m_nMin;
	int		m_nMax;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CDlgTimeLineProperties)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CDlgTimeLineProperties)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_DLGTIMELINEPROPERTIES_H__09F62D04_C136_4376_8B7D_C468F3A9F9DE__INCLUDED_)
