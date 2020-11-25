// SkinPropertyPageThemes.h : header file
//

#ifndef __SKINPROPERTYPAGETHEMES_H__
#define __SKINPROPERTYPAGETHEMES_H__

struct THEMEINFO
{
	CString csIniFileName;
	CString csColorSchemes;
	CString csSizes;
	struct THEME* pTheme;
};

struct THEME
{
	CString strResourcePath;
	CArray<THEMEINFO*, THEMEINFO*> m_arrThemes;
};

/////////////////////////////////////////////////////////////////////////////
// CSkinPropertyPageThemes dialog

class CSkinPropertyPageThemes : public CPropertyPage
{
	DECLARE_DYNCREATE(CSkinPropertyPageThemes)

public:
	CSkinPropertyPageThemes();
	virtual ~CSkinPropertyPageThemes();

	//{{AFX_DATA(CSkinPropertyPageThemes)
	enum { IDD = IDD_DLG_SKIN_THEME };
	int		m_nSchema;
	CListBox	m_lboxSkins;
	CComboBox	m_cmbFonts;
	CComboBox	m_cmbColors;
	int		m_nTheme;
	int		m_nLocalSkins;
	BOOL	m_bApplyMetrics;
	BOOL	m_bApplyFrame;
	BOOL	m_bApplyColors;
	//}}AFX_DATA

	void EnumerateThemeColors(CXTPSkinManagerResourceFile* pFile, LPCTSTR lpszResourcePath, LPCTSTR lpszThemeName);
	void EnumerateThemes(CString strResourcePath);
	void FindThemes(CString strPath, BOOL bRecurse);
	void SetTheme(int nColor, int nFont);
	void ReleaseThemes();
	void ReloadThemes();

	//{{AFX_VIRTUAL(CSkinPropertyPageThemes)
protected:
	virtual BOOL OnInitDialog();
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

protected:
	//{{AFX_MSG(CSkinPropertyPageThemes)
	afx_msg void OnRadioSchema();
	afx_msg void OnReloadThemes();
	afx_msg void OnSelChangeListThemes();
	afx_msg void OnSelChangeComboColors();
	afx_msg void OnSelChangeComboFonts();
	afx_msg void OnDestroy();
	afx_msg void OnCheckApplyMetrics();
	afx_msg void OnCheckApplyFrame();
	afx_msg void OnCheckApplyColors();
	afx_msg void OnThemeChanged();
	afx_msg void OnThemeChangedLuna();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

#endif // __SKINPROPERTYPAGETHEMES_H__