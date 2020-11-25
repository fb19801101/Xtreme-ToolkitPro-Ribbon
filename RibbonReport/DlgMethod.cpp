// DlgMethod.cpp : 实现文件
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "DlgMethod.h"
#include "afxdialogex.h"


// CDlgMethod 对话框

IMPLEMENT_DYNAMIC(CDlgMethod, CDialogEx)

CDlgMethod::CDlgMethod(CWnd* pParent /*=NULL*/)
	: CDialogEx(CDlgMethod::IDD, pParent)
{
	m_nIDCheck  =  0;
	m_hIcon= AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

CDlgMethod::~CDlgMethod()
{
}

void CDlgMethod::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}


BEGIN_MESSAGE_MAP(CDlgMethod, CDialogEx)
END_MESSAGE_MAP()


// CDlgMethod 消息处理程序


BOOL CDlgMethod::OnInitDialog()
{
	CDialogEx::OnInitDialog();

	// TODO:  在此添加额外的初始化
	SetIcon(m_hIcon, TRUE);
	SetIcon(m_hIcon, FALSE);

	CheckRadioButton(IDC_METHOD_RO_XLSCSV, IDC_METHOD_RO_OTHER2, IDC_METHOD_RO_XLSCSV);

	return TRUE;  // return TRUE unless you set the focus to a control
	// 异常: OCX 属性页应返回 FALSE
}


void CDlgMethod::OnOK()
{
	// TODO: 在此添加专用代码和/或调用基类
	m_nIDCheck = GetCheckedRadioButton(IDC_METHOD_RO_XLSCSV, IDC_METHOD_RO_OTHER2);
	CDialogEx::OnOK();
}
