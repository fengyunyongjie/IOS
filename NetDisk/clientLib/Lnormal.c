//
//  Lnormal.cpp
//  ClientLib
//
//  Created by jiangwei on 12-11-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>

void   itoa   (   unsigned   long   val,   char   *buf,   unsigned   radix   )   
{   
    char   *p;                                 /*   pointer   to   traverse   string   */   
    char   *firstdig;                   /*   pointer   to   first   digit   */   
    char   temp;                             /*   temp   char   */   
    unsigned   digval;                 /*   value   of   digit   */   
    
    p   =   buf;   
    firstdig   =   p;                       /*   save   pointer   to   first   digit   */   
    
    do   {   
        digval   =   (unsigned)   (val   %   radix);   
        val   /=   radix;               /*   get   next   digit   */   
        
        /*   convert   to   ascii   and   store   */   
        if   (digval   >   9)   
            *p++   =   (char   )   (digval   -   10   +   'a ');     /*   a   letter   */   
        else   
            *p++   =   (char   )   (digval   +   '0 ');               /*   a   digit   */   
    }   while   (val   >   0);   
    
    /*   We   now   have   the   digit   of   the   number   in   the   buffer,   but   in   reverse   
     order.     Thus   we   reverse   them   now.   */   
    
    *p--   =   '\0 ';                         /*   terminate   string;   p   points   to   last   digit   */   
    
    do   {   
        temp   =   *p;   
        *p   =   *firstdig;   
        *firstdig   =   temp;       /*   swap   *p   and   *firstdig   */   
        --p;   
        ++firstdig;                   /*   advance   to   next   two   digits   */   
    }   while   (firstdig   <   p);   /*   repeat   until   halfway   */   
}

char *_itoa(int num,char *str,int radix)
{
/* 索引表 */

char index[]="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

unsigned unum; /* 中间变量 */

int i=0,j,k;

/* 确定unum的值 */

if(radix==10&&num<0) /* 十进制负数 */
{
unum=(unsigned)-num;
str[i++]='-';
}
else unum=(unsigned)num; /* 其他情况 */
/* 逆序 */
do
{
str[i++]=index[unum%(unsigned)radix];

unum/=radix;

}while(unum);

str[i]='\0';

    /* 转换 */

if(str[0]=='-') k=1; /* 十进制负数 */
else k=0;

    char temp;

for(j=k;j<=(i-k-1)/2;j++)
{

temp=str[j];

str[j]=str[i-j-1];

str[i-j-1]=temp;

}

return str;

}