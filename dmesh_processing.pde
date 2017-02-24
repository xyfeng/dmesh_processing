import megamu.mesh.*; //<>//

ArrayList<PVector> dots; 

void setup()
{
  size(480, 480);
  background(255);
  noStroke();

  PImage img = loadImage("xi.jpg");
  //image(img, 0, 0);

  dots = new ArrayList<PVector>();
  for (int i=0; i<499; i++) {
    PVector one = new PVector(int(random(0, width)), int(random(0, height)));
    dots.add(one);
  }
  dots.add(new PVector(0, 0));
  dots.add(new PVector(0, height));
  dots.add(new PVector(width, 0));
  dots.add(new PVector(width, height));

  //create Delaunay
  float[][] points = new float[dots.size()][2];
  for ( int i=0; i<dots.size(); i++) {
    PVector one = dots.get(i);
    points[i][0] = one.x;
    points[i][1] = one.y;
  }
  Delaunay myDelaunay = new Delaunay( points );

  ArrayList<int[]> triangles = getTriangles(points, myDelaunay);
  
  // draw triangles, DMesh Style
  for( int t=0; t<triangles.size(); t++) {
    int[] one = triangles.get(t);
    int r = 0, g = 0, b = 0;
    for( int p=0; p<one.length; p++ ){
      int i = one[p];
      color c = img.get(int(points[i][0]), int(points[i][1]));
      r += red(c) / 3.0;
      g += green(c) / 3.0;
      b += blue(c) / 3.0;
    }
    color f = color(r,g,b);
    fill(f);
    triangle(points[one[0]][0], points[one[0]][1],points[one[1]][0], points[one[1]][1],points[one[2]][0], points[one[2]][1]);
  }
  
  // Gridient Triangles
  //loadPixels();
  //for (int n=0; n<height; n++) {
  //  for (int m=0; m<width; m++) {
  //    int index = n * width + m;
  //    // draw triangle
  //    PVector p = new PVector(m, n);
  //    for( int t=0; t<triangles.size(); t++) {
  //      int[] one = triangles.get(t);
  //      PVector d1 = new PVector(points[one[0]][0], points[one[0]][1]); 
  //      PVector d2 = new PVector(points[one[1]][0], points[one[1]][1]);
  //      PVector d3 = new PVector(points[one[2]][0], points[one[2]][1]);
  //      PVector bc = getBaryCentric(p, d1, d2, d3);
  //      if (bc.x<0 || bc.x > 1 || bc.y<0 || bc.y > 1 || bc.z < 0 || bc.z > 1) {
  //        continue;
  //      }
  //      color c1 = img.get(int(d1.x), int(d1.y));
  //      color c2 = img.get(int(d2.x), int(d2.y));
  //      color c3 = img.get(int(d3.x), int(d3.y));
  //      float r = red(c1)*bc.x + red(c2)*bc.y + red(c3)*bc.z;
  //      float g = green(c1)*bc.x + green(c2)*bc.y + green(c3)*bc.z;
  //      float b = blue(c1)*bc.x + blue(c2)*bc.y + blue(c3)*bc.z;
  //      color c = color(r, g, b);
  //      pixels[index] = c;
  //    }
  //  }
  //}
  //updatePixels();

  // draw dots
  fill(255, 0, 0);
  noStroke();
  for (int i=0; i<dots.size(); i++) {
    PVector one = dots.get(i);
    ellipse(one.x, one.y, 4, 4);
  }
  // draw edges
  //float[][] myEdges = myDelaunay.getEdges();
  //stroke(255, 0, 0);
  //noFill();
  //for (int i=0; i<myEdges.length; i++)
  //{
  //  float startX = myEdges[i][0];
  //  float startY = myEdges[i][1];
  //  float endX = myEdges[i][2];
  //  float endY = myEdges[i][3];
  //  line( startX, startY, endX, endY );
  //}
}

// use int[] to store triangle indexs
ArrayList<int[]> getTriangles(float[][] points, Delaunay de) {
  ArrayList<int[]> result = new ArrayList<int[]>();
  // loop through first points: i
  for ( int i=0; i<points.length; i++) {
    // links are first point links
    int[] links = de.getLinked(i);
    // loop through second points: links[j]
    for ( int j=0; j<links.length; j++) {
      int[] jlinks = de.getLinked(links[j]);
      // loop through third points: jlinks[k]
      for ( int k=0; k<jlinks.length; k++) {
        // make sure third point is not first point
        if( jlinks[k] == i || links[j] == jlinks[k]) {
          continue;
        }
        int[] klinks = de.getLinked(jlinks[k]);
        // loop through fourth points: klinks[l]
        for ( int l=0; l < klinks.length; l++) {
          if( klinks[l] == i ){
            // find triangle
            // println(i, links[j], jlinks[k]);
            // add three points into triangles arraylist
            int[] pt = {i, links[j], jlinks[k]};
            pt = sort(pt);
            boolean FOUND = false;
            for( int m=0; m<result.size(); m++){
              int[] one = result.get(m);
              if(one[0] == pt[0] && one[1] == pt[1] && one[2] == pt[2]){
                FOUND = true;
              }
            }
            if( FOUND == false ) {
              result.add(pt);
            }
            break;
          }
        }
      }
    }
  }
  return result;
}

// calcuate barycentric coordinates (u,v,w) for point p with respect to triangle (a,b,c)
// use 3d PVector to store u,v,w
// https://en.wikipedia.org/wiki/Barycentric_coordinate_system
PVector getBaryCentric(PVector p, PVector a, PVector b, PVector c) {
  PVector v0 = PVector.sub(b, a);
  PVector v1 = PVector.sub(c, a);
  PVector v2 = PVector.sub(p, a);
  float den = v0.x * v1.y - v1.x * v0.y;
  float v = (v2.x * v1.y - v1.x * v2.y) / den;
  float w = (v0.x * v2.y - v2.x * v0.y) / den;
  float u = 1.0f - v - w;
  return new PVector(u, v, w);
}