enum maxgap=16;

struct rect{
	float x,y,w,h;
	this(float a,float b,float c,float d){
		x=a;
		y=b;
		w=c-a;
		h=d-b;
	}
}
struct pair{
	rect r;
	string s;
}
struct optassoarray(V, K) {
	struct triple {
		ulong index;
		K key;
		V value;
		auto tuple(){
			import std.typecons:t=tuple;
			return t(index,key,value);
		}
	}
	struct _pair {
		V value;
		K key;
	}
	_pair[] array;
	triple opIndex(ulong index) {
		return triple(index, array[index].key, array[index].value);
	}
	triple opIndex(K key) {
		foreach (i, pair; array) {
			if (pair.key == key) {
				return triple(i, pair.key, pair.value);
			}
		}
		return triple(-1, K.init, V.init);
	}
	ulong length() {
		return array.length;
	}
	void opIndexAssign(V value, K key) {
		foreach (i, pair; array) {
			if (pair.key == key) {
				array[i].value = value;
				return;
			}
		}
		array ~= _pair(value, key);
	}
	void opOpAssign(string s:"~")(V value){
		array~=_pair(value,K.init);
	}
	auto torange(){
		import std.range;
		alias T=typeof(&this);
		alias Iota=typeof(iota(0,ulong(10)));
		struct range{
			T parent;
			Iota i;
			triple front(){
				return (*parent)[i.front];
			}
			void popFront(){
				i.popFront;
			}
			bool empty(){
				return i.empty;
			}
		}
		return range(&this,iota(0,length));
	}
}

unittest {
	optassoarray!(int, string) foo;
	foo ~= 1;
	foo["foo"] = 2;
	foo ~= 3;
	assert(foo[0].value == 1);
	assert(foo[0].key == string.init);
	assert(foo[2].value == 3);
	assert(foo[2].key == string.init);
	assert(foo["foo"].index == 1);
	assert(foo["foo"].value == 2);
	import std;
	//foreach(index,key,value; foo.torange.map!(a=>a.tuple)) {
	//	writeln(index,"(",key,"):",value);
	//}
}
import std;
alias has=canFind;
pair[] readgrid(string file,float width,float height,float[] floats...){
	auto f=File(file).byLineCopy;
	static ProcessPipes pipe;
	static openpipe=true;
	if(openpipe){//pipe.stdout.isopen){
		openpipe=false;
		"opening pipe".writeln;
		pipe=pipeShell("calc -p");
	}
	pipe.stdout.byLine.take(10);//init pipe
	string calc(string s){
		pipe.stdin.writeln(s);
		pipe.stdin.flush;
		string t;
		if(s.has('=')){
			t="success";
			//t=pipe.stdout.byLineCopy.front;
		} else {
			t=pipe.stdout.byLineCopy.front;
		}
		//writeln(s,"=>",t);
		return t;
	}
	foreach(s;f.until("---")){//first section is comments/meta data
		writeln("//",s);
	}
	calc("w="~width.to!string);
	calc("h="~height.to!string);
	foreach(s;f.drop(1).until("---")){//2nd section is varibles assiment
		if(s.has("=")){
			calc(s);
		}else{
			calc(s~"="~floats[0].to!string);
			floats=floats[1..$];
		}
	}
	optassoarray!(float, string) ylines;
	foreach(s;f.drop(1).until("---")){// ylines
		if(s.has("=")){
			auto i=s.countUntil("=");
			ylines[s[0..i]]=calc(s[i+1..$]).to!float;
		} else {
			ylines~=calc(s).to!float;
		}
	}
	ylines["left"]=0;
	ylines["right"]=calc("w").to!float;
	
	optassoarray!(float, string) xlines;
	foreach(s;f.drop(1).until("---")){// xlines
		if(s.has("=")){
			auto i=s.countUntil("=");
			xlines[s[0..i]]=calc(s[i+1..$]).to!float;
		} else {
			xlines~=calc(s).to!float;
		}
	}
	xlines["top"]=0;
	xlines["bot"]=calc("h").to!float;
	
	ylines.writeln;
	xlines.writeln;
	//clean up lines
	xlines.array=xlines.array.filter!(a=>a.value>0||a.key!="").array;
	ylines.array=ylines.array.filter!(a=>a.value>0||a.key!="").array;
	xlines.array.sort!((a,b)=>a.value<b.value);
	ylines.array.sort!((a,b)=>a.value<b.value);
	auto yoffset=xlines["top"].index;
	auto xoffset=ylines["left"].index;
	auto gridw=ylines["right"].index-xoffset;
	auto gridh=xlines["bot"].index-yoffset;
	
	ylines.writeln;
	xlines.writeln;
	writeln(yoffset,xoffset,gridw,gridh);
	/*
	foo
	box]foo
	x,y]foo
	x1,y1..box2]foo
	box1..box2]foo
	box1..x2,y2]foo
	x1,y1..x2,y2]foo
	
	big ugly pile o code
	*/
	int xlook(string s){
		try{
			return xlines[s.to!int+xoffset].value.to!int;
		} catch(Exception w){
			auto i=xlines[s].index;
			if(i==-1){
				return -1;
			}
			return xlines[i].value.to!int;
		}
	}
	int ylook(string s){
		try{
			return ylines[s.to!int+xoffset].value.to!int;
		} catch(Exception w){
			auto i=ylines[s].index;
			if(i==-1){
				return -1;
			}
			return ylines[i].value.to!int;
		}
	}
	pair[] out_;
	{
	int x1,x2,y1,y2;//=0,1,0,1;
	string box1,box2;
	int square;
	string t;
	foreach(s;f.drop(1).until("---")){// rects
		//tokenizen
		if( ! s.has("]")){//foo
			box1="";
			t=s;
		} else {
			auto i=s.countUntil("]");
			t=s[i+1..$];
			s=s[0..i];
			if(s.has("..")){//box1..box2]foo
				i=s.countUntil("..");
				box1=s[0..i];
				box2=s[i+2..$];
			} else {//box]foo
				box1=s;
				box2="";
			}
		}
		//processing
		if(box1==""){//foo
			if(y1==0&&x2==0){
				assert(square<=gridw*gridh,"expanded past all grid lines:"~s);
				out_~=pair(
					rect(
						ylines[square%gridw].value,
						xlines[square/gridw].value,
						ylines[square%gridw+1].value,
						xlines[square/gridw+1].value,
					)
					,s);
				square++;
			} else {
				int w=x2-x1-1;
				assert(square<=w*(y2-y1-1),"expanded past local grid lines:"~s);
				out_~=pair(
					rect(
						ylines[square%w].value,
						xlines[square/w].value,
						ylines[square%w+1].value,
						xlines[square/w+1].value,
					)
					,s);
				square++;
			}
		} else { //]foo
			if(box1.has(",")){//x1,y1..box2]foo
				auto i=box1.countUntil(",");
				x1=ylook(box1[0..i]);
				y1=xlook(box1[i+1..$]);
			} else {//box1..box2]foo
				assert(0,"im not sure what this means");
			}
			if(box2==""){//box]foo
				x2=x1+1;
				y2=y1+1;
			} else {//box1..box2]foo
				if(box2.has(",")){
					auto i=box2.countUntil(",");
					x2=ylook(box2[0..i]);
					y2=xlook(box2[i+1..$]);
				} else {
					assert(0,"im not sure what this means");
				}
			}
			if(x1==-1||x2==-1||y1==-1||y2==-1){
				"failed".writeln;
			} else {
				out_~=pair(rect(x1,y1,x2,y2),t);
			}
		}
	}
	
	}
	out_.writeln;
	foreach(s;f.drop(1).until("---")){// extra data
		s.writeln;
	}
	return out_;
}
unittest{
	readgrid("basic.grid",240,360);
	readgrid("basic.grid",480,720);
	readgrid("basic.grid",1000,4000);
}