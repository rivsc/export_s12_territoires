def couche_2(num_terr, layer_name)
mss_content = <<EOS

@zoom_tableau: 15;
@zoom_terr: 18;

#land[zoom=@zoom_terr], 
#landuse[zoom=@zoom_terr],
#land-high.shp{
   
    polygon-opacity:0;
   
    }
#motorway_label[zoom=@zoom_terr],
#mainroad_label[zoom=@zoom_terr],
#mainroad_label[type='primary'][zoom=@zoom_terr],
#mainroad_label[type='secondary'][zoom=@zoom_terr],
#mainroad_label[type='tertiary'][zoom=@zoom_terr],
#minorroad_label[zoom=@zoom_terr] {
    text-name:"";
    text-face-name:@sans;
    text-opacity:0;
    text-halo-opacity:0;
    polygon-opacity:0;
    line-opacity:0;
    ::case{ line-opacity:0;line-width: 16; } 
    ::fill{ line-opacity:0;line-width: 10; }
}

  #barrier_lines[zoom=@zoom_terr], 
  #barrier_points[zoom=@zoom_terr],   
  #roads_low[zoom=@zoom_terr], 
    #roads_med[zoom=@zoom_terr], 
    #roads_high[zoom=@zoom_terr], 
      #tunnel[zoom=@zoom_terr], 
      #bridge[zoom=@zoom_terr], 
      #buildings[zoom=@zoom_terr]{
      polygon-opacity:0;
    line-opacity:0;
    ::outline{line-opacity:0;polygon-opacity:0;}
    ::case{ line-opacity:0;polygon-opacity:0;line-width: 16; } 
    ::fill{ line-opacity:0;polygon-opacity:0;line-width: 10; }
    }

#area_label {
  text-name:"";
  text-face-name:@sans;
  text-opacity:0;
  text-halo-opacity:0;
     
  [zoom=@zoom_terr]{
    text-size: 40;
    text-opacity:0;
    text-halo-opacity:0;
  }
}
  #buildings[zoom=@zoom_terr]{
    polygon-opacity:0;
    building-fill-opacity:0;
    line-opacity:0;
  }

##{layer_name} {
    polygon-opacity:0;
}
#motorway_label[oneway!=0][zoom=@zoom_terr],
#mainroad_label[oneway!=0][zoom=@zoom_terr],
#minorroad_label[oneway!=0][zoom=@zoom_terr] {
  marker-opacity:0;
}
#landuse_parking[zoom=@zoom_terr] {
  [type='parking'] {
     point-opacity:0;
  }
}

##{layer_name} {
  // Style territoires sur plan tableau
  [zoom=@zoom_tableau]{
  	text-name:"[Name]";
    text-size:10;
    polygon-opacity:0;
    line-color:#444;
  	line-width:1;
    text-opacity:0.5;
    text-halo-opacity:0.7;
    text-fill:#00F;
  }
    
  // Style territoires sur carte de territoire
  [zoom=@zoom_terr]{
  	text-name:"";
  }
  
  text-name:"";
  line-color:#999;
  line-width:0;
  polygon-opacity:0.2;/* vert 0.0 - rouge 0.2 - blanc 1.0 */
  polygon-fill:#F00;/* vert #FFF - rouge #F00 - blanc #FFF */
  /*Libelle du texte*/
  text-face-name:"DejaVu Sans Bold";
  text-allow-overlap:true;
  text-size:20;
  text-fill:#000;
  text-halo-fill:#FFF;
  text-halo-radius:2;

  [Name = "OUT_OF_TERRITORY"]{
    text-name:"";
    line-width:0;
    [zoom=@zoom_tableau]{
      polygon-opacity:0;
    }
    // Pour plan général

    /**/
  }
  
  [Name = "#{num_terr}"]{
    text-name:"";
    text-face-name:"DejaVu Sans Bold";
    text-allow-overlap:true;
    text-size:10;
    text-fill:#0F0;
    polygon-fill:#FFF;/* vert #0F0 - rouge #FFF - blanc #FFF */
    polygon-opacity:0.0;/* vert 0.2 - rouge 0.0 - blanc 0.0 */
  }
}
  

EOS
end

