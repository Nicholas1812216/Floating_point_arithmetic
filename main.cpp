/******************************************************************************

                              Online C++ Compiler.
               Code, Compile, Run and Debug C++ program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <iostream>
#include <fstream>

using namespace std;
union S
{
    int x_int;
    float x;
};
int main()
{
    
    ofstream myfile;
    myfile.open("float_test_data.txt");
    S s[14];
    float dat[14] = {0,0,0,0,0,1234.3987,-17762.0,832.895612,0.190283732124,-89780923.0,
    0,0,0,0
    };
    for(int i = 0;i < 14; i++)
    {
        s[i].x = dat[i];
    }
    
    s[0].x_int = 0x00000000; //zero case
    s[1].x_int = 0x000003a6; //no leading one, normalized
    s[2].x_int = 0x7f800000; //pos inf
    s[3].x_int = 0xff800000; //neg inf
    s[4].x_int = 0x7f80001b; //NAN
    s[10].x_int = 0x4f7fffff; //max value
    s[11].x_int = 0x4fffffff; //just outside of max value
    s[12].x_int = 0x3b000000; //min value
    s[13].x_int = 0x3a000000; //just below min value

    
    
    for(int i = 0;i<14;i++)
    {
        if(i == 0)
        {
           myfile<<"00000000"<<"\n"; 
        }
        else if(i == 1)
        {
            myfile<<"00000"<<s[i].x_int<<"\n";
        }
        else
        {
          cout<<hex<<s[i].x<<"\n";
          myfile<<hex<<s[i].x_int<<"\n";   
        }

    }
    myfile.close();
    
    // s.x = -1.239857;
    // cout<<hex<<s.x_int<<"\n";


    return 0;
}
