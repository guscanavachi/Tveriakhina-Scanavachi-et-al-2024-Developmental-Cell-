
nrois = roiManager("count");
//print(nrois);
Table.create("Nuclei");


for(i=0, j=0; i<nrois; i=i+1){
   x1 = 0;
   y1 = 0;
   //roiManager("select", i);
   //Stack.setChannel(2);
   //run("Measure");
   //area1 = getResult("Area");
   //print(area1);
   
   roiManager("select", i);
     Stack.getPosition(channel, slice, frame); 
     
    if(i == 0){
    	frame1 = frame;
    }
    
    if(frame>frame1){
    	frame1=frame;
    	j=0;
    }
    
   print("j = ", j);
   //Stack.setChannel(2);
   run("Enlarge...", "enlarge=-2");
   //run("Measure");
   //area = getResult("Area");
   //print(area);
   
   Roi.getBounds(x0, y0, width, height);
   Roi.move(x0+x1, y0+y1);
 
     
   	run("Measure");
   	print(frame);
   	mean = getResult("Mean");
   	mode = getResult("Mode");
   	median = getResult("Median");
   	min = getResult("Min");
   	max = getResult("Max");
   	
   	selectWindow("Nuclei");
   	Table.set("Time"+frame, j, slice);
   	Table.set("Average"+frame, j, mean);
   	Table.set("mode"+frame, j, mode);
   	Table.set("median"+frame, j, median);
   	Table.set("min"+frame, j, min);
   	Table.set("max"+frame, j, max);
   	
   	//print(mean);
   	j = j +1;
   	wait(500);
   

   
}