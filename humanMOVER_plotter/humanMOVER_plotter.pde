Table table;
int Tcount = 1;    
int rows = 1;
int live = 0;

void setup() {
  size(1400, 800);
  background(0);
  table = loadTable("user2620792019_10_8_22_40_p.csv", "header");
  println(table.getRowCount() + " total rows in table"); 
  rows = table.getRowCount();
  frameRate(200);
}

void draw() {

  int[] nums = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };

  background(0);

  switch (live) {
    
    case 0:
      
      for (int i=1; i < rows-1000; i++) {         
      
        TableRow rowM = table.getRow(i-1);
        TableRow row = table.getRow(i);
      
        float m_x = row.getFloat("mousex");
        float m_y = row.getFloat("mousey");
        float in_t = row.getFloat("intrial");
        float init = row.getFloat("harvtarget");
        float blk = (5-row.getFloat("blockvar"))*100;
      
        float m_x0 = rowM.getFloat("mousex");
        float m_y0 = rowM.getFloat("mousey");
        
        if (in_t==1) {
          if (init==1) {
            stroke(255-(blk/2), 255, blk/2, 255);        
            strokeWeight(2);
          } else {
            stroke(255-(blk/2), 255, blk/2, 150);
            strokeWeight(1);
          }
          line(m_x0-blk, m_y0, m_x-blk , m_y);
          stroke(125,125,125,125);
          line(m_x0+300, m_y0, m_x+300 , m_y);
        }
      }
      break;



    case 1:
      for (int i : nums) {
    
        TableRow row = table.getRow(Tcount+i);
    
        float in_t = row.getFloat("intrial");
        
        if (in_t==1) {
          float m_x = row.getFloat("mousex");
          float m_y = row.getFloat("mousey");
          float init = row.getFloat("inittarget");
          float harv = row.getFloat("harvtarget");
          stroke(255*harv, 255, 255, 15+12*i);
          strokeWeight(ceil(i/1.5));
          point(m_x+300,m_y);
        }
    
      }    
    
      //saveFrame("animateFastSlow-######.tif");
    
      if (Tcount>=rows-21) {
        Tcount=0;
        exit();
      } else {
        Tcount++;
      }
      break;
  }
}
