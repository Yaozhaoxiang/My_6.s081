#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
int
main(int argc, char* argv[])
{
    int pipefd1[2],pipefd2[2];
    int cpid;
    int pre;
    //生成第一个管道
    if(pipe(pipefd1)==-1)
    {
        printf("pipe error\n");
        exit(-1);
    }
    
    cpid = fork();
    if(cpid==-1)
    {
        printf("fork erroe\n");
        exit(-1);
    }
    if (cpid==0)
    {
        //第一个进程传递2-35
        close(pipefd1[0]);
        for(int i=2;i<=35;i++)
        {
            write(pipefd1[1],&i,sizeof(int));
        }
        close(pipefd1[1]);
        exit(0);
    }
    else if (cpid>0)
    {
        close(pipefd1[1]); //关闭写端
    }
    int read_fd = pipefd1[0]; //读端仍然开放
    while (read(read_fd,&pre,sizeof(int)))
    {
        printf("prime %d\n",pre);
        // 为进程创建管道
        if(pipe(pipefd2)==-1)
        {
            printf("pipe error\n");
            exit(-1);
        }

        if((cpid=fork())==0)
        {
            int num;
            close(pipefd2[0]); 
            while(read(read_fd,&num,sizeof(int))>0) //从上一层管道读取数据
            {
                if(num%pre!=0)
                {
                    if(write(pipefd2[1],&num,sizeof(int))==-1)
                    {
                        printf("write to pipe");
                        exit(-1);
                    }
                }
            }
            close(pipefd2[1]);
            close(read_fd);
            exit(0);
        }
        else if(cpid>0)
        {
            close(read_fd);
            close(pipefd2[1]);
            read_fd=pipefd2[0];
        }
        else
        {
            printf("fork errof\n");
            exit(-1);
        }
    }
    close(read_fd);
    while(wait(0)>0);
    exit(0);
}



  