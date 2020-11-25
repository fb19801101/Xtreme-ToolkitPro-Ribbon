// DlgMethod.cpp : ʵ���ļ�
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "DlgMethod.h"
#include "afxdialogex.h"


// CDlgMethod �Ի���

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


// CDlgMethod ��Ϣ�������


BOOL CDlgMethod::OnInitDialog()
{
	CDialogEx::OnInitDialog();

	// TODO:  �ڴ���Ӷ���ĳ�ʼ��
	SetIcon(m_hIcon, TRUE);
	SetIcon(m_hIcon, FALSE);

	CheckRadioButton(IDC_METHOD_RO_XLSCSV, IDC_METHOD_RO_OTHER2, IDC_METHOD_RO_XLSCSV);

	return TRUE;  // return TRUE unless you set the focus to a control
	// �쳣: OCX ����ҳӦ���� FALSE
}


void CDlgMethod::OnOK()
{
	// TODO: �ڴ����ר�ô����/����û���
	m_nIDCheck = GetCheckedRadioButton(IDC_METHOD_RO_XLSCSV, IDC_METHOD_RO_OTHER2);
	CDialogEx::OnOK();
}
