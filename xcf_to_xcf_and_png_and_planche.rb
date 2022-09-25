# script qui prend les fichiers S12_XXXY_normal.xcf est qui
# en fait les png commercant/non commercant campagne et planche à imprimer.

require 'mini_magick'
require 'fileutils'

gimp_bin = '/var/lib/flatpak/exports/bin/org.gimp.GIMP'
WDIR = Dir.pwd
TERR_DIRS = File.join(WDIR, 'export')
csv_territoires = File.join(WDIR, 'liste_territoires.csv')

force_regenere_png = false
force_regenere_xcf = false

def call_gimp(gimp_bin, terr_dir, cmd)
  `cd #{terr_dir} && #{gimp_bin} --no-interface --batch='(#{cmd})' -b '(gimp-quit 0)'`
end

def generate_card_board(terr, campagne = false, forcepng = false, existe_en_commercant = false, commercant = false)

  outfile = File.join(WDIR, "planches","board_#{terr.join("-")}_#{(campagne ? 'special' : 'normal')}#{(existe_en_commercant ? (commercant ? '_comoui' : '_comnon') : '')}.png")
  empty_png = File.join(WDIR, "empty.png")

  if !File.exist?(outfile) or forcepng
	  MiniMagick::Tool::Montage.new do |montage|
	    #montage.resize "3508x2480"
	    nums = []
	    terr.each{ |t|
	      nums    << t
	      dir_t = t.gsub(/[A-Z]/, "")
	      filepath_card = File.join(TERR_DIRS,"territoire_#{dir_t}","S12_#{t}_#{(campagne ? 'special' : 'normal')}#{(existe_en_commercant ? (commercant ? '_comoui' : '_comnon') : '')}.png")

	      if not File.exist?(filepath_card)
		puts "Erreur fichier png de territoire introuvable #{filepath_card}"
	      end

	      montage << filepath_card
	    }

	    # Complète jusqu'à 4.
	    (4 - terr.count).times{
	      montage << empty_png
	    }

	    montage.geometry "1725x1121+1+1"
	    montage << '-background'
	    montage << '#000000' # noir background du montage (pour la découpe)
	    montage << '-bordercolor'
	    montage << '#FFFFFF' # blanc bordure et fond des tile
	    montage << '-border'
	    montage << '2'
	    montage << '-tile' # 2x2 tile
	    montage << '2x2'
	    montage << outfile # C'est ici le nom du fichier de sortie
	  end
  else
	puts "La planche existe déjà"
  end

  return outfile
end

territoires_effectifs = []
territoires_effectifs_com = []

array_territories = Hash[CSV.read(csv_territoires)[1..-1].map{ |arr| [arr.first, arr[1..-1]] }]

array_territories.each do |num_just, autres_donnees|
  locality = autres_donnees[0]
  commercant = autres_donnees[1] == "yes"
  
  terr_dir = File.join(TERR_DIRS, "territoire_#{num_just}")
  
    
    puts "===========================> #{num_just}"

    # Génère le xcf normal
    outfilenamebl = "S12_#{num_just}_blanc.xcf"
    File.unlink(File.join(terr_dir, outfilenamebl)) if force_regenere_xcf && File.exist?(File.join(terr_dir, outfilenamebl))
    call_gimp(gimp_bin, terr_dir, "territoireblanc \"S12_#{num_just}_base.xcf\" \"#{outfilename}\"") if !File.exist?(File.join(terr_dir, outfilenamebl))
    
    # Génère le xcf en changeant la date en 2022
    outfilename = "S12_#{num_just}_normal.xcf"
    File.unlink(File.join(terr_dir, outfilename)) if force_regenere_xcf && File.exist?(File.join(terr_dir, outfilename))
    call_gimp(gimp_bin, terr_dir, "python-fu-montest RUN-NONINTERACTIVE \"S12_#{num_just}_blanc.xcf\" \"#{outfilename}\"") if !File.exist?(File.join(terr_dir, outfilename))
    
    # Génère le png normal
    outfilename = "S12_#{num_just}_normal.png"
    File.unlink(File.join(terr_dir, outfilename)) if force_regenere_png && File.exist?(File.join(terr_dir, outfilename))
    call_gimp(gimp_bin, terr_dir, "exportpng \"S12_#{num_just}_normal.xcf\" \"#{outfilename}\"") if !File.exist?(File.join(terr_dir, outfilename))
    
    # Génère le xcf special
    outfilename = "S12_#{num_just}_special.xcf"
    File.unlink(File.join(terr_dir, outfilename)) if force_regenere_xcf && File.exist?(File.join(terr_dir, outfilename))
    call_gimp(gimp_bin, terr_dir, "territoirejaune \"S12_#{num_just}_normal.xcf\" \"#{outfilename}\"") if !File.exist?(File.join(terr_dir, outfilename))
    
    # Génère le png special
    outfilename = "S12_#{num_just}_special.png"
    File.unlink(File.join(terr_dir, outfilename)) if force_regenere_png && File.exist?(File.join(terr_dir, outfilename))
    call_gimp(gimp_bin, terr_dir, "exportpng \"S12_#{num_just}_special.xcf\" \"#{outfilename}\"") if !File.exist?(File.join(terr_dir, outfilename))
    
    # Supprime le fichier avec la date non à jour
    File.unlink(File.join(terr_dir, outfilenamebl))

    # Si commercant, mettre les mentions
    if commercant
      territoires_effectifs_com << num_just
      
      outfilename = "S12_#{num_just}_normal_comnon.png"
      File.unlink(File.join(terr_dir, outfilename)) if force_regenere_png && File.exist?(File.join(terr_dir, outfilename))
      call_gimp(gimp_bin, terr_dir, "filtrecommercant \"S12_#{num_just}_normal.png\" \"#{outfilename}\" \"#{File.join(WDIR,'pas_commercant_new.png')}\"") if !File.exist?(File.join(terr_dir, outfilename))
      
      outfilename = "S12_#{num_just}_normal_comoui.png"
      File.unlink(File.join(terr_dir, outfilename)) if force_regenere_png && File.exist?(File.join(terr_dir, outfilename))
      call_gimp(gimp_bin, terr_dir, "filtrecommercant \"S12_#{num_just}_normal.png\" \"#{outfilename}\" \"#{File.join(WDIR,'commercant.png')}\"") if !File.exist?(File.join(terr_dir, outfilename))
    else
      territoires_effectifs << num_just
    end
end

# Génère les planches pour l'impression NORMAL / COMPAGNE
territoires_effectifs.each_slice(4) { |a| 
	# Normal
	generate_card_board(a, false, force_regenere_png, false, false)
	# Campagne
	generate_card_board(a, true, force_regenere_png, false, false)
}
# Génène les planches commerçants
territoires_effectifs_com.each_slice(4) { |a| 
	# Normal sans commercant
	generate_card_board(a, false, force_regenere_png, true, false)
	# Normal avec commercant
	generate_card_board(a, false, force_regenere_png, true, true)
	# Campagne sans mention des commerçants
	generate_card_board(a, true, force_regenere_png, false, false)
}

