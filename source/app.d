import raylib;
import std;
enum windowx=800;
enum windowy=600;
Color tocolor(string s){
	auto d=s.chunks(2).take(3).map!(a=>a.to!ubyte(16)).array;
	return Color(d[0],d[1],d[2],255);
}
void main(string[] s){
	InitWindow(windowx, windowy, "Hello, Raylib-D!");
	SetWindowPosition(2000,0);
	SetTargetFPS(60);
	float[10] floats=0;
	while (!WindowShouldClose()){
		import processmonkeygrid;
		BeginDrawing();
			int w=!IsMouseButtonDown(0)?GetScreenWidth:GetMouseX;
			int h=!IsMouseButtonDown(0)?GetScreenHeight:GetMouseY;
			ClearBackground(Colors.BLACK);
			DrawText("Hello, World!", 10,10, 20, Colors.WHITE);
			foreach(p;readgrid(s[1],w.to!float,h.to!float,floats)){
				Rectangle rect=Rectangle(p.r.x,p.r.y,p.r.w,p.r.h);
				Color c=p.s.tocolor;
				//c.writeln;
				DrawRectangleRounded(rect,.2,5,c);
			}
			DrawFPS(10,10);
		EndDrawing();
	}
	CloseWindow();
}