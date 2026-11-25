/* SPDX-License-Identifier: GPL-3.0-or-later
 * Scaling-only adaptation of CarPlay Ultra-Lite source/native/hooks.c.
 * Original physical-size algorithm and CFLite ABI retained. */
typedef const void *CF;
typedef long CFIndex;
extern const int pps_table[] __attribute__((visibility("hidden")));
extern long pps_sys3(long,long,long,long);
enum { ORIG, RET, ARR_CALLBACKS, DICT_KEYS, DICT_VALUES, GET, SET,
       RELEASE, COUNT, AT_INDEX, NEW_ARRAY, APPEND, NEW_DICT, SET_INT, GET_INT,
       APPLY, TYPE, ARR_TYPE, DICT_TYPE };
#define PTR(i) ((void *)((const char *)pps_table + pps_table[i]))
#define FN(i,t) ((t)PTR(i))
#define CFS(n,s) static const struct { unsigned type,refs; char text[sizeof(s)]; } n __attribute__((aligned(4))) = {0x10756u,0x7fffffffu,s}
CFS(displays_key,"displays");
CFS(width_key,"widthPhysical");
CFS(height_key,"heightPhysical");
static CF get(CF d,CF k){return FN(GET,CF(*)(CF,CF))(d,k);}
static void set(CF d,CF k,CF v){FN(SET,void(*)(CF,CF,CF))(d,k,v);}
static void release(CF o){FN(RELEASE,void(*)(CF))(o);}
static int is(CF o,int t){return o && FN(TYPE,unsigned long(*)(CF))(o)==FN(t,unsigned long(*)(void))();}
static void copy(CF k,CF v,void *to){set(to,k,v);}
static int percent(void){
    char b[8]; long fd=pps_sys3(5,(long)"/data/data/com.daudio.app.dipo/files/pps-scale",0,0);
    if(fd<0)return 100;
    long n=pps_sys3(3,fd,(long)b,sizeof b);
    pps_sys3(6,fd,0,0);
    if(n<2 || n>3 || b[0]<'0'||b[0]>'9'||b[1]<'0'||b[1]>'9')return 100;
    if(n==3 && b[2]!='\n')return 100;
    int p=(b[0]-'0')*10+b[1]-'0';
    return p>=50 && p<100 && (b[1]=='0'||b[1]=='5')?p:100;
}
static int physical(CF d,CF key,int p){
    int err=0;
    long long mm=FN(GET_INT,long long(*)(CF,CF,int*))(d,key,&err);
    if(err||mm<=0||mm>10000)return 0;
    unsigned rest=(unsigned)mm*100u+(unsigned)p/2u,q=0;
    while(rest>=(unsigned)p){rest-=(unsigned)p;q++;}
    return (int)q;
}
__attribute__((visibility("hidden"))) void pps_info(CF info){
    int p=percent();
    if(p==100||!is(info,DICT_TYPE))return;
    CF displays=get(info,&displays_key);
    if(!is(displays,ARR_TYPE))return;
    CFIndex n=FN(COUNT,CFIndex(*)(CF))(displays);
    if(n<1||n>64)return;
    CF first=FN(AT_INDEX,CF(*)(CF,CFIndex))(displays,0);
    if(!is(first,DICT_TYPE))return;
    int w=physical(first,&width_key,p),h=physical(first,&height_key,p);
    if(!w||!h)return;
    CF out=FN(NEW_ARRAY,CF(*)(CF,CFIndex,const void*))(0,0,*(void**)PTR(ARR_CALLBACKS));
    if(!out)return;
    CF d=FN(NEW_DICT,CF(*)(CF,CFIndex,const void*,const void*))(0,0,*(void**)PTR(DICT_KEYS),*(void**)PTR(DICT_VALUES));
    if(!d){release(out);return;}
    FN(APPLY,void(*)(CF,void(*)(CF,CF,void*),void*))(first,copy,(void*)d);
    FN(SET_INT,void(*)(CF,CF,long long))(d,&width_key,w);
    FN(SET_INT,void(*)(CF,CF,long long))(d,&height_key,h);
    FN(APPEND,void(*)(CF,CF))(out,d);
    release(d);
    for(CFIndex i=1;i<n;i++)FN(APPEND,void(*)(CF,CF))(out,FN(AT_INDEX,CF(*)(CF,CFIndex))(displays,i));
    set(info,&displays_key,out);
    release(out);
}
