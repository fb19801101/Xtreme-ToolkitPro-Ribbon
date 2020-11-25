// RibbonResourceDoc.h : interface of the CRibbonResourceDoc class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_RIBBONRESOURCEDOC_H__A101014F_EAC4_4675_AC3C_334F06B4C181__INCLUDED_)
#define AFX_RIBBONRESOURCEDOC_H__A101014F_EAC4_4675_AC3C_334F06B4C181__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000


class CRibbonResourceDoc : public CRichEditDoc
{
protected: // create from serialization only
	CRibbonResourceDoc();
	DECLARE_DYNCREATE(CRibbonResourceDoc)

// Attributes
public:

// Operations
public:
	virtual CRichEditCntrItem* CreateClientItem(REOBJECT* preo) const;

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CRibbonResourceDoc)
	public:
	virtual BOOL OnNewDocument();
	virtual void Serialize(CArchive& ar);
	//}}AFX_VIRTUAL

// Implementation
public:
	virtual ~CRibbonResourceDoc();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	//{{AFX_MSG(CRibbonResourceDoc)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_RIBBONRESOURCEDOC_H__A101014F_EAC4_4675_AC3C_334F06B4C181__INCLUDED_)
