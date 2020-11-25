// xtp_vector.h
//
// This file is a part of the XTREME TOOLKIT PRO MFC class library.
// (c)1998-2012 Codejock Software, All Rights Reserved.
//
// THIS SOURCE FILE IS THE PROPERTY OF CODEJOCK SOFTWARE AND IS NOT TO BE
// RE-DISTRIBUTED BY ANY MEANS WHATSOEVER WITHOUT THE EXPRESSED WRITTEN
// CONSENT OF CODEJOCK SOFTWARE.
//
// THIS SOURCE CODE CAN ONLY BE USED UNDER THE TERMS AND CONDITIONS OUTLINED
// IN THE XTREME TOOLKIT PRO LICENSE AGREEMENT. CODEJOCK SOFTWARE GRANTS TO
// YOU (ONE SOFTWARE DEVELOPER) THE LIMITED RIGHT TO USE THIS SOFTWARE ON A
// SINGLE COMPUTER.
//
// CONTACT INFORMATION:
// support@codejock.com
// http://www.codejock.com
//
/////////////////////////////////////////////////////////////////////////////

//{{AFX_CODEJOCK_PRIVATE
#if !defined(__XTP_VECTOR_H__)
#define __XTP_VECTOR_H__
//}}AFX_CODEJOCK_PRIVATE

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#include <vector>

//===========================================================================
// Summary:
//     This class provide some vector ext functions.
// Remarks:
//===========================================================================


template<class T>
class xtp_vector : public std::vector<T>
{
public:
	xtp_vector() : vector() {}
	xtp_vector(const vector<T>& t) : vector(t) {}
	~xtp_vector() {vector::~vector();}

	template <typename T, size_t N>
	xtp_vector(T(&t)[N])
	{
		int n = xtp_countof(t);
		for(int i=0; i<n; i++)
			push_back(t[i]);
	}

	xtp_vector(const xtp_vector<T>& t)
	{
		clear();
		for (size_t i=0;i<t.size();i++)
		{
			push_back(t[i]);
		}
	}

	template <typename T, size_t N>
	xtp_vector& operator=(T(&t)[N])
	{
		int n = xtp_countof(t);
		for(int i=0; i<n; i++)
			push_back(t[i]);

		return *this;
	}

	xtp_vector& operator=(const vector<T>& t)
	{
		clear();
		for (size_t i=0;i<t.size();i++)
		{
			push_back(t[i]);
		}

		return *this;
	}

	xtp_vector& operator=(const xtp_vector<T>& t)
	{
		clear();
		for (size_t i=0;i<t.size();i++)
		{
			push_back(t[i]);
		}

		return *this;
	}

	T& operator [](const int i)
	{
		return at(i);
	}

	operator vector<T>() const
	{
		vector<T> t;
		for (int i=0;i<size();i++)
		{
			t.push_back(at(i));
		}

		return t;
	}

	operator T*() const
	{
		T* t = new T[size()];
		for (size_t i=0;i<size();i++)
		{
			t[i] = at(i);
		}

		return t;
	}

public:
	int contains(T t)
	{
		size_t i=0;
		size_t index=0;
		for (i=0;i<size();i++)
		{
			if(at(i)==t) index++;
		}
		return index;
	}

	int count() const
	{
		return size();
	}

	void append(T t)
	{
		if(!contains(t)) push_back(t);
	}

	void remove(T t)
	{
		size_t i=0;
		for (i=0;i<size();i++)
		{
			if(at(i) == t)
				break;
		}
		erase(i);
	}
};

#endif //__XTP_VECTOR_H__