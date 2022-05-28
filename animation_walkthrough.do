********************************************************************************
****** Animating graphs in Stata
****** Requires: ffmpeg software: Download from https://www.ffmpeg.org/
****** Developed by: Sabhya Gupta sagupta@povertyactionlab.org
****** Last updated: Feb 14, 2022
********************************************************************************

cd "C:\Users\sabhyag\Documents\Research\coding_lunch\animation"

********************************************************************************
*********              First example of animation           ********************
********************************************************************************

twoway scatteri 2 1
twoway scatteri 3 4

* To actually see movement in the point, you will want to fix the x and y axis

twoway scatteri 2 1, yscale(range(0 5)) xscale(range(0 5)) ylabel(0(1)5) xlabel(0(1)5)
twoway scatteri 3 4, yscale(range(0 5)) xscale(range(0 5)) ylabel(0(1)5) xlabel(0(1)5)


forvalues x_coordinate = 1(1)5{
    
	twoway scatteri 2 `x_coordinate', yscale(range(0 5)) xscale(range(0 5)) ylabel(0(1)5) xlabel(0(1)5)
	graph export "example1_`x_coordinate'.png", as(png) width(1280) height(720) replace
}


** Now that we have the files as example_1, example_2 and so on, we can combine them using ffmpeg:

/* ffmpeg documentation: https://www.ffmpeg.org/ffmpeg.html

* -y: overwrite output files
* -framerate: number of frames in a second. Human beings see 24 frames a second but we can slow it down
* image2 - specifies the format of the input
* -i: to specify the input files
* -pixfmt - specify the format of the output files

*/

shell "C:\Users\sabhyag\Downloads\ffmpeg\bin\ffmpeg.exe"  -y -framerate 24 -f image2 -i "example1_%01d.png"  -pix_fmt yuv420p "example1_animation1.mp4"

** can slow it down using some of these features:
shell "C:\Users\sabhyag\Downloads\ffmpeg\bin\ffmpeg.exe"  -y -framerate 5 -f image2 -i "example1_%01d.png"  -pix_fmt yuv420p "example1_animation2.mp4"


** transform into a gif file:

/* -t: the duration of the mp4 file to convert to gif
   -r: same as the framerate but for mp4 files
*/

shell "C:\Users\sabhyag\Downloads\ffmpeg\bin\ffmpeg.exe" -y -r 24 -i "example1_animation1.mp4" -t 30 -r 10 "example1_animation1.gif"


********************************************************************************
*********              Second example of animation           *******************
********************************************************************************
use "baroda_0102_1obs.dta"

egen school_group= group(schoolid)

twoway scatter post_tot pre_tot if school_group==1, yscale(range(0 100)) xscale(range(0 100)) ylabel(0(10)100) xlabel(0(10)100)

//do this for all schools:

set graphics off
local graph_counter = 0

forvalues id = 1(1)98{
    
	twoway scatter post_tot pre_tot if school_group==`id', yscale(range(0 100)) xscale(range(0 100)) ylabel(0(10)100) xlabel(0(10)100)
	
	local graph_counter = `graph_counter'+1
	local name = string(`graph_counter', "%03.0f")
	
	graph export "example2_raw_files/example2_`name'.png", as(png) width(1280) height(720) replace

}


shell "C:\Users\sabhyag\Downloads\ffmpeg\bin\ffmpeg.exe"  -y -framerate 24 -f image2 -i "example2_raw_files/example2_%03d.png"  -pix_fmt yuv420p "example2_animation.mp4"


shell "C:\Users\sabhyag\Downloads\ffmpeg\bin\ffmpeg.exe" -y -r 24 -i "example2_animation.mp4" -t 30 -r 10 "example2_animation.gif"



********************************************************************************
************           Use animation to explain statistics   *******************
********************************************************************************

clear
local GraphCounter = 0
local mu_null = 0
local sd = 1
local z_crit = round(-1*invnormal(0.025)*1, 0.01) 								//invnormal calculates the normal quantiles


set graphics off

forvalues mu_alt = 1(0.01)3 {
    twoway function y=normalden(x,`mu_alt',`sd'),                               ///
    range(-3 5) color("47 170 159") dropline(`mu_alt') ||              			///
	function y=normalden(x,`mu_null',`sd'),                      				///
    range(-3 5) color("227 89 37") dropline(0)           				///
    xtitle("{&beta}") xlabel(,tstyle(none)) 		                           	///
    legend(off)  graphregion(color(white))                                      ///
    yscale(range(0 0.6) lstyle(none)) ytitle("") ylabel(,tstyle(none))			///
	text(0.45 0 "H{subscript:0}", color("227 89 37"))                           ///
    text(0.45 `mu_alt' "H{subscript:{&beta}}", color("47 170 159"))  
	
  local name = string(`GraphCounter', "%03.0f")
  quietly graph export "example3_raw_files\mu_alt_`name'.png", as(png) width(1280) height(720) replace

  local ++GraphCounter
}

//use in cmd prompter in windows to troubleshoot
shell "C:\Users\sabhyag\Downloads\ffmpeg\bin\ffmpeg.exe"  -y -framerate 25 -f image2 -i "example3_raw_files\mu_alt_%03d.png" -pix_fmt yuv420p "power_by_mean.mp4"

shell "C:\Users\sabhyag\Downloads\ffmpeg\bin\ffmpeg.exe" -y -r 25 -i "power_by_mean.mp4" -t 20 -r 25 "power_by_mean.gif"



*** What are some of the ways you can use this?
/*

Resources:

How to create animated graphics using Stata: https://blog.stata.com/2014/03/24/how-to-create-animated-graphics-using-stata/

How to create animated graphics to illustrate spatial spillover effects: https://blog.stata.com/2018/03/06/how-to-create-animated-graphics-to-illustrate-spatial-spillover-effects/

COVID-19 visualizations with Stata Part 6: Animations: https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-6-animations-f9d2b09985c2


*/

********************************************************************************