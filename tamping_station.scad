$fn=100;

// Constants
wall_thickness=7;
floor_thickness=2;
inner_diameter=72.5;
outer_diameter=inner_diameter+2.0*wall_thickness;

tamper_base_diameter=58.5;
tamper_base_height=12;
tamper_handle_diameter=27;
tamper_handle_height=55;
tamper_handle_cutout_diameter=tamper_handle_diameter+2;
tamper_handle_cutout_height=32; // Actually the height at which the cutout starts.
tamper_angle=75;
tamper_y_offset=-8; // Needs to be hand tuned to avoid collision!
tamper_rest_height=7;
tamper_rest_offset=15;

portafilter_handle_cutout_diameter=18;
portafilter_handle_cutout_height=25; // Actually the height at which the cutout starts.
portafilter_ears_width=20; // The distance between the two height measurements below.
portafilter_ears_height_1=55;
portafilter_ears_height_2=56;
portafilter_ears_cutout_width=30;
portafilter_ears_tilt_angle=atan2((portafilter_ears_height_2-portafilter_ears_height_1), portafilter_ears_width);
echo(portafilter_ears_tilt_angle);

station_height=tamper_base_diameter+10;

// Create a hull of two to four circles
// Usage: RoundedCornerPolygon([x1, y1, r1], ..., [x4, y4, r4])
module RoundedCornerPolygon(A=[0, 0, 0], B=[0, 0, 0], C=[0, 0, -1], D=[0, 0, -1]) {

	// adapted from http://www.thingiverse.com/thing:9347 {
	hull() {

		translate([A[0], A[1], 0])
		circle(r=A[2]);

		if (B[2]!=-1) {

            translate([B[0], B[1], 0])
            circle(r=B[2]);

            if (C[2]!=-1) {

                translate([C[0], C[1], 0])
                circle(r=C[2]);

                if (D[2]!=-1) {

                    translate([D[0], D[1], 0])
                    circle(r=D[2]);

                }

            }

        }

    }

}

module TamperShape() {
    union() {
        cylinder(tamper_base_height, d=tamper_base_diameter);
        cylinder(tamper_handle_height, d=tamper_handle_diameter);
    }
}
module Tamper() {
    y_offset=tamper_y_offset+0.5*inner_diameter-0.5*tamper_base_diameter*cos(tamper_angle);
    echo(y_offset);
    translate([0, y_offset, 1*(floor_thickness+0.5*tamper_base_diameter)])
        rotate(tamper_angle, [1, 0, 0])
            TamperShape();
}
module Funnel() {
    translate([0, 0, station_height-8])
        cylinder(36, d=outer_diameter);
}

module Cutout(height, diameter) {
    translate([0, -0.5*0.5*(outer_diameter+inner_diameter), height+0.5*diameter])
        rotate(90, [1,0,0])
            translate([0, 0, -wall_thickness])
                linear_extrude(height=2*wall_thickness)
                    RoundedCornerPolygon(
                        [0.0, 0.0, 0.5*diameter],
                        [0.0, station_height, 0.5*diameter]
                    );
}
module TamperCutout() {
    Cutout(tamper_handle_cutout_height, tamper_handle_cutout_diameter);
}
module PortaFilterCutout() {
    Cutout(portafilter_handle_cutout_height, portafilter_handle_cutout_diameter);
}

module EarCutout() {
    intersection() {
        translate([0, -0.5*portafilter_ears_cutout_width, 0])
            cube([0.5*outer_diameter, portafilter_ears_cutout_width, station_height]);
        translate([0, 0, 0.5*(portafilter_ears_height_2+portafilter_ears_height_1)])
            rotate(portafilter_ears_tilt_angle, [1,0,0])
                translate([0, -0.5*outer_diameter, 0])
                    cube([0.5*outer_diameter, outer_diameter, station_height]);
    }
}
module EarsCutout() {
    union() {
        EarCutout();
        rotate(180, [0,0,1])
            EarCutout();
    }
}
module TamperRest() {
    intersection() {
        cylinder(station_height, d=outer_diameter);
        union() {
            translate([-outer_diameter-tamper_rest_offset, 0, 0])
                cube([outer_diameter, outer_diameter, tamper_rest_height], false);
            translate([tamper_rest_offset, 0, 0])
                cube([outer_diameter, outer_diameter, tamper_rest_height], false);
        }
    }
}

module TampingStationBase() {
    difference() {
        cylinder(station_height, d=outer_diameter);
        cylinder(station_height, d=inner_diameter);
    }
}

module TampingStation() {
    union() {
        difference() {
            TampingStationBase();
            TamperCutout();
            PortaFilterCutout();
            EarsCutout();
        }
        TamperRest();
    }
}

// Cross-section.
difference() {
    union() {//intersection() {//
        TampingStation();
        //Tamper();
        //Funnel();
    }
    //translate([0, -100, 0])
    //    cube(200, true);
}