$fa = $preview ? 8 : 3;
$fs = $preview ? 3 : 0.25;

metal_w = 3;
inner_tube_inner_d = 20;// actually 22, but dents in hull;
inner_tube_outer_d = 25.5;
inner_tube_hole_d = 5;
outer_tube_inner_d = 35;
outer_tube_hole_d = 3;
hole_offs = 6;

ws = 2;

pot_d = 6.3;
pot_d_low = 16;
pot_h_low = 7;
pot_part_h = 15;
pot_gewinde_h = 6;
pot_gewinde_d = 7.5; // actually 7, but to offer more play
pot_schlitz = 1;
pot_schlitz_h = 6;
pot_kranz_d = 10.5;
pot_kranz_h = 2;
pot_pimmel = [3, 1.5, 4];

tube_height = 80;
rohrversatz = 20;
screw_safety_margin = 5;
lessen_slew = 1-0.5;


//calculated
pot_turn_h = pot_part_h - pot_gewinde_h;
pot_gesamt_h = pot_part_h + pot_kranz_h + pot_h_low;


module tube(inner_d, outer_d, height)
{
	difference()
	{
		cylinder(d = outer_d, h = height);
		translate([0,0,-.5]) cylinder(d = inner_d, h = height+1);
	}
}

module inner_tube()
{
	difference()
	{
		tube(inner_tube_inner_d, inner_tube_outer_d, tube_height);
		//hole
		translate([0, 0, tube_height - hole_offs]) rotate([90, 0, 0])
			cylinder(d = inner_tube_hole_d, h = inner_tube_inner_d + 10, center=true);
	}
	
}


%translate([0,0,-tube_height])
{
	//inner
	inner_tube();

	//outer
	difference()
	{
		tube(outer_tube_inner_d, outer_tube_inner_d+metal_w, tube_height-rohrversatz);
		//hole
		translate([0, 0, tube_height - rohrversatz - hole_offs]) rotate([90, 0, 90])
			cylinder(d = outer_tube_hole_d, h = outer_tube_inner_d + 10);
	}
}



module poti()
{
	cylinder(d = pot_d_low, h= pot_h_low);
	
	translate([0,0,pot_h_low])
	{
		//kranz
		cylinder(d = pot_kranz_d, h= pot_kranz_h);
		//platine
		translate([0, -pot_d_low/2, -1]) cube([15,pot_d_low, 1]);
		//pimmel
		translate([-pot_pimmel.x/2, -pot_d_low/2]) cube(pot_pimmel);
	}
	//gewinde
	translate([0,0,pot_h_low+pot_kranz_h]) cylinder(d = pot_gewinde_d, h= pot_gewinde_h);
	//rotator
	translate([0,0,pot_h_low+pot_kranz_h+pot_gewinde_h])
		color("grey") difference()
		{
			cylinder(d = pot_d, h= pot_turn_h);
			translate([-pot_schlitz/2, -25, pot_turn_h-pot_schlitz_h]) cube([pot_schlitz, 50, pot_schlitz_h]);
		};
}

module poti_rotated()
{
	#translate([0,0,pot_gesamt_h-hole_offs+inner_tube_hole_d/2+ws]) rotate([180,0,90]) poti();
}



i_h = 2*hole_offs;
color ("orange") difference()
{
	union()
	{
		//lower cylinder
		translate([0, 0, - i_h + .5*hole_offs]) cylinder(d = inner_tube_inner_d, h = 1.5*hole_offs);
		//kegel
		cylinder(d1 = inner_tube_inner_d, d2 = pot_d + 2*ws, h = pot_turn_h-hole_offs+inner_tube_hole_d/2);
	}
	translate([0, 0, - hole_offs]) rotate([90])
		cylinder(d = inner_tube_hole_d, h = outer_tube_inner_d + 10, center=true);
	poti_rotated();
}


!difference(){
	color("brown") 
	{
		//lower ring
		translate([0,0,-(rohrversatz+hole_offs+outer_tube_hole_d)]) difference()
		{
			union()
			{
				cylinder(h=3*outer_tube_hole_d, d = outer_tube_inner_d-ws);
				num_bebbels = 10;
				for(i = [0:num_bebbels])
				{
					rotate([0, 0, i*(360/num_bebbels)]) translate([(outer_tube_inner_d-ws)/2, 0, 0])
						cylinder(d=ws, h = 3*outer_tube_hole_d+ws);
				}
			}
			translate([0,0,-.5])cylinder(h=rohrversatz+hole_offs+1, d = inner_tube_outer_d);
		}
		
		//expansion
		expansion_base = rohrversatz-(hole_offs+inner_tube_hole_d/2);
		translate([0,0,-(rohrversatz)]) difference()
		{
			cylinder(d1=outer_tube_inner_d-ws, d2 = outer_tube_inner_d +2*(screw_safety_margin+ws),
				h=expansion_base);
			cylinder(d1=inner_tube_outer_d, d2 = outer_tube_inner_d +2*screw_safety_margin,
				h=expansion_base);
		}
		//middle
		middle_base = -rohrversatz+expansion_base+hole_offs;
		translate([0,0,-rohrversatz+expansion_base]) difference()
		{
			cylinder(d = outer_tube_inner_d +2*(screw_safety_margin+ws), h=hole_offs);
			cylinder(d = outer_tube_inner_d +2*(screw_safety_margin), h=hole_offs+1);
		}
		//inpansion (lol)
		translate([0,0,middle_base]) difference()
		{
			dimension = outer_tube_inner_d +2*(screw_safety_margin);
			cylinder(d1 = dimension+2*ws, d2 = dimension*lessen_slew,
				h=pot_part_h+ws/2);
			cylinder(d1 = dimension, d2 = pot_d_low,	//for better 3d-printability
				h=pot_part_h-ws/2);
		}
	}
	poti_rotated();
	//screw_slit
	hull()
	{
		translate([0, 0, -hole_offs]) rotate([90, 0, 0]) cylinder(d=inner_tube_hole_d+2*ws,
			h = 2*outer_tube_inner_d, center=true);
		translate([0, 0, -hole_offs-2*rohrversatz]) rotate([90, 0, 0]) cylinder(d=inner_tube_hole_d+2*ws,
			h = 2*outer_tube_inner_d, center=true);
	}
	translate([0, 0, - rohrversatz - hole_offs]) rotate([90, 0, 90])
		cylinder(d = outer_tube_hole_d, h = outer_tube_inner_d + 10);
	
	//schnittsicht
	//translate([0,0, -30]) cube([50, 50, 50]);
}
