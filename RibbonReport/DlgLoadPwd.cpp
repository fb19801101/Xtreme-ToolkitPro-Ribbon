// DlgLoadPwd.cpp : ʵ���ļ�
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "DlgLoadPwd.h"


/////////////////////////////////////////////////////////////////////////////
// DlgLoadPwd �Ի���

CDlgLoadPwd::CDlgLoadPwd(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgLoadPwd::IDD, pParent)
	, m_strPwd(_T(""))
{
	m_hIcon= AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CDlgLoadPwd::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_LOADPWD_ET_PWD, m_strPwd);
}

BEGIN_MESSAGE_MAP(CDlgLoadPwd, CDialog)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgLoadPwd ��Ϣ�������
BOOL CDlgLoadPwd::OnInitDialog()
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