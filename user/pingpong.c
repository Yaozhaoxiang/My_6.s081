#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
void parent(int pipefd1[],int pipefd2[]);
void child(int pipefd1[],int pipefd2[]);
int main(int argc, char* argv)
{
    int pipefd1[2],pipefd2[2];
    int cpid;
    //创建两个管道
    pipe(pipefd1);
    pipe(pipefd2);

    cpid=fork();
    if(cpid==-1)
    {
        printf("fork error\n");
        exit(-1);
    }
    else if(cpid==0)
    {
        //子进程
        child(pipefd1,pipefd2);
    }
    else if(cpid>0)
    {
        //父进程
        parent(pipefd1,pipefd2);
    }
    exit(0);
}
void parent(int pipefd1[],int pipefd2[])
{
    char c='p';
    //pipefd1 p写,pipefd2 读
    close(pipefd1[0]);
    close(pipefd2[1]);
    write(pipefd1[1],&c,sizeof(char));
    if(read(pipefd2[0],&c,sizeof(char))>0)
    {
        printf("%d: received pong\n",getpid());
    }
    else
    {
        printf("read error!\n");
        exit(-1);
    }
    close(pipefd1[1]);
    close(pipefd2[0]);
}
void child(int pipefd1[],int pipefd2[])
{
    char c;
    //pipefd1 p写,pipefd2 读
    close(pipefd1[1]);
    close(pipefd2[0]);
    if(read(pipefd1[0],&c,sizeof(char))>0)
    {
        printf("%d: received ping\n",getpid());
    }
    else
    {
        printf("read error!\n");
        exit(-1);
    }
    write(pipefd2[1],&c,sizeof(char));
    close(pipefd1[0]);
    close(pipefd2[1]);
    exit(0);
}
