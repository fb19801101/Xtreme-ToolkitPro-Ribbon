#pragma once


// CDlgMethod 对话框

class CDlgMethod : public CDialogEx
{
	DECLARE_DYNAMIC(CDlgMethod)

public:
	CDlgMethod(CWnd* pParent = NULL);   // 标准构造函数
	virtual ~CDlgMethod();

// 对话框数据
	enum { IDD = IDD_DLG_METHOD };

protected:
	HICON m_hIcon;
	virtual BOOL OnInitDialog();
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV 支持

	DECLARE_MESSAGE_MAP()

public:
	virtual void OnOK();
	UINT m_nIDCheck;
};
