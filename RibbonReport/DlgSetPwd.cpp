// DlgSetPwd.cpp : ʵ���ļ�
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "DlgSetPwd.h"


/////////////////////////////////////////////////////////////////////////////
// CDlgSetPwd �Ի���

CDlgSetPwd::CDlgSetPwd(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgSetPwd::IDD, pParent)
	, m_strUser(_T(""))
	, m_strPwd(_T(""))
	, m_strPwd2(_T(""))
	, m_strPwd3(_T(""))
{
	m_hIcon= AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CDlgSetPwd::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_SETPWD_ET_USER, m_strUser);
	DDX_Text(pDX, IDC_SETPWD_ET_PWD, m_strPwd);
	DDX_Text(pDX, IDC_SETPWD_ET_PWD2, m_strPwd2);
	DDX_Text(pDX, IDC_SETPWD_ET_PWD3, m_strPwd3);
}

BEGIN_MESSAGE_MAP(CDlgSetPwd, CDialog)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgSetPwd ��Ϣ�������
BOOL CDlgSetPwd::OnInitDialog()
{
	CDialog::OnInitDialog();

	// TODO:  �ڴ���Ӷ���ĳ�ʼ��
	SetIcon(m_hIcon, TRUE);
	SetIcon(m_hIcon, FALSE);
	
	// TODO: �ڴ���ӿؼ�֪ͨ����������

	UpdateData(FALSE);
	return TRUE;
	// �쳣: OCX ����ҳӦ���� FALSE
}