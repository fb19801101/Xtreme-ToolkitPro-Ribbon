#if !defined(AFX_BACKSTAGEPAGEPRINT_H__A1221CB4_7CFC_47DB_8765_D3812497F8A4__INCLUDED_)
#define AFX_BACKSTAGEPAGEPRINT_H__A1221CB4_7CFC_47DB_8765_D3812497F8A4__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// BackstagePagePrint.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CBackstagePagePrint dialog

class CBackstagePagePrint : public CXTPRibbonBackstagePage
{
	DECLARE_DYNCREATE(CBackstagePagePrint)

// Construction
public:
	CBackstagePagePrint();
	~CBackstagePagePrint();

// Dialog Data
	//{{AFX_DATA(CBackstagePagePrint)
	enum { IDD = IDD_BACKSTAGEPAGE_PRINT };
	int		m_nCopies;
	//}}AFX_DATA

	CXTPRibbonBackstageButton m_btnPrint;
	CXTPRibbonBackstageSeparator m_lblSeparator4;
	CXTPRibbonBackstageSeparator m_lblSeparator1;
	void InitButton(UINT nID);

	CXTPRibbonBackstageLabel m_lblPrint;

	BOOL OnSetActive();
	BOOL OnKillActive();

	class CBackstagePreviewView : CXTPPreviewView
	{

		friend class CBackstagePagePrint;
	};
	
	class CBackstagePrintView : CView
	{
		
		friend class CBackstagePagePrint;
	};

	CBackstagePreviewView* m_pPreviewView;
	CFrameWnd* m_pFrameWnd;
	CBackstagePrintView* m_pView;

	void UpdateCopies(BOOL bSaveAndValidate);
	
	BOOL CreatePrintPreview();

	BOOL OnInitDialog();
// Overrides
	// ClassWizard generate virtual function overrides
	//{{AFX_VIRTUAL(CBackstagePagePrint)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	// Generated message map functions
	//{{AFX_MSG(CBackstagePagePrint)
	afx_msg void OnButtonPrint();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_BACKSTAGEPAGEPRINT_H__A1221CB4_7CFC_47DB_8765_D3812497F8A4__INCLUDED_)
