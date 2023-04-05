/*
broken appooch, std bad
going to try pipes and a shell script next
*/
import std;
typeof(pipeShell("")) shell;
void system(string s){
	s.writeln;
	shell.stdin.writeln(s); 
	wait(shell.pid);
	auto r=shell.stdout.byLineCopy;
	while(!r.empty){
		r.front.writeln;
		r.popFront;
	}
	//return out_;
}
void main(){
	shell=pipeShell("echo");
	system("ls");//.writeln;
	system("export foo=bar");//.writeln;
	system("echo $bar");//.writeln;
}