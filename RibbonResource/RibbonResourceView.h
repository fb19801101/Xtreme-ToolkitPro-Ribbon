// RibbonResourceView.h : interface of the CRibbonResourceView class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_RIBBONRESOURCEVIEW_H__2D2EF93C_3FBF_46BF_A4F6_42DB8C75A968__INCLUDED_)
#define AFX_RIBBONRESOURCEVIEW_H__2D2EF93C_3FBF_46BF_A4F6_42DB8C75A968__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000


class CRibbonResourceView : public CRichEditView
{
protected: // create from serialization only
	CRibbonResourceView();
	DECLARE_DYNCREATE(CRibbonResourceView)

// Attributes
public:
	CRibbonResourceDoc* GetDocument();

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CRibbonResourceView)
	public:
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	virtual void OnInitialUpdate();
	protected:
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	//}}AFX_VIRTUAL
	void OnFilePrintPreview();

// Implementation
public:
	virtual ~CRibbonResourceView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:
	CFont m_fnt;

// Generated message map functions
protected:
	//{{AFX_MSG(CRibbonResourceView)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

#ifndef _DEBUG  // debug version in RibbonResourceView.cpp
inline CRibbonResourceDoc* CRibbonResourceView::GetDocument()
   { return (CRibbonResourceDoc*)m_pDocument; }
#endif

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_RIBBONRESOURCEVIEW_H__2D2EF93C_3FBF_46BF_A4F6_42DB8C75A968__INCLUDED_)
