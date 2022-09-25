#!/usr/bin/env ruby
# encoding : utf-8

##################################################################
# script qui pilote tilemill et exporte les différentes couches
# et génére les territoires complet au format XCF
##################################################################

require 'rubygems'
require 'nokogiri'
require 'fileutils'
require 'csv'

##################
## Configuration
##################

home = `echo $HOME`.strip
# Chemin absolu du dossier des scripts utilisateurs de GIMP (ATTENTION gimp doit impérativement être installé avec flatpak !!!)
gimp_script_dir = "#{home}/.config/GIMP/2.10/scripts"
# Chemin absolu de l'executable (index.js) de tilemill
tilemill_exe    = "#{home}/tilemill_project/tilemill/index.js"
# Chemin absolu vers le projet OSMBright
osmbright_project_name = "osm-bright-new" # lorsque tilemill est lancé et que vous ouvrez le projet c'est ce que vous voyez dans la barre d'adresse, probablement que le dossier s'appellera OSMBright chez vous
osmbright       = "#{home}/Documents/MapBox/project/#{osmbright_project_name}" 
# Nom du layer correspondant au doc.kml dans tilemill
layer_name = "territoires"
# Boundingbox plan (plus la valeur est grande plus le contexte du territoire sera grand et plus le territoire appaitra petit sur le S12)
bbox_plan = 0.0004

##################
## fin Configuration
##################

WDIR = Dir.pwd
# Chemin absolu sur kml qui contient tous les territoires détourés (méthode béthel)
kml_territories = File.join(WDIR, "doc.kml")
# Chemin absolu vers le fichier S12_std.xcf vide
s12exemple = File.join(WDIR, "S12_std.xcf")
# Chemin absolu du dossier d'export
output_dir = File.join(WDIR, "export")
# CSV qui répertorie les territoires (voir exemple)
csv_territoires = File.join(WDIR, "liste_territoires.csv")
FileUtils.mkdir_p(output_dir)

#################################
## installation des scripts gimp
#################################
Dir.glob(File.join(WDIR, "script_gimp", "*.scm")).each do |script_gimp|
  FileUtils.cp(script_gimp, File.join(gimp_script_dir, File.basename(script_gimp)))
end

# Taille des polices des rues (chaque taille sera dans un calque séparé)
array_textsize  = [40,45,50,55,60]

# Pour les numéros d'immeuble on prend les valeurs ci-dessus et on 
array_textsize_numero = [20,30,40,50]

[gimp_script_dir, kml_territories, tilemill_exe, s12exemple, output_dir, osmbright].each do |filepath|
  raise "Fichier ou dossier #{filepath} introuvable, veuillez corriger le chemin" if !File.exist?(output_dir)
end

# DONT TOUCH THIS
mss_file        = File.join(osmbright, "perso.mss")

# Zoom du territoire (ne pas changer car le CartoCSS est spécifique à ce niveau de zoom)
zoom      	= 18


array_territories = Hash[CSV.read("liste_territoires.csv")[1..-1].map{ |arr| [arr.first, arr[1..-1]] }] #(1..36).to_a + (100..117).to_a + (200..224).to_a + (300..315).to_a + (400..419).to_a #(1..5).to_a #(0..140)

require_relative 'ruby_plan/1_couche_plan'    # fond de carte sans les rues
require_relative 'ruby_plan/2_couche_rouge'   # Mets les limites du territoires en rouge
require_relative 'ruby_plan/3_parkings'       # Affiche les parkings pour le stationnement (attention certains sont payants ou fermés)
require_relative 'ruby_plan/4_poi'            # Point d'intérêt, permet de se répérer
require_relative 'ruby_plan/5_rue'            # Uniquement les noms des lieux et rues
require_relative 'ruby_plan/6_numero'         # Uniquement les numéros d'immeuble

def generate_mss(t, z, tsize, layer_name)
  return couche_5(tsize, layer_name)
end

def generate_mss_6(t, z, tsize, layer_name)
  return couche_6(tsize, layer_name)
end

print "Génération des territoires"

hashterr = {}

# Extract coordinates
xml_doc  = Nokogiri::XML(File.read(kml_territories))
xml_doc.remove_namespaces!
xml_doc.xpath("//Placemark").each{ |xmlplacemark|
  # Exemple : Metz : lat:49 long:6
  # Initialize coords
  hshll = {
    :min_long => 180.0,
    :min_lat  => 90.0,
    :max_long => -180.0,
    :max_lat  => -90.0
  }

  # Define bounding box coords
  xmlplacemark.xpath("Polygon/outerBoundaryIs/LinearRing/coordinates").text.strip.split(" ").each{ |coor|
    coords = coor.strip.split(",")
    long = coords[0].to_f
    lat  = coords[1].to_f

    hshll[:min_long] = long if hshll[:min_long] > long
    hshll[:min_lat]  = lat  if hshll[:min_lat] 	> lat
    hshll[:max_long] = long if hshll[:max_long] < long
    hshll[:max_lat]  = lat  if hshll[:max_lat] 	< lat
  }

  # Save in hash
  terrname = xmlplacemark.xpath("name")[0].text.strip.gsub(/TERR_/,"")
  puts "==> terrname : " + terrname
  hashterr[terrname] = hshll
}

# Ecrit le script gimp
NB_COUCHES = 3 # 4 si on remet les parkings
nbimage = ((array_textsize.length + array_textsize_numero.length) + NB_COUCHES + 1)

gimpscript =<<EOS
(define (territoire #{(0..nbimage - 1).map{|i| "fname-#{i}" }.join(' ')} num localite outputfilename)
    (let* (
            ; first main image
            (image (car (gimp-file-load RUN-NONINTERACTIVE fname-0 fname-0)))
            ; them layer
            (drawable0 (car (gimp-image-get-active-drawable image)))
            ; open image as layer

	    #{(1..nbimage - 1).map{|i|
              "(drawable#{i} (car (gimp-file-load-layer RUN-NONINTERACTIVE image fname-#{i})))"
	    }.join("\n")}
            (numlayer (car (gimp-image-get-layer-by-name image "num")))
            (loclayer (car (gimp-image-get-layer-by-name image "loc")))
        )

#{(1..nbimage - 1).map{|i|
        "
        (gimp-image-insert-layer image drawable#{i} 0 0) ; add layer to image
        (gimp-layer-set-mode drawable#{i} NORMAL-MODE) ; set layer mixing mode
        (gimp-layer-scale drawable#{i} 975 975 FALSE) ; mets le layer à la taille de l'image
	(gimp-image-lower-item image drawable#{i}) ; déplace dans la stack
	(gimp-layer-translate drawable#{i} 375 100) ; Déplace le calque
        (gimp-item-set-visible drawable#{i} #{(((NB_COUCHES) >= i || (NB_COUCHES + array_textsize.length) == i || (NB_COUCHES + array_textsize.length + array_textsize_numero.length) == i) ? 'TRUE' : 'FALSE')})
        "
}.join("\n")}

        (gimp-text-layer-set-text numlayer num)
        (gimp-text-layer-set-font-size numlayer 50 PIXELS)
        (gimp-text-layer-set-text loclayer localite)
        (gimp-text-layer-set-font-size loclayer 50 PIXELS)

        ; merge layers
        ;(set! drawable (car (gimp-image-flatten image)))

        ; save
        (gimp-file-save RUN-NONINTERACTIVE image drawable0 outputfilename outputfilename)
    )
)

; Pour le lancer : cd testgimp && gimp --no-interface --batch='(territoire "S12_std.xcf" "terr_016.png" "terr_016_2.png" "S12_016.xcf")' -b '(gimp-quit 0)'
;gimp --no-interface --batch='(territoire "S12_std.xcf" "terr_001.png" "terr_002.png" "terr_003.png" "terr_004.png" "terr_005.png" "terr_006.png" "terr_007.png" "terr_008.png" "S12_016.xcf")' -b '(gimp-quit 0)'
EOS

File.open(File.join(gimp_script_dir, 'territoire.scm'), 'w') do |f|
  f.write(gimpscript)
end

array_territories.each{ |t, autres_donnees|
  files_terr = []
  terr = t.to_s.rjust(3,"0")

  # Ignore si le territoire n'existe pas
  if hashterr[terr].nil? then
    puts "Ignore #{terr} car non trouvé dans le kml"
    next
  end

  export_dir      = File.join("#{output_dir}", "territoire_#{terr}")
  FileUtils.mkdir_p(export_dir)

  # min_long, min_lat, max_long, max_lat
  bbox = "#{hashterr[terr][:min_long].round(4) - bbox_plan},#{hashterr[terr][:min_lat].round(4) - bbox_plan},#{hashterr[terr][:max_long].round(4) + bbox_plan},#{hashterr[terr][:max_lat].round(4) + bbox_plan}"

  # Mets l'eau transparente (pour avoir un fond de carte transparent), CartoCSS ne permet pas de gérer les priorités d'opérateur donc on modifie le fichier base.mss directement
  str_water = "Map { background-color: @water; }"
  str_transparent = "Map { background-color: transparent; }"
  
  base_mss_path = File.join(osmbright, "base.mss")
  base_mss_content = File.read(base_mss_path)
  base_mss_content.gsub!(str_water, str_transparent)
  File.open(base_mss_path, "w+") do |f|
    f.write(base_mss_content)
  end

  # Génère les plans rues
    array_textsize.each{ |textsize|
      contentfile = generate_mss(terr, zoom, textsize, layer_name)
      File.open(mss_file, "w") do |f|
        f.write(contentfile)
      end

      filename_output = "terr_#{zoom}_#{textsize}.png"
      files_terr << filename_output

      # Export png
      cmd = "#{tilemill_exe} export #{osmbright_project_name} #{export_dir}/#{filename_output} --format=png --verbose=off --width=1920 --height=1920 --bbox=\"#{bbox}\" --static_zoom=#{zoom}"
      puts "#{cmd}"
      system(cmd)
    }
  
    # Génère les numéros de maison
    array_textsize_numero.each{ |textsize|
      contentfile = generate_mss_6(terr, zoom, textsize, layer_name)
      File.open(mss_file, "w") do |f|
        f.write(contentfile)
      end

      filename_output = "terr_numero_#{zoom}_#{textsize}.png"
      files_terr << filename_output

      # Export png
      cmd = "#{tilemill_exe} export #{osmbright_project_name} #{export_dir}/#{filename_output} --format=png --verbose=off --width=1920 --height=1920 --bbox=\"#{bbox}\" --static_zoom=#{zoom}"
      puts "#{cmd}"
      system(cmd)
    }

  files_layer = []

  # Génère les autres couches
  couches = ["couche_2","couche_4","couche_1"]  # "couche_3" les parkings sont bien mal renseigné
  couches.each{ |filerb|
  
    if filerb == "couche_1"
	# revert l'eau transparente
	base_mss_content.gsub!(str_transparent, str_water)
	File.open(base_mss_path, "w+") do |f|
	  f.write(base_mss_content)
	end
    end
  
    puts "=========> #{filerb}"
    File.open(mss_file, "w") do |f|
      methode_to_call = "#{filerb}(#{(filerb == "couche_2" ? "'#{terr}'," : "")}'#{layer_name}')"
      f.write(eval(methode_to_call))
    end

    filename_output = "terr_#{filerb}.png"
    files_layer << filename_output

    cmd = "#{tilemill_exe} export #{osmbright_project_name} #{export_dir}/#{filename_output} --format=png --verbose=off --width=1920 --height=1920 --bbox=\"#{bbox}\" --static_zoom=#{zoom}"
    puts "#{cmd}"
    system(cmd)
  }

  allfiles = files_layer.sort + files_terr

  files_params = "#{allfiles.map{ |f| "\"#{File.join(export_dir,f)}\"" }.join(' ')}"
  
  localite = autres_donnees[0]
  
  terr_filename = File.join(export_dir,"S12_#{terr}.xcf")

  gimpcmd = "gimp --no-interface --batch='(territoire \"#{s12exemple}\" #{files_params} \"#{terr}\" \"#{localite}\" \"#{terr_filename}\")' -b '(gimp-quit 0)'"
  puts "=======>"
  puts gimpcmd
  system(gimpcmd)
  
  terr_normal_filename = File.join(export_dir,"S12_#{terr}_base.xcf")
  
  gimpcmd = "gimp --no-interface --batch='(changetransparent \"#{terr_filename}\" \"#{terr}\" \"#{terr_normal_filename}\")' -b '(gimp-quit 0)'"
  puts "=======>"
  puts gimpcmd
  system(gimpcmd)
  
  print "."
}

`open #{output_dir}`

puts "====> Terminé !"

