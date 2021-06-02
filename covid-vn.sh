#!/bin/sh
if [ "$1" = "default" ]; then
curl -s https://api.apify.com/v2/key-value-stores/EaCBL1JNntjR3EakU/records/LATEST?disableRedirect=true | tail -n +6 | sed -e 's/ //g' -e 's/}//g'

elif [ "$1" = "extra" ]; then
cp ~/.local/covid-vn-new ~.local/covid-vn-old
curl -s https://api.apify.com/v2/key-value-stores/EaCBL1JNntjR3EakU/records/LATEST?disableRedirect=true |\
	tail -n +6 |\
	tr '\n' ' ' |\
	sed -e 's/ //g' \
	-e 's/}//g' \
	-e 's/"infected":/ /g' \
	-e 's/,"treated":/  /g' \
	-e 's/,"recovered":/  /g' \
	-e 's/,"deceased":/  /g' \
	> .local/covid-vn
cp ~/.local/covid-vn ~/.local/covid-vn-new

nhiemCu="$(awk '{print $2}' ~/.local/covid-vn-old)"
dieuTriCu="$(awk '{print $4}' ~/.local/covid-vn-old)"
khoiCu="$(awk '{print $6}' ~/.local/covid-vn-old)"
chetCu="$(awk '{print $8}' ~/.local/covid-vn-old)"

nhiemMoi="$(awk '{print $2}' ~/.local/covid-vn-new)"
dieuTriMoi="$(awk '{print $4}' ~/.local/covid-vn-new)"
khoiMoi="$(awk '{print $6}' ~/.local/covid-vn-new)"
chetMoi="$(awk '{print $8}' ~/.local/covid-vn-new)"

nhiemDif="$((nhiemMoi-nhiemCu))"
dieuTriDif="$((dieuTriMoi-dieuTriCu))"
khoiDif="$((khoiMoi-khoiCu))"
chetDif="$((chetMoi-chetCu))"
	if [ ! $nhiemDif -eq 0 ]; then
		if [ $nhiemDif -gt 0  ]; then
			dunstify -t 0 "CA NHIỄM MỚI" " +$nhiemDif" & sed -i "s/$nhiemMoi/$nhiemCu +$nhiemDif/g" ~/.local/covid-vn
		elif [ $nhiemDif -lt 0 ]; then
			dunstify -t 0 "CA NHIỄM MỚI" " $nhiemDif" & sed -i "s/$nhiemMoi/$nhiemCu $nhiemDif/g" ~/.local/covid-vn
		fi
	fi

	if [ ! $dieuTriDif -eq 0 ]; then
		if [ $dieuTriDif -gt 0  ]; then
			dunstify -t 0 "CA NHẬP VIỆN" " +$dieuTriDif" & sed -i "s/$dieuTriMoi/$dieuTriCu +$dieuTriDif/g" ~/.local/covid-vn
		elif [ $dieuTriDif -lt 0 ]; then
			dunstify -t 0 "CA NHẬP VIỆN" " $dieuTriDif" & sed -i "s/$dieuTriMoi/$dieuTriCu $dieuTriDif/g" ~/.local/covid-vn
		fi
	fi

	if [ ! $khoiDif -eq 0 ]; then
		if [ $khoiDif -gt 0  ]; then
			dunstify -t 0 "CA KHỎI BỆNH" " +$khoiDif" & sed -i "s/$khoiMoi/$khoiCu +$khoiDif/g" ~/.local/covid-vn
		elif [ $khoiDif -lt 0 ]; then
			dunstify -t 0 "CA KHỎI BỆNH" " $khoiDif" & sed -i "s/$khoiMoi/$khoiCu $khoiDif/g" ~/.local/covid-vn
		fi
	fi

	if [ ! $chetDif -eq 0 ]; then
		if [ $chetDif -gt 0  ]; then
			dunstify -t 0 "CA TỬ VONG" " +$chetDif" & sed -i "s/$chetMoi/$chetCu +$chetDif/g" ~/.local/covid-vn
		elif [ $chetDif -lt 0 ]; then
			dunstify -t 0 "CA TỬ VONG" " $chetDif" & sed -i "s/$chetMoi/$chetCu $chetDif/g" ~/.local/covid-vn
		fi
	fi

elif [ "$1" = "text" ]; then
cp ~/.local/covid-vn-new-text ~/.local/covid-vn-old-text
curl -s https://api.apify.com/v2/key-value-stores/EaCBL1JNntjR3EakU/records/LATEST?disableRedirect=true |\
	tail -n +6 |\
	sed -e 's/ //g' \
	-e 's/}//g' \
	-e '/"infected":/d' \
	-e 's/"treated":/\%\{F#D8DEE9\}NHPVN:\%\{F-\} /g' \
	-e '/"recovered":/d' \
	-e 's/"deceased":/\%\{F#D8DEE9\}TUVG:\%\{F-\} /g' \
	-e 's/,//g' |\
	tr '\n' ' ' |\
	sed 's/ $//g' \
	> ~/.local/covid-vn-text
cp ~/.local/covid-vn-text ~/.local/covid-vn-new-text

dieuTriCu="$(awk '{print $2}' ~/.local/covid-vn-old-text)"
chetCu="$(awk '{print $4}' ~/.local/covid-vn-old-text)"

dieuTriMoi="$(awk '{print $2}' ~/.local/covid-vn-new-text)"
chetMoi="$(awk '{print $4}' ~/.local/covid-vn-new-text)"

dieuTriDif="$((dieuTriMoi-dieuTriCu))"
chetDif="$((chetMoi-chetCu))"

	if [ ! $dieuTriDif -eq 0 ]; then
		if [ $dieuTriDif -gt 0  ]; then
			dunstify -t 0 "CA NHẬP VIỆN" " +$dieuTriDif" & sed -i "s/$dieuTriMoi/$dieuTriCu+$dieuTriDif/g" ~/.local/covid-vn-text
		elif [ $dieuTriDif -lt 0 ]; then
			dunstify -t 0 "CA XUẤT VIỆN" " $dieuTriDif" & sed -i "s/$dieuTriMoi/$dieuTriCu$dieuTriDif/g" ~/.local/covid-vn-text
		fi
	fi

	if [ ! $chetDif -eq 0 ]; then
		if [ $chetDif -gt 0  ]; then
			dunstify -t 0 "CA TỬ VONG" " +$chetDif" & sed -i "s/$chetMoi/$chetCu+$chetDif/g" ~/.local/covid-vn-text
		elif [ $chetDif -lt 0 ]; then
			dunstify -t 0 "CA TỬ VONG" " $chetDif" & sed -i "s/$chetMoi/$chetCu$chetDif/g" ~/.local/covid-vn-text
		fi
	fi

elif [ "$1" = "mini" ]; then
cp ~/.local/covid-vn-new-mini ~/.local/covid-vn-old-mini
curl -s https://api.apify.com/v2/key-value-stores/EaCBL1JNntjR3EakU/records/LATEST?disableRedirect=true |\
	tail -n +6 |\
	sed -e 's/ //g' \
	-e 's/}//g' \
	-e '/"infected":/d' \
	-e 's/"treated":/ /g' \
	-e '/"recovered":/d' \
	-e 's/"deceased":/ /g' \
	-e 's/,/ /g' \
	-e 's/\./,/g' |\
	tr '\n' ' ' \
	> ~/.local/covid-vn-mini
cp ~/.local/covid-vn-mini ~/.local/covid-vn-new-mini

dieuTriCu="$(awk '{print $2}' ~/.local/covid-vn-old-mini)"
chetCu="$(awk '{print $4}' ~/.local/covid-vn-old-mini)"

dieuTriMoi="$(awk '{print $2}' ~/.local/covid-vn-new-mini)"
chetMoi="$(awk '{print $4}' ~/.local/covid-vn-new-mini)"

dieuTriDif="$((dieuTriMoi-dieuTriCu))"
chetDif="$((chetMoi-chetCu))"

	if [ ! $dieuTriDif -eq 0 ]; then
		if [ $dieuTriDif -gt 0  ]; then
			dunstify -t 0 "CA NHẬP VIỆN" " +$dieuTriDif" & sed -i "s/$dieuTriMoi/$dieuTriCu +$dieuTriDif/g" ~/.local/covid-vn-mini
		elif [ $dieuTriDif -lt 0 ]; then
			dunstify -t 0 "CA XUẤT VIỆN" " $dieuTriDif" & sed -i "s/$dieuTriMoi/$dieuTriCu $dieuTriDif/g" ~/.local/covid-vn-mini
		fi
	fi

	if [ ! $chetDif -eq 0 ]; then
		if [ $chetDif -gt 0  ]; then
			dunstify -t 0 "CA TỬ VONG" " +$chetDif" & sed -i "s/$chetMoi/$chetCu +$chetDif/g" ~/.local/covid-vn-mini
		elif [ $chetDif -lt 0 ]; then
			dunstify -t 0 "CA TỬ VONG" " $chetDif" & sed -i "s/$chetMoi/$chetCu $chetDif/g" ~/.local/covid-vn-mini
		fi
	fi

fi
