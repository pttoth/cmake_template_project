#pragma once

#include "parentclass.h"

namespace ClassNameSpace{

class NewClass: public ParentClass
{
public:
    NewClass() = default;
    NewClass( const NewClass& other ) = default;
    NewClass( NewClass&& source ) = default;

    virtual ~NewClass() = default;

    NewClass& operator=( const NewClass& other ) = default;
    NewClass& operator=( NewClass&& source ) = default;

    bool operator==( const NewClass& other ) const = default;
protected:
private:
};

} // end of ClassNameSpace
