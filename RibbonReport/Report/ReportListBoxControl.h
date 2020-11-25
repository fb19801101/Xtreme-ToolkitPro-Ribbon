// ReportListBoxControl.h: interface for the CReportListBoxControl class.
//


#pragma once

class CXTPReportControl;
class CXTPReportRecord;
class CReportListBoxControl : public CXTPListBox
{
	DECLARE_DYNAMIC(CReportListBoxControl)
public:
	CReportListBoxControl();
	~CReportListBoxControl();

public:
	BOOL SetReportCtrl(CXTPReportControl* pReportCtrl);
	CXTPReportControl* GetReportCtrl();

public:
	void SetConnection(CXTPADOConnection& con);
	CXTPADOConnection& GetConnection();
	BOOL UpdateList();
	CString GetItemCaption(int nIndex);
	CXTPReportRecord* GetItemRecord(int nIndex);
	CString GetCurItemCaption();
	CXTPReportRecord* GetCurItemRecord();

protected:
//{{AFX_CODEJOCK_PRIVATE
	DECLARE_MESSAGE_MAP()

	//{{AFX_VIRTUAL(CReportListBoxControl)
	public:
	virtual void DrawItem(LPDRAWITEMSTRUCT lpDrawItemStruct);
	protected:
	virtual void PreSubclassWindow();
	//}}AFX_VIRTUAL

	//{{AFX_MSG(CReportListBoxControl)
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	afx_msg void OnPaint();
	afx_msg LRESULT OnPrintClient(WPARAM wParam, LPARAM lParam);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	//}}AFX_MSG
//}}AFX_CODEJOCK_PRIVATE

protected:
	CXTPReportControl* m_pReportCtrl;       // Pointer to the parent report control.
	CXTPTipWindow m_tipWindow;
};
