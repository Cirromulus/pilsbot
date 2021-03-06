$fa = $preview ? 8 : 4;
$fs = $preview ? 3 : 0.25;

module achse(){
	//color("brown")cylinder(d=17, h=22);
	color("brown")cylinder(d=17.4, h=22);
	translate([0,0,20]){
		//cylinder(d=15.5, h=50);
		cylinder(d=16, h=50);
	}
	cylinder(d=8.5, h=500);
}


difference()
{
	cylinder(d=22.5, h=72);
	achse();
	translate([0,-12/2,(50+20)-42]) union(){
		cube([50,12,42]);
		translate([0,12/2, 0]) rotate([0,90,0])cylinder(d=12, h=50);
	}
	translate([0,-8/2,50]) cube([100,8,100]);
}
