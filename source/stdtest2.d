import std;
void init(){
	spawnShell("source/runcalc.sh");
}
string system(string s){
	File("in","w").writeln(s);
	return File("out").byLineCopy.front;
}
void main(){
	init;
	system("1+1").writeln;
	system("1+1").writeln;
	system("1+1").writeln;
	system("1+1").writeln;
}