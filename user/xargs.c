#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/param.h"
#define MAX_LINE 1024
int main(int argc,char* argv[])
{
    if(argc<2)
    {
        printf("Usage: %s <command>\n", argv[0]);
        exit(-1);
    }
    char buf[MAX_LINE];

    //先复制xargc后面的命令 
    //exec(fliename,argv):filename：可执行文件，argv：参数列表，argv[0]是可执行文件名，后面是参数
    char *xargv[MAXARG];
    int xargc=0;
    int n;
    for (int i = 1; i < argc; i++)
    {
        xargv[xargc]=argv[i];
        xargc++;
    } 
    //从输入端读取
    while ((n=read(0,buf,MAX_LINE))>0)
    {
       if(fork()==0)
       {
            char* arg=(char*)malloc(sizeof(buf));
            int index=0;
            for(int i=0;i<n;++i)
            {
                if(buf[i]==' ' || buf[i]=='\n')
                {
                    arg[index]=0;
                    xargv[xargc++]=arg;
                    index=0;
                    arg=(char*)malloc(sizeof(buf));
                }
                else
                {
                    arg[index++]=buf[i];
                }
            }
            xargv[xargc]=0;
            exec(xargv[0],xargv);
       }
       else
            wait(0);
    }
    

    exit(0);
}





